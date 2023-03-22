#import "Basic";
#import "POSIX";
#import "File";
#import "Sort";
#import "String";
#import "Math";

#import "wayland";
#import "EGL";
#import "glad";

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

    egl: struct {
        dpy: EGLDisplay;
        ctx: EGLContext;
        conf: EGLConfig;
    }
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

    use_gl: bool;
    native: *wl_egl_window;
    egl_surface: EGLSurface;
    gl: struct {
        w: s32;
        h: s32;
        program: u32;
        rotation_uniform: s32;
        empty_vao: u32;
    }

    buffers: [2]Buffer;
    prev_buffer: *Buffer;
    callback: *wl_callback;
    decoration: *zxdg_toplevel_decoration_v1;

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
        },

        motion = (data: *void, self: *wl_pointer, time: u32, fx: wl_fixed_t, fy: wl_fixed_t) -> void #c_call {
        },

        button = (data: *void, self: *wl_pointer, serial: u32, time: u32, button: u32, state: u32) -> void #c_call {
            if hovered_window {
                toplevel := hovered_window.x_toplevel;
                seat := hovered_window.display.seat;
                if (button == 272) && (state == 1) {
                    xdg_toplevel.move(toplevel, seat, serial);
                } else if (button == 273) && (state == 1) {
                    hovered_window.use_gl = !hovered_window.use_gl;
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

    /* init EGL */
    d.egl.dpy = eglGetDisplay(d.display);
    assert(d.egl.dpy != null);

    n: s32;
    major: s32;
    minor: s32;
    ret := eglInitialize(d.egl.dpy, *major, *minor);
    assert(ret == EGL_TRUE);
    print("Initialized EGL version %.%\n", major, minor);

    ret = eglBindAPI(EGL_OPENGL_API);
    assert(ret == EGL_TRUE);

    config_attribs : []s32 = .[
		EGL_SURFACE_TYPE, EGL_WINDOW_BIT,
		EGL_RED_SIZE, 1,
		EGL_GREEN_SIZE, 1,
		EGL_BLUE_SIZE, 1,
		EGL_ALPHA_SIZE, 1,
		EGL_RENDERABLE_TYPE, EGL_OPENGL_BIT,
		EGL_NONE
    ];
    ret = eglChooseConfig(d.egl.dpy, config_attribs.data, *d.egl.conf, 1, *n);
    assert(ret == EGL_TRUE && n == 1);

    context_attribs: []s32 = .[
		EGL_CONTEXT_MAJOR_VERSION, 4,
		EGL_CONTEXT_MINOR_VERSION, 6,
		EGL_NONE
    ];
    d.egl.ctx = eglCreateContext(d.egl.dpy, d.egl.conf, EGL_NO_CONTEXT, context_attribs.data);
    assert(d.egl.ctx != null);

    wls := d.compositor.create_surface(d.compositor);
    wln := wl_egl_window.create(wls, 1, 1);
    egs := eglCreateWindowSurface(d.egl.dpy, d.egl.conf, wln, null);
    ret = eglMakeCurrent(d.egl.dpy, egs, egs, d.egl.ctx);
    gl_load(*gl, eglGetProcAddress);
    eglDestroySurface(d.egl.dpy, egs);
    wl_egl_window.destroy(wln);
    wl_surface.destroy(wls);

    return true;
}

display_destroy :: (display: *Display) {
    eglMakeCurrent(display.egl.dpy, EGL_NO_SURFACE, EGL_NO_SURFACE, EGL_NO_CONTEXT);
    eglTerminate(display.egl.dpy);
    eglReleaseThread();

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

window_init :: (d: *Display, w: *Window, width: s32, height: s32, use_gl := true) -> bool {
    x_window_listener :: xdg_surface_listener.{
        configure = (data: *void, surface: *xdg_surface, serial: u32) -> void #c_call {
            w: *Window = data;
            xdg_surface.ack_configure(surface, serial);

            ctx: Context;
            push_context ctx {
                if !w.callback {
                    w.callback = wl_surface.frame(w.surface);
                    wl_callback.add_listener(w.callback, *frame_listener, w);
                    window_redraw(w, 0);
                }
            }

            wl_surface.commit(w.surface);
        }
    };

    x_toplevel_listener :: xdg_toplevel_listener.{
        configure = (data: *void, toplevel: *xdg_toplevel, width: s32, height: s32, states: *wl_array) -> void #c_call {
            w: *Window = data;
            w.gl.w = width;
            w.gl.h = height;
            wl_egl_window.resize(w.native, width, height, 0, 0);
        },
        close = (data: *void, toplevel: *xdg_toplevel) -> void #c_call {
            ctx: Context;
            push_context ctx {
                print("Close requested...\n");
                running = false;
            }
        }
    };

    decoration_listener :: zxdg_toplevel_decoration_v1_listener.{
        configure = (data: *void, decoration: *zxdg_toplevel_decoration_v1, mode: u32) -> void #c_call {
        }
    };

    frame_listener :: wl_callback_listener.{
        done = (data: *void, callback: *wl_callback, time: u32) -> void #c_call {
            w: *Window = data;

            if callback wl_callback.destroy(callback);
            w.callback = wl_surface.frame(w.surface);
            wl_callback.add_listener(w.callback, *frame_listener, w);

            if !w.initial_time w.initial_time = time;
            w.final_time = time;
            w.frames += 1;

            ctx: Context;
            push_context ctx {
                window_redraw(w, time);
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

    w.use_gl = use_gl;
    w.native = wl_egl_window.create(w.surface, width, height);
    w.egl_surface = eglCreateWindowSurface(d.egl.dpy, d.egl.conf, w.native, null);
    ret := eglMakeCurrent(d.egl.dpy, w.egl_surface, w.egl_surface, d.egl.ctx);
    assert(ret == EGL_TRUE);

    wl_surface.damage(w.surface, 0, 0, w.width, w.height);
    wl_surface.commit(w.surface);

    w.gl.program = compile_program(w);
    glGenVertexArrays(1, *w.gl.empty_vao);

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

vert_shader_text :: #string DONE
#version 460 core

const vec2 vertices[3] = vec2[3](
    vec2(-0.5, -0.5),
    vec2( 0.5, -0.5),
    vec2( 0,    0.5)
);

const vec4 colors[3] = vec4[3](
    vec4(1.0, 0.0, 0.0, 1.0),
    vec4(0.0, 1.0, 0.0, 1.0),
    vec4(0.0, 0.0, 1.0, 1.0)
);

uniform mat4 rotation;

out gl_PerVertex {
    vec4 gl_Position;
};
out vec4 v_color;

void main() {
    gl_Position = vec4(vertices[gl_VertexID], 0, 1) * rotation;
    v_color = colors[gl_VertexID];
}
DONE

frag_shader_text :: #string DONE
#version 460 core

in vec4 v_color;
out vec4 frag_color;
void main() {
    frag_color = v_color;
}
DONE

compile_shader :: (w: *Window, source: string, shader_type: u32) -> u32 {
	shader := glCreateShader(shader_type);
	assert(shader != 0);

	glShaderSource(shader, 1, *source.data, null);
	glCompileShader(shader);

    status: s32;
	glGetShaderiv(shader, GL_COMPILE_STATUS, *status);
	if (!status) {
		log_buff: [1024]u8;
		len: u32;
		glGetShaderInfoLog(shader, log_buff.count, *len, log_buff.data);
        log := to_string(log_buff.data, len);
        print("Error: compiling %: %\n",
			ifx shader_type == GL_VERTEX_SHADER then "vertex" else "fragment", log,
            to_standard_error = true);
		exit(1);
	}

	return shader;
}

compile_program :: (w: *Window) -> u32 {
    vert := compile_shader(w, vert_shader_text, GL_VERTEX_SHADER);
    frag := compile_shader(w, frag_shader_text, GL_FRAGMENT_SHADER);

    program := glCreateProgram();
    glAttachShader(program, frag);
    glAttachShader(program, vert);
    glLinkProgram(program);

    status: s32;
    log_buff: [1024]u8;
    len: u32;
    glGetProgramiv(program, GL_LINK_STATUS, *status);
    if !status {
        glGetProgramInfoLog(program, log_buff.count, *len, log_buff.data);
        log := to_string(log_buff.data, len);
        print("Shader link error: %\n", log);
        exit(1);
    }

    glUseProgram(program);
    w.gl.rotation_uniform = glGetUniformLocation(program, "rotation");

    return program;
}

window_redraw :: (w: *Window, time: u32) {
    if w.use_gl {
        eglMakeCurrent(w.display.egl.dpy, w.egl_surface, w.egl_surface, w.display.egl.ctx);
        defer eglSwapBuffers(w.display.egl.dpy, w.egl_surface);

        if !w.initial_time return;

        rotation: [16]float32 = .[
            1, 0, 0, 0,
            0, 1, 0, 0,
            0, 0, 1, 0,
            0, 0, 0, 1,
        ];

        speed_div : u32 : 5;
        angle := cast(float32) ((time / speed_div) % 360) * PI / 180.0;
        rotation[ 0] =  cos(angle);
        rotation[ 2] =  sin(angle);
        rotation[ 8] = -sin(angle);
        rotation[10] =  cos(angle);

        glViewport(0, 0, xx w.gl.w, xx w.gl.h);

        v := abs(1.0 - cast(float32)((time % 2001) / 1000.0));
        glClearColor(v, v, v, 0.9);
        glClear(GL_COLOR_BUFFER_BIT);

        glUseProgram(w.gl.program);
        glUniformMatrix4fv(w.gl.rotation_uniform, 1, GL_FALSE, rotation.data);
        glBindVertexArray(w.gl.empty_vao);
        glDrawArrays(GL_TRIANGLES, 0, 3);
    } else {
        b := window_next_buffer(w);
        assert(b != null);

        paint_pixels(b.shm_data, 0, w.width, w.height, time);
        wl_surface.attach(w.surface, b.buffer, 0, 0);
        wl_surface.damage(w.surface, 0, 0, w.width, w.height);
        wl_surface.commit(w.surface);
        b.busy = true;
    }
}

window_destroy :: (w: *Window) {
    eglMakeCurrent(w.display.egl.dpy, EGL_NO_SURFACE, EGL_NO_SURFACE, EGL_NO_CONTEXT);
    eglDestroySurface(w.display.egl.dpy, w.egl_surface);
    wl_egl_window.destroy(w.native);

    if w.callback wl_callback.destroy(w.callback);
    if w.buffers[0].buffer wl_buffer.destroy(w.buffers[0].buffer);
    if w.buffers[1].buffer wl_buffer.destroy(w.buffers[1].buffer);
    if w.decoration zxdg_toplevel_decoration_v1.destroy(w.decoration);
    if w.x_toplevel xdg_toplevel.destroy(w.x_toplevel);
    if w.x_surface xdg_surface.destroy(w.x_surface);
    if w.surface wl_surface.destroy(w.surface);
    memset(w, 0, size_of(Window));
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

window_list: [..]Window;
hovered_window: *Window;

main :: () {
    args := get_command_line_arguments();
    defer array_reset(*args);

    use_gl := false;
    window_count := 1;
    for args {
        if !it_index continue;
        if !starts_with(it, "-") break;
        arg := advance(it);
        if starts_with(arg, "count=") {
            s := advance(arg, 6);
            count, ok := string_to_int(s);
            if !ok {
                print("Invalid count: '%'\n", s);
                exit(1);
            }
            window_count = min(8, max(1, count));
        } else if arg == "gl" {
            use_gl = true;
        }
    }
    print("window_count = %, use_gl = %\n", window_count, use_gl);

    wl_global_init();

    d: Display;
    if !display_init(*d) {
        print("Could not create display.\n");
        exit(1);
    }
    defer display_destroy(*d);

    for 1..window_count {
        w := array_add(*window_list);

        if !window_init(*d, w, 800, 600, use_gl) {
            print("Could not create window.\n");
            exit(1);
        }

        print("WINDOW: %\n", <<w);
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
