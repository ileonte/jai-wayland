#import "Basic";
#import "POSIX";
#import "File";
#import "Sort";
#import "wayland";

running := true;

Display :: struct {
    display: *wl_display;
    registry: *wl_registry;
    compositor: *wl_compositor;
    wm_base: *xdg_wm_base;
    shm: *wl_shm;
    seat: *wl_seat;
    decoration_manager: *zxdg_decoration_manager_v1;

    pointer: *wl_pointer;
    cursor_theme: *wl_cursor_theme;
    default_cursor: *wl_cursor;
    cursor_surfaces: [..]*wl_surface;

    has_argb: bool;
    globals: [..]string;
}

Buffer :: struct {
    buffer: *wl_buffer;
    shm_data: *void;
    busy: bool;
}

Window :: struct {
    display: *Display;
    width: s32;
    height: s32;
    surface: *wl_surface;
    x_surface: *xdg_surface;
    x_toplevel: *xdg_toplevel;
    buffers: [2]Buffer;
    prev_buffer: *Buffer;
    callback: *wl_callback;
    decoration: *zxdg_toplevel_decoration_v1;
    wait_for_configure: bool;

    enter_serial: u32;

    initial_time: u32;
    final_time: u32;
    frames: u32;
}

display_init :: (d: *Display) -> bool {
    pointer_listener :: wl_pointer_listener.{
        enter = (data: *void, self: *wl_pointer, serial: u32, surface: *wl_surface,
            surface_x: wl_fixed_t, surface_y: wl_fixed_t) -> void #c_call
        {
            for *w : window_list {
                if w.surface != surface continue;
                hovered_window = w;
                hovered_window.enter_serial = serial;
            }

            ctx: Context;
            push_context ctx {
                print("HOVERED WINDOW: %\n", hovered_window);
            }
        },

        motion = (data: *void, self: *wl_pointer, time: u32, fx: wl_fixed_t, fy: wl_fixed_t) -> void #c_call {
        },

        button = (data: *void, self: *wl_pointer, serial: u32, time: u32, button: u32, state: u32) -> void #c_call {
            ctx: Context;
            push_context ctx {
                print("BUTTON EVENT -> serial = %, time = %, button = %, state = %\n", serial, time, button, state);
            }

            if hovered_window {
                toplevel := hovered_window.x_toplevel;
                seat := hovered_window.display.seat;
                if (button == 272) && (state == 1) {
                    xdg_toplevel.move(toplevel, seat, serial);
                } else if (button == 273) && (state == 1) {
                    xdg_toplevel.show_window_menu(toplevel, seat, serial, 0, 0);
                }
            }
        }
    };

    wm_base_listener :: xdg_wm_base_listener.{
        ping = (data: *void, shell: *xdg_wm_base, serial: u32) -> void #c_call {
            xdg_wm_base.pong(shell, serial);
        }
    };

    shm_listener :: wl_shm_listener.{
        format = (data: *void, shm: *wl_shm, format: u32) -> void #c_call {
            d: *Display = data;
            if format == wl_shm.format_argb8888 d.has_argb = true;
        }
    };

    registry_listener :: wl_registry_listener.{
        global = (data: *void, registry: *wl_registry, id: u32, intf: *u8, version: u32) -> void #c_call {
            d: *Display = data;

            ctx: Context;
            push_context ctx {
                array_add(*d.globals, copy_string(to_string(intf)));
            }

            if to_string(intf) == {
                case "wl_compositor"; d.compositor = wl_registry.bind(registry, id, *wl_compositor_interface, 1);
                case "xdg_wm_base"; {
                    d.wm_base = wl_registry.bind(registry, id, *xdg_wm_base_interface, 1);
                    xdg_wm_base.add_listener(d.wm_base, *wm_base_listener, d);
                }
                case "wl_shm"; {
                    d.shm = wl_registry.bind(registry, id, *wl_shm_interface, 1);
                    wl_shm.add_listener(d.shm, *shm_listener, d);
                }
                case "wl_seat"; {
                    d.seat = wl_registry.bind(
                        registry, id, *wl_seat_interface,
                        wl_min(version, cast(u32) wl_seat_interface.version));
                    d.pointer = wl_seat.get_pointer(d.seat);
                    wl_pointer.add_listener(d.pointer, *pointer_listener, d);
                }
                case "zxdg_decoration_manager_v1"; {
                    d.decoration_manager = wl_registry.bind(registry, id, *zxdg_decoration_manager_v1_interface, 1);
                }
            }
        }
    };

    d.display = wl_display.connect(null);
    assert(d.display != null);

    d.has_argb = false;
    d.registry = wl_display.get_registry(d.display);
    wl_registry.add_listener(d.registry, *registry_listener, d);

    wl_display.roundtrip(d.display);
    if d.shm == null {
        print("No wl_shm global\n", to_standard_error = true);
        return false;
    }

    wl_display.roundtrip(d.display);
    if !d.has_argb {
        print("WL_SHM_FORMAT_ARGB8888 not available\n", to_standard_error = true);
        return false;
    }

    quick_sort(d.globals, compare_strings);

    d.cursor_theme = wl_cursor_theme.load("breeze_cursors", 128, d.shm);
    if d.cursor_theme {
        for 0..d.cursor_theme.cursor_count - 1 {
            cursor := d.cursor_theme.cursors[it];
            name := to_string(cursor.name);
            print("CURSOR: '%' (% images)\n", name, cursor.image_count);
        }
        d.default_cursor = wl_cursor_theme.get_cursor(d.cursor_theme, "08e8e1c95fe2fc01f976f1e063a24ccd");
        if d.default_cursor {
            for image_idx: 0..d.default_cursor.image_count - 1 {
                surface := wl_compositor.create_surface(d.compositor);
                image := d.default_cursor.images[image_idx];
                buffer := wl_cursor_image.get_buffer(image);
                wl_surface.attach(surface, buffer, 0, 0);
                wl_surface.damage(surface, 0, 0, xx image.width, xx image.height);
                wl_surface.commit(surface);

                array_add(*d.cursor_surfaces, surface);
            }
        }
    }

    return true;
}

