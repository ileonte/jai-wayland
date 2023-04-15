X11Display :: struct {
    handle: *X11.Display;

    glx_ctx: X11.GLXContext;
    glx_cnf: X11.GLXFBConfig;
}

X11Window :: struct {
    handle: X11.Window;
    display: *X11Display;

    glx_win: X11.GLXWindow;
}

x11_init_display :: (xd: *X11Display) -> bool {
    X11.init_global_display();
    xd.handle = X11.x_global_display;
    return ifx xd.handle then true else false;
}

x11_toggle_fullscreen :: (x11_win: *X11Window, desire_fullscreen: bool, saved: *Saved_Window_Info) ->
    success: bool, width: s32, height: s32
{
    win := x11_win.handle;
    display := x11_win.display.handle;

    if desire_fullscreen {
        if X11.x_global_net_wm_state && X11.x_global_net_wm_state_fullscreen {
            xev: X11.XEvent;
            xev.type = X11.ClientMessage;
            xev.xclient.window = win;
            xev.xclient.message_type = X11.x_global_net_wm_state;
            xev.xclient.format = 32;
            xev.xclient.data.l[0] = X11._NET_WM_STATE_ADD;
            xev.xclient.data.l[1] = cast(s64) X11.x_global_net_wm_state_fullscreen;

            X11.XSendEvent(display, X11.DefaultRootWindow(display), X11.False,
                X11.SubstructureRedirectMask | X11.SubstructureNotifyMask, *xev);
            X11.XSync(display, X11.False);

            width: u32;
            height: u32;

            // for what ever stupid reason, XGetGeometry crashes if you pass null in for any of its return parameters
            root: X11.Window;
            x, y: s32;
            border_width: u32;
            depth_return: u32;
            // this will return the window's current dimensions, but it seems the server will imediately send a
            // ConfigureNotify event with the new size of the fullscreen window
            X11.XGetGeometry(display, win, *root, *x, *y, *width, *height, *border_width, *depth_return);
            return true, cast(s32) width, cast(s32) height;
        } else {
            // :NoNET_WM_STATE_FULLSCREEN:
            // @TODO typically the window manager should support NET_WM_STATE and NET_WM_STATE_FULLSCREEN
            // however, in the event that it does not, we're supposed to change the window's attributes
            // to enable override_redirect. However, apparently in doing so, this causes the window manager
            // to ignore the window (the window, in essense, is considered as acting as a temporary window manager
            // accoring to the ICCM) requiring more work on our part. The ICCM strongly discourages doing this,
            // but this is the only other way to take control of the screen AFAICT. -josh
            return false, 0, 0;
        }
    } else {
        if X11.x_global_net_wm_state && X11.x_global_net_wm_state_fullscreen {
            xev: X11.XEvent;
            xev.type = X11.ClientMessage;
            xev.xclient.window = win;
            xev.xclient.message_type = X11.x_global_net_wm_state;
            xev.xclient.format = 32;
            xev.xclient.data.l[0] = X11._NET_WM_STATE_REMOVE;
            xev.xclient.data.l[1] = cast(s64) X11.x_global_net_wm_state_fullscreen;

            X11.XSendEvent(display, X11.DefaultRootWindow(display), X11.False,
                X11.SubstructureRedirectMask | X11.SubstructureNotifyMask, *xev);

            width: u32;
            height: u32;

            // for what ever stupid reason, XGetGeometry crashes if you pass null in for any of its return parameters
            root: X11.Window;
            x, y: s32;
            border_width: u32;
            depth_return: u32;
            X11.XGetGeometry(display, win, *root, *x, *y, *width, *height, *border_width, *depth_return);
            return true, cast(s32) width, cast(s32) height;
        } else {
            // :NoNET_WM_STATE_FULLSCREEN:
            return false, 0, 0;
        }
    }
}

