/*
 * Auto-generated by `wayland-scanner` version 1.0.1
 * Protocol: surface_extension
 */

qt_surface_extension_interface: wl_interface;
qt_surface_extension :: struct {
    #as _proxy: wl_proxy;
    _interface_ :: *qt_surface_extension_interface;

    set_user_data :: inline (self: *qt_surface_extension, user_data: *void) #c_call {
        wl_proxy.set_user_data(self, user_data);
    }

    get_user_data :: inline (self: *qt_surface_extension) -> *void #c_call {
        return wl_proxy.get_user_data(self);
    }

    get_version :: inline (self: *qt_surface_extension) -> u32 #c_call {
        return wl_proxy.get_version(self);
    }

    destroy :: inline (self: *qt_surface_extension) #c_call {
        wl_proxy.destroy(self);
    }

    get_extended_surface :: inline (self: *qt_surface_extension, surface: *wl_surface) -> *qt_extended_surface #c_call {
        ret: *wl_proxy = wl_proxy.marshal_flags(
            self, QT_SURFACE_EXTENSION_GET_EXTENDED_SURFACE,
            *qt_extended_surface_interface, wl_proxy.get_version(self), 0,
            null, surface);
        return cast(*qt_extended_surface) ret;
    }
}

QT_SURFACE_EXTENSION_GET_EXTENDED_SURFACE       : u32 : 0;
QT_SURFACE_EXTENSION_GET_EXTENDED_SURFACE_SINCE : u32 : 1;

qt_extended_surface_interface: wl_interface;
qt_extended_surface :: struct {
    #as _proxy: wl_proxy;
    _interface_ :: *qt_extended_surface_interface;

    /* ENUM: qt_extended_surface::orientation */
    orientation_PrimaryOrientation           : u32 : 0;
    orientation_PortraitOrientation          : u32 : 1;
    orientation_LandscapeOrientation         : u32 : 2;
    orientation_InvertedPortraitOrientation  : u32 : 4;
    orientation_InvertedLandscapeOrientation : u32 : 8;

    /* ENUM: qt_extended_surface::windowflag */
    windowflag_OverridesSystemGestures : u32 : 1;
    windowflag_StaysOnTop              : u32 : 2;
    windowflag_BypassWindowManager     : u32 : 4;

    set_user_data :: inline (self: *qt_extended_surface, user_data: *void) #c_call {
        wl_proxy.set_user_data(self, user_data);
    }

    get_user_data :: inline (self: *qt_extended_surface) -> *void #c_call {
        return wl_proxy.get_user_data(self);
    }

    get_version :: inline (self: *qt_extended_surface) -> u32 #c_call {
        return wl_proxy.get_version(self);
    }

    destroy :: inline (self: *qt_extended_surface) #c_call {
        wl_proxy.destroy(self);
    }

    update_generic_property :: inline (self: *qt_extended_surface, name: *u8, value: *wl_array) #c_call {
        wl_proxy.marshal_flags(
            self, QT_EXTENDED_SURFACE_UPDATE_GENERIC_PROPERTY,
            null, wl_proxy.get_version(self), 0,
            name, value);
    }

    set_content_orientation_mask :: inline (self: *qt_extended_surface, orientation: s32) #c_call {
        wl_proxy.marshal_flags(
            self, QT_EXTENDED_SURFACE_SET_CONTENT_ORIENTATION_MASK,
            null, wl_proxy.get_version(self), 0,
            orientation);
    }

    set_window_flags :: inline (self: *qt_extended_surface, flags: s32) #c_call {
        wl_proxy.marshal_flags(
            self, QT_EXTENDED_SURFACE_SET_WINDOW_FLAGS,
            null, wl_proxy.get_version(self), 0,
            flags);
    }

    raise :: inline (self: *qt_extended_surface) #c_call {
        wl_proxy.marshal_flags(
            self, QT_EXTENDED_SURFACE_RAISE,
            null, wl_proxy.get_version(self), 0);
    }

    lower :: inline (self: *qt_extended_surface) #c_call {
        wl_proxy.marshal_flags(
            self, QT_EXTENDED_SURFACE_LOWER,
            null, wl_proxy.get_version(self), 0);
    }

    add_listener :: inline (self: *qt_extended_surface, listener: *qt_extended_surface_listener, data: *void) -> s32 #c_call {
        return wl_proxy.add_listener(self, cast(*generic_c_call) listener, data);
    }
}