display_destroy :: (display: *Display) {
    if display.shm wl_shm.destroy(display.shm);
    if display.wm_base xdg_wm_base.destroy(display.wm_base);

    for display.cursor_surfaces {
        wl_surface.destroy(it);
    }
    array_reset(*display.cursor_surfaces);
    if display.cursor_theme wl_cursor_theme.destroy(display.cursor_theme);
    if display.pointer wl_pointer.release(display.pointer);

    if display.seat wl_seat.release(display.seat);
    if display.compositor wl_compositor.destroy(display.compositor);
    if display.decoration_manager zxdg_decoration_manager_v1.destroy(display.decoration_manager);
    if display.registry wl_registry.destroy(display.registry);
    if display.display {
        wl_display.flush(display.display);
        wl_display.disconnect(display.display);
    }
    memset(display, 0, size_of(Display));
}

window_init :: (d: *Display, w: *Window, width: s32, height: s32) -> bool {
    x_window_listener :: xdg_surface_listener.{
        configure = (data: *void, surface: *xdg_surface, serial: u32) -> void #c_call {
            w: *Window = data;
            xdg_surface.ack_configure(surface, serial);

            ctx: Context;
            push_context ctx {
                if w.wait_for_configure {
                    window_redraw(w, null, 0);
                    w.wait_for_configure = false;
                }
                print("XDG_SURFACE CONFIGURE(%)\n", surface);
            }
        }
    };

    x_toplevel_listener :: xdg_toplevel_listener.{
        configure = (data: *void, toplevel: *xdg_toplevel, w: s32, h: s32, states: *wl_array) -> void #c_call {
            ctx: Context;
            push_context ctx {
                print("XDG_TOPLEVEL CONFIGURE(%) STATES: [ ", toplevel);
                for state: wl_array_each(u32, states) {
                    if <<state == {
                        case xdg_toplevel.state_maximized; print("maximized ");
                        case xdg_toplevel.state_fullscreen; print("fullscreen ");
                        case xdg_toplevel.state_resizing; print("resizing(%x%) ", w, h);
                        case xdg_toplevel.state_activated; print("activated ");
                        case xdg_toplevel.state_tiled_left; print("tiled_left ");
                        case xdg_toplevel.state_tiled_right; print("tiled_right ");
                        case xdg_toplevel.state_tiled_top; print("tiled_top ");
                        case xdg_toplevel.state_tiled_bottom; print("tiled_bottom ");
                        case; print("unknown_state(%) ", <<state);
                    }
                }
                print("]\n");
            }
        },
        close = (data: *void, toplevel: *xdg_toplevel) -> void #c_call {
            running = false;
        }
    };

    decoration_listener :: zxdg_toplevel_decoration_v1_listener.{
        configure = (data: *void, decoration: *zxdg_toplevel_decoration_v1, mode: u32) -> void #c_call {
            ctx: Context;
            push_context ctx {
                print("XDG_DECORATION CONFIGURE(%) mode = %\n", decoration, mode);
            }
        }
    };

    w.display = d;
    w.width = width;
    w.height = height;

    w.surface = wl_compositor.create_surface(d.compositor);

    w.x_surface = xdg_wm_base.get_xdg_surface(d.wm_base, w.surface);
    xdg_surface.add_listener(w.x_surface, *x_window_listener, w);

    w.x_toplevel = xdg_surface.get_toplevel(w.x_surface);
    xdg_toplevel.add_listener(w.x_toplevel, *x_toplevel_listener, w);
    xdg_toplevel.set_title(w.x_toplevel, "Jai :: Wayland");
    xdg_toplevel.set_app_id(w.x_toplevel, "com.ileonte.jai.wayland-1");

    if d.decoration_manager {
        w.decoration = zxdg_decoration_manager_v1.get_toplevel_decoration(d.decoration_manager, w.x_toplevel);
        zxdg_toplevel_decoration_v1.set_mode(w.decoration, zxdg_toplevel_decoration_v1.mode_server_side);
        zxdg_toplevel_decoration_v1.add_listener(w.decoration, *decoration_listener, w);
    }

    w.wait_for_configure = true;
    wl_surface.commit(w.surface);

    return true;
}

