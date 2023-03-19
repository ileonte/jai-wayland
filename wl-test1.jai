#import "Basic";
#import "POSIX";
#import "wayland";

Display :: struct {
    display: *wl_display;
    registry: *wl_registry;
    compositor: *wl_compositor;
    wm_base: *xdg_wm_base;
    fshell: *zwp_fullscreen_shell_v1;
    shm: *wl_shm;
    has_xrgb: bool;
}

display_init :: (_display: *Display) -> bool {
    using _display;

    display = wl_display_connect(null);
    assert(display != null);

    has_xrgb = false;
    registry = wl_display_get_registry_req(display);
    registry_listener := wl_registry_listener.{
        global = (data: *void, registry: *wl_registry, id: u32, intf: *u8, version: u32) -> void #c_call {
            d: *Display = data;
            if to_string(intf) == {
                case "wl_compositor"; wl_registry_bind_req(registry, id, *wl_compositor_interface, 1);
                case "xdg_wm_base"; {
                    listener := xdg_wm_base_listener.{
                        ping = (data: *void, shell: *xdg_wm_base, serial: u32) -> void #c_call {
                            xdg_wm_base_pong_req(shell, serial);
                        }
                    };
                    d.wm_base = wl_registry_bind_req(registry, id, *xdg_wm_base_interface, 1);
                    xdg_wm_base_add_listener(d.wm_base, *listener, d);
                }
                case "zwp_fullscreen_shell_v1"; {
                    d.fshell = wl_registry_bind_req(registry, id, *zwp_fullscreen_shell_v1_interface, 1);
                }
                case "wl_shm"; {
                    listener := wl_shm_listener.{
                        format = (data: *void, shm: *wl_shm, format: u32) -> void #c_call {
                            d: *Display = data;
                            if format == xx wl_shm_format_constants.format_xrgb8888 d.has_xrgb = true;
                        }
                    };
                }
            }
        },
        global_remove = (data: *void, registry: *wl_registry, name: u32) -> void #c_call {}
    };
    wl_registry_add_listener(registry, *registry_listener, display);
    wl_display_roundtrip(display);
    if shm == null {
        print("No wl_shm global\n", to_standard_error = true);
        return false;
    }
    wl_display_roundtrip(display);
    if !has_xrgb {
        print("WL_SHM_FORMAT_XRGB8888 not available\n", to_standard_error = true);
        return false;
    }

    return false;
}

display_destroy :: (display: *Display) {
    if display.shm wl_shm_destroy(display.shm);
    if display.wm_base xdg_wm_base_destroy_req(display.wm_base);
    if display.fshell zwp_fullscreen_shell_v1_release_req(display.fshell);
    if display.compositor wl_compositor_destroy(display.compositor);
    if display.registry wl_registry_destroy(display.registry);
    if display.display {
        wl_display_flush(display.display);
        wl_display_disconnect(display.display);
    }
    memset(display, 0, size_of(Display));
}

main :: () {
    wl_global_init();

    d: Display;
    if !display_init(*d) exit(1);
    display_destroy(*d);
}
