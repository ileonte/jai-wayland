Saved_Window_Info :: struct {}

Display :: *_Display;
global_display : Display : *_global_display;

Window  :: *_Window;
INVALID_WINDOW : Window : null;

init_display :: () -> bool {
    if global_display.tag != X11Display && global_display.tag != WLDisplay {
        wd: WLDisplay;
        if wl_init_display(*wd) {
            set(global_display, wd);
            // @TODO: set global function pointers
            return true;
        }
        xd: X11Display;
        if x11_init_display(*xd) {
            set(global_display, xd);
            return true;
        }
    }
    return false;
}

/*
 * Window functions
 */
create_window :: (width: int, height: int, window_name: string, window_x := 0, window_y := 0, parent: Window = INVALID_WINDOW, background_color_rgb: [3]float) -> Window {
    if (!init_display()) return INVALID_WINDOW;
    if global_display.tag == {
        case X11Display; {
            if parent != INVALID_WINDOW assert(parent.tag == X11Window);
            xw := x11_create_window(
                isa(global_display, X11Display),
                width, height,
                window_name,
                window_x, window_y,
                ifx parent then isa(parent, X11Window) else null,
                background_color_rgb);
            if !xw.handle return INVALID_WINDOW;
            ret := array_add(*global_windows);
            set(ret, xw);
            return ret;
        }
        case WLDisplay; #through;
        case; return INVALID_WINDOW;
    }
}

toggle_fullscreen :: (win: Window, desire_fullscreen: bool, saved: *Saved_Window_Info) -> success: bool, width: s32, height: s32 {
    w, h: s32;
    s := false;
    if global_display.tag == {
        case X11Display; s, w, h = x11_toggle_fullscreen(isa(win, X11Window), desire_fullscreen, saved);
        case WLDisplay;
    }
    return s, w, h;
}

get_by_native_handle :: (native_handle: *void) -> Window {
    for * global_windows {
        if has_native_handle(it, native_handle) return it;
    }
    return INVALID_WINDOW;
}

has_native_handle :: (win: Window, native_handle: *void) -> bool {
    if !win return false;
    if win.tag == {
        case X11Window; return x11_has_native_handle(isa(win, X11Window), xx native_handle);
        case WLWindow; #through;
        case; return false;
    }
}

get_dimensions :: (win: Window, right_handed: bool) -> (x: s32, y: s32, width: s32, height: s32, success := true) {
    x, y, w, h: s32;
    ok := false;
    if win.tag == {
        case X11Window; x, y, w, h, ok = x11_get_dimensions(isa(win, X11Window), right_handed);
        case WLDisplay;
    }
    return x, y, w, h, ok;
}

get_mouse_pointer_position :: (display: Display, win: Window, right_handed: bool) -> x: int, y: int, success: bool {
    x, y: int;
    ok := false;
    if display.tag == {
        case X11Display; {
            assert(win.tag == X11Window);
            x, y, ok = x11_get_mouse_pointer_position(isa(display, X11Display), isa(win, X11Window), right_handed);
        }
        case WLDisplay;
    }
    return x, y, ok;
}

get_mouse_pointer_position :: (win: Window, right_handed: bool) -> x: int, y: int, success: bool {
    x, y: int;
    ok := false;
    if global_display.tag == {
        case X11Display; {
            assert(win.tag == X11Window);
            x, y, ok = x11_get_mouse_pointer_position(isa(win, X11Window), right_handed);
        }
        case WLDisplay;
    }
    return x, y, ok;
}

get_mouse_pointer_position :: (right_handed := false) -> x: int, y: int, success: bool {
    x, y: int;
    ok := false;
    if global_display.tag == {
        case X11Display; x, y, ok = x11_get_mouse_pointer_position(right_handed);
        case WLDisplay;
    }
    return x, y, ok;
}

/*
 * Input functions
 */
translate_key_code :: (display: Display, key: u64) -> Key_Code {
    if display.tag == {
        case X11Display; return x11_translate_key_code(key);
        case WLDisplay;
    }
    return .UNKNOWN;
}

translate_key_code :: (key: u64) -> Key_Code {
    return translate_key_code(global_display, key);
}

update_window_events :: () {
    if global_display.tag == {
        case X11Display; x11_update_window_events(isa(global_display, X11Display));
        case WLDisplay;
    }
}

#scope_module;

X11 :: #import "X11";
EGL :: #import "EGL";
WL  :: #import "Wayland";
#import "Input";
#import "Tagged_Union";
#import "Basic";

#load "ldx_display.jai";
#load "ldx_input.jai";
#load "ldw_display.jai";
#load "ldw_input.jai";
#load "ld_gl.jai";

_Display        :: Tagged_Union(X11Display, WLDisplay);
_Window         :: Tagged_Union(X11Window, WLWindow);
_INVALID_WINDOW : Window;

_global_display: _Display;
global_windows: [..] _Window;
