libxkb :: #system_library "libxkbcommon";

xkb_context :: struct {}
xkb_keymap  :: struct {}
xkb_state   :: struct {}
xkb_keycode_t :: u32;
xkb_keysym_t  :: u32;
xkb_mod_mask_t :: u32;
xkb_mod_index_t :: u32;
xkb_layout_index_t :: u32;
xkb_state_component :: enum {
    XKB_STATE_MODS_DEPRESSED :: (1 << 0);
    XKB_STATE_MODS_LATCHED :: (1 << 1);
    XKB_STATE_MODS_LOCKED :: (1 << 2);
    XKB_STATE_MODS_EFFECTIVE :: (1 << 3);
    XKB_STATE_LAYOUT_DEPRESSED :: (1 << 4);
    XKB_STATE_LAYOUT_LATCHED :: (1 << 5);
    XKB_STATE_LAYOUT_LOCKED :: (1 << 6);
    XKB_STATE_LAYOUT_EFFECTIVE :: (1 << 7);
    XKB_STATE_LEDS :: (1 << 8);
}

XKB_MOD_NAME_SHIFT   :: "Shift";
XKB_MOD_NAME_CAPS    :: "Lock";
XKB_MOD_NAME_CTRL    :: "Control";
XKB_MOD_NAME_ALT     :: "Mod1";
XKB_MOD_NAME_NUM     :: "Mod2";
XKB_MOD_NAME_LOGO    :: "Mod4";
XKB_MOD_NAME_ALT_GR  :: "Mod5";  // not part of XKB

xkb_keysym_flags :: enum {
    XKB_KEYSYM_NO_FLAGS :: 0;
    XKB_KEYSYM_CASE_INSINSITIVE :: 1;
}

xkb_keysym_get_name :: (keysym: xkb_keysym_t, buffer: *u8, size: u64) -> s32 #foreign libxkb;
xkb_keysym_from_name :: (name: *u8, flags: xkb_keysym_flags) -> xkb_keysym_t #foreign libxkb;

xkb_keysym_to_utf8 :: (keysym: xkb_keysym_t, buffer: *u8, size: u64) -> s32 #foreign libxkb;
xkb_keysym_to_utf32 :: (keysym: xkb_keysym_t) -> u32 #foreign libxkb;

xkb_keysym_to_upper :: (keysym: xkb_keysym_t) -> xkb_keysym_t #foreign libxkb;
xkb_keysym_to_lower :: (keysym: xkb_keysym_t) -> xkb_keysym_t #foreign libxkb;

xkb_context_flags :: enum {
    XKB_CONTEXT_NO_FLAGS :: 0;
    XKB_CONTEXT_NO_DEFAULT_INCLUDES :: (1 << 0);
    XKB_CONTEXT_NO_ENVIRONMENT_NAMES :: (1 << 1);
    XKB_CONTEXT_NO_SECURE_GETENV :: (1 << 2);
}

xkb_context_new :: (flags: xkb_context_flags) -> *xkb_context #foreign libxkb;
xkb_context_ref :: (ctx: *xkb_context) -> *xkb_context #foreign libxkb;
xkb_context_unref :: (ctx: *xkb_context) #foreign libxkb;
xkb_context_set_user_data :: (ctx: *xkb_context, data: *void) #foreign libxkb;
xkb_context_get_user_data :: (ctx: *xkb_context) -> *void #foreign libxkb;

xkb_keymap_compile_flags :: enum {
    XKB_KEYMAP_COMPILE_NO_FLAGS :: 0;
}

xkb_keymap_format :: enum {
    XKB_KEYMAP_FORMAT_TEXT_V1 :: 1;
}

xkb_keymap_new_from_string :: (ctx: *xkb_context, string: *u8, format: xkb_keymap_format, flags: xkb_keymap_compile_flags) -> *xkb_keymap #foreign libxkb;
xkb_keymap_ref :: (keymap: *xkb_keymap) -> *xkb_keymap #foreign libxkb;
xkb_keymap_unref :: (keymap: *xkb_keymap) #foreign libxkb;
xkb_keymap_mod_get_index :: (keymap: *xkb_keymap, name: *u8) -> xkb_mod_index_t #foreign libxkb;

