get_gl_context :: (display: Display) -> *void {
    if display.tag == {
        case X11Display; return isa(display, X11Display).glx_ctx;
        case WLDisplay; return isa(display, WLDisplay).egl_ctx;
        case; return null;
    }
}

get_gl_context :: inline () -> *void {
    return get_gl_context(global_display);
}

get_gl_proc_address_function :: (display: Display) -> GL.GetProcAddressFunction {
    if display.tag == {
        case X11Display; return X11.glXGetProcAddress;
        case WLDisplay; return EGL.eglGetProcAddress;
        case; return null;
    }
}

get_gl_proc_address_function :: inline () -> GL.GetProcAddressFunction {
    return get_proc_address_function(global_display);
}

get_gl_proc_address_function :: (win: Window) -> GL.GetProcAddressFunction {
    if win.tag == {
        case X11Window; return X11.glXGetProcAddress;
        case WLWindow; return EGL.eglGetProcAddress;
        case; return null;
    }
}

create_gl_context :: (display: Display, major_version := 0, minor_version := 0, compatibility := false, debug := false) {
    if display.tag == {
        case X11Display; {
            xd := isa(display, X11Display);
            xd.glx_ctx, xd.glx_cnf = GL.glx_create_context(xx major_version, xx minor_version, compatibility, debug);
        }
        case WLDisplay; {
            wld := isa(display, WLDisplay);
            wld.egl_dpy, wld.egl_ctx, wld.egl_cnf = egl_create_context(
                wld.handle, major_version, minor_version, compatibility, debug);
        }
    }
}

create_gl_context :: inline (major_version := 0, minor_version := 0, compatibility := false, debug := false) {
    create_gl_context(global_display, major_version, minor_version, compatibility, debug);
}

create_gl_surface :: (win: Window) {
    if win.tag == {
        case X11Window; {
            w := isa(win, X11Window);
            w.glx_win = X11.glXCreateWindow(w.display.handle, w.display.glx_cnf, w.handle, null);
        }
        case WLWindow; {
            w := isa(win, WLWindow);
            w.egl_native = WL.wl_egl_window.create(w.handle, w.width, w.height);
            w.egl_surface = EGL.eglCreateWindowSurface(w.display.egl_dpy, w.display.egl_cnf, w.egl_native, null);
        }
    }
}

make_current :: (win: Window) {
    if win.tag == {
        case X11Window; {
            w := isa(win, X11Window);
            X11.XLockDisplay(w.display.handle);
            if !X11.glXMakeCurrent(w.display.handle, w.glx_win, w.display.glx_ctx)
                log_error("glxMakeCurrent failed! (glx_window %, context %)\n", w.glx_win, w.display.glx_ctx);
            X11.XUnlockDisplay(w.display.handle);
        }
        case WLWindow; {
            w := isa(win, WLWindow);
            EGL.eglMakeCurrent(w.display.egl_dpy, w.egl_surface, w.egl_surface, w.display.egl_ctx);
        }
    }
}

swap_buffers :: (win: Window) {
    if win.tag == {
        case X11Window; {
            w := isa(win, X11Window);
            X11.glXSwapBuffers(w.display.handle, w.glx_win);
        }
        case WLWindow; {
            w := isa(win, WLWindow);
            EGL.eglSwapBuffers(w.display.egl_dpy, w.egl_surface);
        }
    }
}

#scope_file
GL :: #import "GL";

egl_create_context :: (native_display: EGL.EGLNativeDisplayType, major_version := 0, minor_version := 0,
    compatibility := false, debug := false) -> EGL.EGLDisplay, EGL.EGLContext, EGL.EGLConfig
{
    n: s32;
    major: s32;
    minor: s32;

    egl_dpy := EGL.eglGetDisplay(native_display);
    EGL.eglInitialize(egl_dpy, *major, *minor);
    EGL.eglBindAPI(EGL.EGL_OPENGL_API);

    config_attribs : []s32 = .[
        EGL.EGL_SURFACE_TYPE, EGL.EGL_WINDOW_BIT,
        EGL.EGL_RED_SIZE, 8,
        EGL.EGL_GREEN_SIZE, 8,
        EGL.EGL_BLUE_SIZE, 8,
        EGL.EGL_ALPHA_SIZE, 8,
        EGL.EGL_RENDERABLE_TYPE, EGL.EGL_OPENGL_BIT,
        EGL.EGL_NONE
    ];
    egl_cnf: EGL.EGLConfig;
    EGL.eglChooseConfig(egl_dpy, config_attribs.data, *egl_cnf, 1, *n);

    context_attribs: [9]s32;
    attr_count := 0;

    if major_version > 0 {
        context_attribs[attr_count + 0] = EGL.EGL_CONTEXT_MAJOR_VERSION;
        context_attribs[attr_count + 1] = xx major_version;
        context_attribs[attr_count + 2] = EGL.EGL_CONTEXT_MINOR_VERSION;
        context_attribs[attr_count + 3] = xx minor_version;
        attr_count += 4;
    }

    context_attribs[attr_count + 0] = EGL.EGL_CONTEXT_OPENGL_PROFILE_MASK;
    if compatibility  context_attribs[attr_count + 1] = EGL.EGL_CONTEXT_OPENGL_COMPATIBILITY_PROFILE_BIT;
    else              context_attribs[attr_count + 1] = EGL.EGL_CONTEXT_OPENGL_CORE_PROFILE_BIT;
    attr_count += 2;

    if debug {
        context_attribs[attr_count + 0] = EGL.EGL_CONTEXT_OPENGL_DEBUG;
        context_attribs[attr_count + 1] = EGL.EGL_TRUE;
        attr_count += 2;
    }

    context_attribs[attr_count] = EGL.EGL_NONE;

    egl_ctx := EGL.eglCreateContext(egl_dpy, egl_cnf, EGL.EGL_NO_CONTEXT, context_attribs.data);

    return egl_dpy, egl_ctx, egl_cnf;
}