window_next_buffer :: (w: *Window) -> *Buffer {
    buffer_listener :: wl_buffer_listener.{
        release = (data: *void, self: *wl_buffer) -> void #c_call {
            b: *Buffer = data;
            b.busy = false;
        }
    };

    b: *Buffer = null;
    if !w.buffers[0].busy b = *w.buffers[0];
    else if !w.buffers[1].busy b = *w.buffers[1];
    else return null;

    if !b.buffer {
        stride := w.width * 4;
        size := w.height * stride;

        fd := memfd_create("brrrap", 0);
        ftruncate(fd, size);

        data :*s32 = mmap(null, xx size, PROT_READ | PROT_WRITE, MAP_SHARED, fd, 0);
        for 0..(w.width * w.height) - 1 data[it] = 0xffffffff; // red?

        pool := wl_shm.create_pool(w.display.shm, fd, size);
        b.buffer = wl_shm_pool.create_buffer(pool, 0, w.width, w.height, stride, wl_shm.format_argb8888);
        wl_buffer.add_listener(b.buffer, *buffer_listener, b);
        wl_shm_pool.destroy(pool);
        close(fd);
        b.shm_data = data;
    }

    return b;
}

paint_pixels :: (image: *void, padding: s32, width: s32, height: s32, time: u32) {
	halfh := padding + (height - padding * 2) / 2;
	halfw := padding + (width  - padding * 2) / 2;
	ir, or: s32;
	pixel: *u32 = image;
	y: s32;

	/* squared radii thresholds */
	or = (ifx (halfw < halfh) then halfw else halfh) - 8;
	ir = or - 32;
	or *= or;
	ir *= ir;

	pixel += padding * width;
	for y: padding..(height - padding - 1) {
		y2 := (y - halfh) * (y - halfh);

		pixel += padding;
		for x: padding..(width - padding - 1) {
			v: u32;

			/* squared distance from center */
			r2 := (x - halfw) * (x - halfw) + y2;

			if (r2 < ir)
				v = (cast(u32) (r2 / 32) + time / 64) * 0x0080401;
			else if (r2 < or)
				v = (cast(u32) y + time / 32) * 0x0080401;
			else
				v = (cast(u32) x + time / 16) * 0x0080401;
			v &= 0x00ffffff;

            v |= 0xff000000;

			<<pixel = v;
            pixel += 1;
		}

		pixel += padding;
	}
}