xkb_state_new :: (keymap: *xkb_keymap) -> *xkb_state #foreign libxkb;
xkb_state_ref :: (state: *xkb_state) -> *xkb_state #foreign libxkb;
xkb_state_unref :: (state: *xkb_state) #foreign libxkb;
xkb_state_key_get_one_sym :: (state: *xkb_state, key: xkb_keycode_t) -> xkb_keysym_t #foreign libxkb;
xkb_state_key_get_utf8 :: (state: *xkb_state, key: xkb_keycode_t, buffer: *u8, size: u64) -> s32 #foreign libxkb;
xkb_state_key_get_utf32 :: (state: *xkb_state, key: xkb_keycode_t) -> u32 #foreign libxkb;
xkb_state_update_mask :: (
    state: *xkb_state,
    depressed_mods: xkb_mod_mask_t,
    latched_mods: xkb_mod_mask_t,
    locked_mods: xkb_mod_mask_t,
    depressed_layout: xkb_layout_index_t,
    latched_layout: xkb_layout_index_t,
    locked_layout: xkb_layout_index_t) -> xkb_state_component #foreign libxkb;
xkb_state_mod_index_is_active :: (state: *xkb_state, idx: xkb_mod_index_t, type: xkb_state_component) -> s32 #foreign libxkb;

MOD_SHIFT     : u32 : 1;
MOD_CAPS_LOCK : u32 : 2;
MOD_CTRL      : u32 : 4;
MOD_ALT       : u32 : 8;
MOD_ALT_GR    : u32 : 128;

keyboard_listenter :: wl_keyboard_listener.{
    keymap = (data: *void, self: *wl_keyboard, format: u32, fd: s32, size: u32) -> void #c_call {
        ctx: Context;
        push_context ctx {
            if format == wl_keyboard.keymap_format_xkb_v1 {
                keymap := mmap(null, size, PROT_READ, MAP_PRIVATE, fd, 0);
                defer munmap(keymap, size);

                d : *WLDisplay = wl_proxy.get_user_data(self);
                d.kb_context = xkb_context_new(.XKB_CONTEXT_NO_FLAGS);
                d.kb_keymap = xkb_keymap_new_from_string(d.kb_context, keymap,
                    .XKB_KEYMAP_FORMAT_TEXT_V1, .XKB_KEYMAP_COMPILE_NO_FLAGS);
                d.kb_state = xkb_state_new(d.kb_keymap);

                d.mod_idx_shift     = xkb_keymap_mod_get_index(d.kb_keymap, XKB_MOD_NAME_SHIFT.data);
                d.mod_idx_ctrl      = xkb_keymap_mod_get_index(d.kb_keymap, XKB_MOD_NAME_CTRL.data);
                d.mod_idx_alt       = xkb_keymap_mod_get_index(d.kb_keymap, XKB_MOD_NAME_ALT.data);
                d.mod_idx_caps_lock = xkb_keymap_mod_get_index(d.kb_keymap, XKB_MOD_NAME_CAPS.data);
                d.mod_idx_super     = xkb_keymap_mod_get_index(d.kb_keymap, XKB_MOD_NAME_LOGO.data);
                d.mod_idx_alt_gr    = xkb_keymap_mod_get_index(d.kb_keymap, XKB_MOD_NAME_ALT_GR.data);
            } else {
                log_error("Received unsupported keymap from compositor!\n");
                assert(false);
            }
        }
    },

    key = (data: *void, self: *wl_keyboard, serial: u32, time: u32, key: u32, state: u32) -> void #c_call {
        ctx: Context;
        push_context ctx {
            d : *WLDisplay = wl_proxy.get_user_data(self);
            if !d.kb_state return;

            buf: [16]u8;
            keycode: xkb_keycode_t = key + 8;
            keysym := xkb_state_key_get_one_sym(d.kb_state, keycode);
            utf32  := xkb_state_key_get_utf32(d.kb_state, keycode);

            event: Event;
            event.type = .KEYBOARD;
            event.key_code = x11_translate_key_code(keysym);
            event.shift_pressed = xkb_state_mod_index_is_active(d.kb_state, d.mod_idx_shift, .XKB_STATE_MODS_DEPRESSED) == 1;
            event.ctrl_pressed  = xkb_state_mod_index_is_active(d.kb_state, d.mod_idx_ctrl, .XKB_STATE_MODS_DEPRESSED) == 1;
            event.alt_pressed   = xkb_state_mod_index_is_active(d.kb_state, d.mod_idx_alt, .XKB_STATE_MODS_DEPRESSED) == 1;

            if state == wl_keyboard.key_state_pressed {
                event.key_pressed = 1;
                input_button_states[event.key_code] = (Key_Current_State.START | Key_Current_State.DOWN);
            } else {
                event.key_pressed = 0;
                input_button_states[event.key_code] = Key_Current_State.END;
            }

            array_add(*events_this_frame, event);

            if event.key_pressed && (keysym < XK_BackSpace || keysym > XK_Hyper_R ) && !event.ctrl_pressed && utf32 {
                char_event: Event;
                char_event.type = .TEXT_INPUT;
                char_event.utf32 = utf32;
                array_add(*events_this_frame, char_event);
            }
        }
    },

    modifiers = (data: *void, self: *wl_keyboard, serial: u32,
        mods_depressed: u32, mods_latched: u32, mods_locked: u32, group: u32) -> void #c_call
    {
        d : *WLDisplay = wl_proxy.get_user_data(self);
        xkb_state_update_mask(
            d.kb_state,
            mods_depressed, mods_latched, mods_locked,
            group, group, group);
    }
};