x11_create_window :: (x11_display: *X11Display, width: int, height: int, window_name: string, window_x: int, window_y: int, x11_parent: *X11Window, background_color_rgb: [3]float) -> X11Window {
    d := x11_display.handle;

    X11.XLockDisplay(d);
    root := X11.DefaultRootWindow(d);
    parent := ifx x11_parent then x11_parent.handle else root;

    // These attributes must match the attibutes we use to create the GL context. :GlContextAttributes
    //        -rluba, 2021-11-30
    attr := s32.[
        X11.GLX_RGBA,
        X11.GLX_DEPTH_SIZE, 24,
        X11.GLX_DOUBLEBUFFER,
        X11.GLX_RED_SIZE, 8,
        X11.GLX_GREEN_SIZE, 8,
        X11.GLX_BLUE_SIZE, 8,
        X11.GLX_STENCIL_SIZE, 8,
        X11.None
    ];
    vi := X11.glXChooseVisual(d, 0, attr.data);
    cmap := X11.XCreateColormap(d, parent, vi.visual, X11.AllocNone);

    background_color: X11.XColor;
    background_color.flags |= X11.DoRed | X11.DoGreen | X11.DoBlue;
    background_color.red     = to_u16(background_color_rgb[0]);
    background_color.green   = to_u16(background_color_rgb[1]);
    background_color.blue    = to_u16(background_color_rgb[2]);
    X11.XAllocColor(d, cmap, *background_color);

    swa: X11.XSetWindowAttributes;
    swa.colormap = cmap;
    swa.event_mask =
        X11.ExposureMask |
        X11.KeyPressMask |
        X11.KeyReleaseMask |
        X11.ButtonPressMask |
        X11.ButtonReleaseMask |
        X11.StructureNotifyMask |
        X11.FocusChangeMask |
        X11.EnterWindowMask |
        X11.LeaveWindowMask |
        X11.PointerMotionHintMask |
        X11.PointerMotionMask;
    swa.background_pixel = background_color.pixel;
    win := X11.XCreateWindow(d, parent,
        xx window_x, xx window_y, xx width, xx height,
        0,
        vi.depth,
        X11.InputOutput, vi.visual,
        cast(u64) (X11.CWColormap | X11.CWEventMask),
        *swa);

    to_u16 :: (f: float) -> u16 {
        u := cast(s32)(f * 65535);
        if u < 0      u = 0;
        if u > 65535  u = 65535;

        return cast(u16) u;
    }

    win_name := temp_c_string(window_name);
    if window_name then X11.XStoreName(d, win, win_name);

    class_hints := X11.XAllocClassHint();
    if class_hints {
        // this changes the application name for now (not the window title)
        // unset, gnome3 will just display "Unknown" in the activity bar and the dock
        if window_name {
            class_hints.res_name = win_name;
            class_hints.res_class = win_name;
        } else {
            class_hints.res_name = "jai-application";
            class_hints.res_class = "JAI-Application";
        }
        X11.XSetClassHint(d, win, class_hints);
    }

    X11.XMapWindow(d, win);

    X11.XSetWMProtocols(d, win, *X11.x_global_wm_delete_window, 1);

    array_add(*X11.x_global_windows, win);

    X11.XUnlockDisplay(d);
    return .{
        handle = win,
        display = x11_display,
    };
}

x11_has_native_handle :: (win: *X11Window, native_handle: X11.Window) -> bool {
    return win.handle == native_handle;
}

x11_get_dimensions :: (win: *X11Window, right_handed: bool) -> (x: s32, y: s32, width: s32, height: s32, success := true) {
    xwa: X11.XWindowAttributes;
    X11.XGetWindowAttributes(win.display.handle, win.handle, *xwa);

    y := ifx right_handed then xwa.y+xwa.height else xwa.y;
    return xwa.x, y, xwa.width, xwa.height;
}

x11_get_mouse_pointer_position :: (dpy: *X11Display, win: *X11Window, right_handed: bool) -> x: int, y: int, success: bool {
    root_x, root_y: s32;
    win_x, win_y: s32;
    root, child: X11.Window;
    modifier_mask: u32;

    // @TODO XQueryPointer is a round trip to the X server, which means this could be very slow.
    // It may be more desirable to update a global mouse state by capturing mouse events in X11_Input.jai:update_x11_window_events()
    ok := X11.XQueryPointer(dpy.handle, win.handle, *root, *child, *root_x, *root_y, *win_x, *win_y, *modifier_mask);

    if right_handed {
        xwa: X11.XWindowAttributes;
        X11.XGetWindowAttributes(dpy.handle, win.handle, *xwa);
        win_y = xwa.height - win_y;
    }
    return win_x, win_y, ok == X11.True;
}

x11_get_mouse_pointer_position :: (win: *X11Window, right_handed: bool) -> x: int, y: int, success: bool {
    dpy := isa(global_display, X11Display);
    assert(dpy != null);
    x, y, success := x11_get_mouse_pointer_position(dpy, win, right_handed);
    return x, y, success;
}

x11_get_mouse_pointer_position :: (right_handed := false) -> x: int, y: int, success: bool {
    dpy := isa(global_display, X11Display);
    assert(dpy != null);

    hwnd: X11.Window;
    revert: s32;
    X11.XGetInputFocus(dpy.handle, *hwnd, *revert);
    win := get_by_native_handle(xx hwnd);
    if !win || !isa(win, X11Window) return 0, 0, false;

    x, y, success := x11_get_mouse_pointer_position(dpy, isa(win, X11Window), right_handed);
    return x, y, success;
}
