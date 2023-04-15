/*
 * @TODO:
 *  - fix flickering on window resize
 */

WLDisplay :: struct {
    handle: *wl_display;

    registry: *wl_registry;
    compositor: *wl_compositor;
    wm_base: *xdg_wm_base;
    shm: *wl_shm;
    seat: *wl_seat;

    decoration_manager: *zxdg_decoration_manager_v1;

    pointer: *wl_pointer;
    keyboard: *wl_keyboard;

    egl_dpy: EGLDisplay;
    egl_ctx: EGLContext;
    egl_cnf: EGLConfig;

    kb_context: *xkb_context;
    kb_keymap : *xkb_keymap;
    kb_state  : *xkb_state;
    mod_idx_shift     : u32;
    mod_idx_ctrl      : u32;
    mod_idx_alt       : u32;
    mod_idx_caps_lock : u32;
    mod_idx_super     : u32;
    mod_idx_alt_gr    : u32;
}

WLWindow :: struct {
    // we would really like this to be LDWindow but we get a circular dependency if we declare it like that
    wrapper: *void;

    handle: *wl_surface;
    display: *WLDisplay;

    x_surface: *xdg_surface;
    x_toplevel: *xdg_toplevel;
    x_toplevel_configured: bool;
    decoration: *zxdg_toplevel_decoration_v1;

    width: s32;
    height: s32;

    mouse_x: s32;
    mouse_y: s32;

    // this is here to "drive" the main loop when OpenGL is initialized
    callback: *wl_callback;

    egl_native: *wl_egl_window;
    egl_surface: EGLSurface;
}

wm_base_listener :: xdg_wm_base_listener.{
    ping = (data: *void, shell: *xdg_wm_base, serial: u32) -> void #c_call {
        xdg_wm_base.pong(shell, serial);
    }
};

registry_listener :: wl_registry_listener.{
    global = (data: *void, registry: *wl_registry, id: u32, intf: *u8, version: u32) -> void #c_call {
        d: *WLDisplay = data;

        if to_string(intf) == {
            case "wl_compositor"; d.compositor = wl_registry.bind(registry, id, *wl_compositor_interface, 1);
            case "xdg_wm_base"; {
                d.wm_base = wl_registry.bind(registry, id, *xdg_wm_base_interface, 1);
                xdg_wm_base.add_listener(d.wm_base, *wm_base_listener, d);
            }
            case "wl_shm"; {
                d.shm = wl_registry.bind(registry, id, *wl_shm_interface, 1);
            }
            case "wl_seat"; {
                d.seat = wl_registry.bind(
                    registry, id, *wl_seat_interface,
                    wl_min(version, cast(u32) wl_seat_interface.version));

                d.pointer = wl_seat.get_pointer(d.seat);
                wl_proxy.set_user_data(d.pointer, d);
                wl_pointer.add_listener(d.pointer, *pointer_listener, d);

                d.keyboard = wl_seat.get_keyboard(d.seat);
                wl_proxy.set_user_data(d.keyboard, d);
                wl_keyboard.add_listener(d.keyboard, *keyboard_listenter, d);
            }
            case "zxdg_decoration_manager_v1"; {
                d.decoration_manager = wl_registry.bind(registry, id, *zxdg_decoration_manager_v1_interface, 1);
            }
        }
    }
};

wl_init_display :: (display: LDDisplay) -> bool {
    wl_global_init();

    set(display, WLDisplay.{});
    d := isa(display, WLDisplay);

    d.handle = wl_display.connect(null);
    if !d.handle return false;

    d.registry = wl_display.get_registry(d.handle);
    wl_registry.add_listener(d.registry, *registry_listener, d);

    wl_display.roundtrip(d.handle);
    wl_display.roundtrip(d.handle);

    return true;
}

x_window_listener :: xdg_surface_listener.{
    configure = (data: *void, surface: *xdg_surface, serial: u32) -> void #c_call {
        w: *WLWindow = wl_proxy.get_user_data(surface);
        xdg_surface.ack_configure(surface, serial);
    }
};

x_toplevel_listener :: xdg_toplevel_listener.{
    configure = (data: *void, toplevel: *xdg_toplevel, width: s32, height: s32, states: *wl_array) -> void #c_call {
        ctx: Context;
        push_context ctx {
            w: *WLWindow = wl_proxy.get_user_data(toplevel);

            if !w.x_toplevel_configured {
                w.x_toplevel_configured = true;
                return;
            }

            w.width = max(width, 400);
            w.height = max(height, 400);
            if w.egl_native  wl_egl_window.resize(w.egl_native, w.width, w.height, 0, 0);
            add_resize_record(xx w.wrapper, xx w.width, xx w.height);
        }
    },
    close = (data: *void, toplevel: *xdg_toplevel) -> void #c_call {
        ctx: Context;
        push_context ctx {
            event: Event;
            event.type = .QUIT;
            array_add(*events_this_frame, event);
        }
    }
};

wl_create_window :: (d: *WLDisplay, ld_win: LDWindow, width: int, height: int, window_name: string,
    window_x: int, window_y: int, x11_parent: *WLWindow, background_color_rgb: [3]float) -> bool
{
    set(ld_win, WLWindow.{});
    w := isa(ld_win, WLWindow);

    w.wrapper = ld_win;
    w.display = d;
    w.width = xx width;
    w.height = xx height;

    w.handle = wl_compositor.create_surface(d.compositor);
    wl_proxy.set_user_data(w.handle, w);

    w.x_surface = xdg_wm_base.get_xdg_surface(d.wm_base, w.handle);
    wl_proxy.set_user_data(w.x_surface, w);
    xdg_surface.add_listener(w.x_surface, *x_window_listener, w);

    w.x_toplevel = xdg_surface.get_toplevel(w.x_surface);
    wl_proxy.set_user_data(w.x_toplevel, w);
    xdg_toplevel.add_listener(w.x_toplevel, *x_toplevel_listener, w);
    xdg_toplevel.set_title(w.x_toplevel, window_name.data);
    xdg_toplevel.set_app_id(w.x_toplevel, "com.ileonte.jai.wayland-1");  // @TODO: get this from the user somehow

    if d.decoration_manager {
        w.decoration = zxdg_decoration_manager_v1.get_toplevel_decoration(d.decoration_manager, w.x_toplevel);
        zxdg_toplevel_decoration_v1.set_mode(w.decoration, zxdg_toplevel_decoration_v1.mode_server_side);
    }

    wl_surface.damage(w.handle, 0, 0, w.width, w.height);
    wl_surface.commit(w.handle);

    return true;
}

frame_listener :: wl_callback_listener.{
    done = (data: *void, callback: *wl_callback, time: u32) -> void #c_call {
        w: *WLWindow = data;

        if callback wl_callback.destroy(callback);
        w.callback = wl_surface.frame(w.handle);
        wl_callback.add_listener(w.callback, *frame_listener, w);
    }
};

wl_setup_frame_updates :: (w: *WLWindow) {
    if w.callback wl_callback.destroy(w.callback);
    w.callback = wl_surface.frame(w.handle);
    wl_callback.add_listener(w.callback, *frame_listener, w);
}

wl_has_native_handle :: (w: *WLWindow, native_handle: *wl_surface) -> bool {
    return w.handle == native_handle;
}

wl_get_dimensions :: (w: *WLWindow, right_handed: bool) -> (x: s32, y: s32, width: s32, height: s32, success := true) {
    return 0, 0, w.width, w.height, true;
}