/* These are taken from <linux/input-event-codes.h> */
BTN_LEFT   : u32 : 0x110;
BTN_RIGHT  : u32 : 0x111;
BTN_MIDDLE : u32 : 0x112;

pointer_listener :: wl_pointer_listener.{
    enter = (data: *void, self: *wl_pointer, serial: u32, surface: *wl_surface,
        surface_x: wl_fixed_t, surface_y: wl_fixed_t) -> void #c_call
    {
        current_hovered_window = wl_surface.get_user_data(surface);
    },

    motion = (data: *void, self: *wl_pointer, time: u32, fx: wl_fixed_t, fy: wl_fixed_t) -> void #c_call {
        if current_hovered_window != null {
            current_hovered_window.mouse_x = wl_fixed_to_int(fx);
            current_hovered_window.mouse_y = wl_fixed_to_int(fy);
        }
    },

    button = (data: *void, self: *wl_pointer, serial: u32, time: u32, button: u32, state: u32) -> void #c_call {
        event: Event;
        event.type = .KEYBOARD;
        if button == {
            case BTN_LEFT;   event.key_code = .MOUSE_BUTTON_LEFT;
            case BTN_MIDDLE; event.key_code = .MOUSE_BUTTON_MIDDLE;
            case BTN_RIGHT;  event.key_code = .MOUSE_BUTTON_RIGHT;
        }
        if state == wl_pointer.button_state_pressed {
            event.key_pressed = 1;
            input_button_states[event.key_code] = (Key_Current_State.START | Key_Current_State.DOWN);
        } else {
            event.key_pressed = 0;
            input_button_states[event.key_code] = Key_Current_State.END;
        }

        ctx: Context;
        push_context ctx {
            array_add(*events_this_frame, event);
        }
    }
};

wl_update_window_events :: (display: *WLDisplay) {
    wl_display.dispatch(display.handle);
}

wl_get_mouse_pointer_position :: (win: *WLWindow, right_handed: bool) -> x: int, y: int, success: bool {
    if right_handed {
        return win.mouse_x, win.height - win.mouse_y, true;
    }
    return win.mouse_x, win.mouse_y, true;
}

wl_get_mouse_pointer_position :: (right_handed: bool) -> x: int, y: int, success: bool {
    if current_hovered_window return wl_get_mouse_pointer_position(current_hovered_window, right_handed);
    return 0, 0, false;
}

#scope_file
#import "POSIX";

current_hovered_window: *WLWindow;
