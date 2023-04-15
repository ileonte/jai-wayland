WLDisplay :: struct {
    handle: *WL.wl_display;

    egl_dpy: EGL.EGLDisplay;
    egl_ctx: EGL.EGLContext;
    egl_cnf: EGL.EGLConfig;
}

WLWindow :: struct {
    handle: *WL.wl_surface;
    display: *WLDisplay;

    width: s32;
    height: s32;

    egl_native: *WL.wl_egl_window;
    egl_surface: EGL.EGLSurface;
}

wl_init_display :: (wd: *WLDisplay) -> bool {
    return false;
}