window_redraw :: (data: *void, callback: *wl_callback, time: u32) {
    frame_listener :: wl_callback_listener.{
        done = (data: *void, callback: *wl_callback, time: u32) -> void #c_call {
            w: *Window = data;
            if !w.initial_time w.initial_time = time;
            w.final_time = time;
            w.frames += 1;

            ctx: Context;
            push_context ctx {
                window_redraw(data, callback, time);
            }

            d := w.display;
            if !d.default_cursor return;
            image_idx := wl_cursor.frame(d.default_cursor, time);
            image := d.default_cursor.images[image_idx];
            wl_pointer.set_cursor(
                d.pointer, w.enter_serial, d.cursor_surfaces[image_idx],
                xx image.hotspot_x, xx image.hotspot_y);
        }
    };

    w: *Window = data;
    b := window_next_buffer(w);
    assert(b != null);

    // paint_pixels(b.shm_data, 0, w.width, w.height, time);
    wl_surface.attach(w.surface, b.buffer, 0, 0);
    wl_surface.damage(w.surface, 0, 0, w.width, w.height);

    if callback wl_callback.destroy(callback);
    w.callback = wl_surface.frame(w.surface);
    wl_callback.add_listener(w.callback, *frame_listener, w);
    wl_surface.commit(w.surface);
    b.busy = true;
}

window_destroy :: (w: *Window) {
    if w.callback wl_callback.destroy(w.callback);
    if w.buffers[0].buffer wl_buffer.destroy(w.buffers[0].buffer);
    if w.buffers[1].buffer wl_buffer.destroy(w.buffers[1].buffer);
    if w.decoration zxdg_toplevel_decoration_v1.destroy(w.decoration);
    if w.x_toplevel xdg_toplevel.destroy(w.x_toplevel);
    if w.x_surface xdg_surface.destroy(w.x_surface);
    if w.surface wl_surface.destroy(w.surface);
    memset(w, 0, size_of(Window));
}

window_list: [..]Window;
hovered_window: *Window;

main :: () {
    print("%\n", type_of(wl_display_listener.error));

    args := get_command_line_arguments();
    defer array_reset(*args);

    window_count := 1;
    if args.count > 1 {
        count, ok := string_to_int(args[1], T = type_of(window_count));
        if ok window_count = min(8, max(1, count));
    }

    wl_global_init();

    d: Display;
    if !display_init(*d) {
        print("Could not create display.\n");
        exit(1);
    }
    defer display_destroy(*d);

    // for d.globals print("%\n", it);

    for 1..window_count {
        w := array_add(*window_list);

        if !window_init(*d, w, 800, 600) {
            print("Could not create window.\n");
            exit(1);
        }

        print("WINDOW: %\n", <<w);

        wl_surface.damage(w.surface, 0, 0, w.width, w.height);
        if !w.wait_for_configure {
            print("Redrawing window!\n");
            window_redraw(w, null, 0);
        }
    }
    defer for * w: window_list window_destroy(w);


    last_write := 0;
    while running {
        wl_display.dispatch(d.display);

        w := *window_list[0];
        seconds := (w.final_time - w.initial_time) / 1000;
        if ((seconds % 15) == 0) && (seconds > last_write) {
            fseconds := cast(float64)(w.final_time - w.initial_time) / 1000.0;
            fps := cast(float64)w.frames / fseconds;
            print("% frames in % s = % fps\n", w.frames, fseconds, fps);
            last_write = seconds;
        }
    }

    for * w: window_list {
        seconds := cast(float64)(w.final_time - w.initial_time) / 1000.0;
        fps := cast(float64)w.frames / seconds;
        print("% frames in % s = % fps\n", w.frames, seconds, fps);
    }

    print("DONE!\n");
}

libc :: #system_library "libc";
memfd_create :: (name: *u8, flags: s32) -> s32 #foreign libc;
