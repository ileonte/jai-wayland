/*
 * Auto-generated by `wayland-scanner` version 1.0.1
 * Protocol: keystate
 */

org_kde_kwin_keystate_interface: wl_interface;
org_kde_kwin_keystate :: struct {
    #as _proxy: wl_proxy;
    _interface_ :: *org_kde_kwin_keystate_interface;

    /* ENUM: org_kde_kwin_keystate::key */
    key_capslock   : u32 : 0;
    key_numlock    : u32 : 1;
    key_scrolllock : u32 : 2;

    /* ENUM: org_kde_kwin_keystate::state */
    state_unlocked : u32 : 0;
    state_latched  : u32 : 1;
    state_locked   : u32 : 2;

    set_user_data :: inline (self: *org_kde_kwin_keystate, user_data: *void) #c_call {
        wl_proxy.set_user_data(self, user_data);
    }

    get_user_data :: inline (self: *org_kde_kwin_keystate) -> *void #c_call {
        return wl_proxy.get_user_data(self);
    }

    get_version :: inline (self: *org_kde_kwin_keystate) -> u32 #c_call {
        return wl_proxy.get_version(self);
    }

    fetchStates :: inline (self: *org_kde_kwin_keystate) #c_call {
        wl_proxy.marshal_flags(
            self, ORG_KDE_KWIN_KEYSTATE_FETCHSTATES,
            null, wl_proxy.get_version(self), 0);
    }

    destroy :: inline (self: *org_kde_kwin_keystate) #c_call {
        wl_proxy.marshal_flags(
            self, ORG_KDE_KWIN_KEYSTATE_DESTROY,
            null, wl_proxy.get_version(self), WL_MARSHAL_FLAG_DESTROY);
    }

    add_listener :: inline (self: *org_kde_kwin_keystate, listener: *org_kde_kwin_keystate_listener, data: *void) -> s32 #c_call {
        return wl_proxy.add_listener(self, cast(*generic_c_call) listener, data);
    }
}

ORG_KDE_KWIN_KEYSTATE_FETCHSTATES        : u32 : 0;
ORG_KDE_KWIN_KEYSTATE_DESTROY            : u32 : 1;
ORG_KDE_KWIN_KEYSTATE_FETCHSTATES_SINCE  : u32 : 1;
ORG_KDE_KWIN_KEYSTATE_DESTROY_SINCE      : u32 : 4;
ORG_KDE_KWIN_KEYSTATE_STATECHANGED_SINCE : u32 : 1;

org_kde_kwin_keystate_listener :: struct {
    stateChanged := _stubs_.stateChanged;

    _stubs_ :: struct {
        stateChanged :: (data: *void,
            self: *org_kde_kwin_keystate,
            key: u32,
            state: u32) -> void #c_call {}
    }
}


#scope_module
keystate_protocol_init :: () {
    keystate_types_storage = .[
        /* __DUMMY__ */
        null,  // 0
        /* EVENT: org_kde_kwin_keystate::stateChanged */
        null,  // 1
        null,  // 2
    ];

    org_kde_kwin_keystate_requests[0] = .{"fetchStates", "", keystate_types_storage.data + 0};
    org_kde_kwin_keystate_requests[1] = .{"destroy", "", keystate_types_storage.data + 0};
    org_kde_kwin_keystate_events[0] = .{"stateChanged", "uu", keystate_types_storage.data + 1};
    org_kde_kwin_keystate_interface = .{
        "org_kde_kwin_keystate", 4,
        org_kde_kwin_keystate_requests.count, org_kde_kwin_keystate_requests.data,
        org_kde_kwin_keystate_events.count, org_kde_kwin_keystate_events.data,
    };
}


#scope_file
keystate_types_storage: []*wl_interface;

org_kde_kwin_keystate_requests: [2]wl_message;
org_kde_kwin_keystate_events  : [1]wl_message;

#assert size_of(org_kde_kwin_keystate) == 0 "wayland-scanner bug: org_kde_kwin_keystate is non-empty";