QT_EXTENDED_SURFACE_UPDATE_GENERIC_PROPERTY            : u32 : 0;
QT_EXTENDED_SURFACE_SET_CONTENT_ORIENTATION_MASK       : u32 : 1;
QT_EXTENDED_SURFACE_SET_WINDOW_FLAGS                   : u32 : 2;
QT_EXTENDED_SURFACE_RAISE                              : u32 : 3;
QT_EXTENDED_SURFACE_LOWER                              : u32 : 4;
QT_EXTENDED_SURFACE_UPDATE_GENERIC_PROPERTY_SINCE      : u32 : 1;
QT_EXTENDED_SURFACE_SET_CONTENT_ORIENTATION_MASK_SINCE : u32 : 1;
QT_EXTENDED_SURFACE_SET_WINDOW_FLAGS_SINCE             : u32 : 1;
QT_EXTENDED_SURFACE_RAISE_SINCE                        : u32 : 1;
QT_EXTENDED_SURFACE_LOWER_SINCE                        : u32 : 1;
QT_EXTENDED_SURFACE_ONSCREEN_VISIBILITY_SINCE          : u32 : 1;
QT_EXTENDED_SURFACE_SET_GENERIC_PROPERTY_SINCE         : u32 : 1;
QT_EXTENDED_SURFACE_CLOSE_SINCE                        : u32 : 1;

qt_extended_surface_listener :: struct {
    onscreen_visibility  := _stubs_.onscreen_visibility;
    set_generic_property := _stubs_.set_generic_property;
    close                := _stubs_.close;

    _stubs_ :: struct {
        onscreen_visibility :: (data: *void,
            self: *qt_extended_surface,
            visible: s32) -> void #c_call {}
        set_generic_property :: (data: *void,
            self: *qt_extended_surface,
            name: *u8,
            value: *wl_array) -> void #c_call {}
        close :: (data: *void,
            self: *qt_extended_surface) -> void #c_call {}
    }
}


#scope_module
surface_extension_protocol_init :: () {
    surface_extension_types_storage = .[
        /* __DUMMY__ */
        null,  // 0
        /* REQUEST: qt_surface_extension::get_extended_surface */
        *qt_extended_surface_interface,   // 1
        *wl_surface_interface,   // 2
        /* REQUEST: qt_extended_surface::update_generic_property */
        null,  // 3
        null,  // 4
        /* REQUEST: qt_extended_surface::set_content_orientation_mask */
        null,  // 5
        /* REQUEST: qt_extended_surface::set_window_flags */
        null,  // 6
        /* EVENT: qt_extended_surface::onscreen_visibility */
        null,  // 7
        /* EVENT: qt_extended_surface::set_generic_property */
        null,  // 8
        null,  // 9
    ];

    qt_surface_extension_requests[0] = .{"get_extended_surface", "no", surface_extension_types_storage.data + 1};
    qt_surface_extension_interface = .{
        "qt_surface_extension", 1,
        qt_surface_extension_requests.count, qt_surface_extension_requests.data,
        0, null,
    };

    qt_extended_surface_requests[0] = .{"update_generic_property", "sa", surface_extension_types_storage.data + 3};
    qt_extended_surface_requests[1] = .{"set_content_orientation_mask", "i", surface_extension_types_storage.data + 5};
    qt_extended_surface_requests[2] = .{"set_window_flags", "i", surface_extension_types_storage.data + 6};
    qt_extended_surface_requests[3] = .{"raise", "", surface_extension_types_storage.data + 0};
    qt_extended_surface_requests[4] = .{"lower", "", surface_extension_types_storage.data + 0};
    qt_extended_surface_events[0] = .{"onscreen_visibility", "i", surface_extension_types_storage.data + 7};
    qt_extended_surface_events[1] = .{"set_generic_property", "sa", surface_extension_types_storage.data + 8};
    qt_extended_surface_events[2] = .{"close", "", surface_extension_types_storage.data + 0};
    qt_extended_surface_interface = .{
        "qt_extended_surface", 1,
        qt_extended_surface_requests.count, qt_extended_surface_requests.data,
        qt_extended_surface_events.count, qt_extended_surface_events.data,
    };
}


#scope_file
surface_extension_types_storage: []*wl_interface;

qt_surface_extension_requests: [1]wl_message;

qt_extended_surface_requests: [5]wl_message;
qt_extended_surface_events  : [3]wl_message;

#assert size_of(qt_surface_extension) == 0 "wayland-scanner bug: qt_surface_extension is non-empty";
#assert size_of(qt_extended_surface) == 0 "wayland-scanner bug: qt_extended_surface is non-empty";
