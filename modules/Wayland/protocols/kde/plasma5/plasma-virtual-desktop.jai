/*
 * Auto-generated by `wayland-scanner` version 1.0.1
 * Protocol: org_kde_plasma_virtual_desktop
 */

org_kde_plasma_virtual_desktop_management_interface: wl_interface;
org_kde_plasma_virtual_desktop_management :: struct {
    #as _proxy: wl_proxy;
    _interface_ :: *org_kde_plasma_virtual_desktop_management_interface;

    set_user_data :: inline (self: *org_kde_plasma_virtual_desktop_management, user_data: *void) #c_call {
        wl_proxy.set_user_data(self, user_data);
    }

    get_user_data :: inline (self: *org_kde_plasma_virtual_desktop_management) -> *void #c_call {
        return wl_proxy.get_user_data(self);
    }

    get_version :: inline (self: *org_kde_plasma_virtual_desktop_management) -> u32 #c_call {
        return wl_proxy.get_version(self);
    }

    destroy :: inline (self: *org_kde_plasma_virtual_desktop_management) #c_call {
        wl_proxy.destroy(self);
    }

    get_virtual_desktop :: inline (self: *org_kde_plasma_virtual_desktop_management, desktop_id: *u8) -> *org_kde_plasma_virtual_desktop #c_call {
        ret: *wl_proxy = wl_proxy.marshal_flags(
            self, ORG_KDE_PLASMA_VIRTUAL_DESKTOP_MANAGEMENT_GET_VIRTUAL_DESKTOP,
            *org_kde_plasma_virtual_desktop_interface, wl_proxy.get_version(self), 0,
            null, desktop_id);
        return cast(*org_kde_plasma_virtual_desktop) ret;
    }

    request_create_virtual_desktop :: inline (self: *org_kde_plasma_virtual_desktop_management, name: *u8, position: u32) #c_call {
        wl_proxy.marshal_flags(
            self, ORG_KDE_PLASMA_VIRTUAL_DESKTOP_MANAGEMENT_REQUEST_CREATE_VIRTUAL_DESKTOP,
            null, wl_proxy.get_version(self), 0,
            name, position);
    }

    request_remove_virtual_desktop :: inline (self: *org_kde_plasma_virtual_desktop_management, desktop_id: *u8) #c_call {
        wl_proxy.marshal_flags(
            self, ORG_KDE_PLASMA_VIRTUAL_DESKTOP_MANAGEMENT_REQUEST_REMOVE_VIRTUAL_DESKTOP,
            null, wl_proxy.get_version(self), 0,
            desktop_id);
    }

    add_listener :: inline (self: *org_kde_plasma_virtual_desktop_management, listener: *org_kde_plasma_virtual_desktop_management_listener, data: *void) -> s32 #c_call {
        return wl_proxy.add_listener(self, cast(*generic_c_call) listener, data);
    }
}

ORG_KDE_PLASMA_VIRTUAL_DESKTOP_MANAGEMENT_GET_VIRTUAL_DESKTOP                  : u32 : 0;
ORG_KDE_PLASMA_VIRTUAL_DESKTOP_MANAGEMENT_REQUEST_CREATE_VIRTUAL_DESKTOP       : u32 : 1;
ORG_KDE_PLASMA_VIRTUAL_DESKTOP_MANAGEMENT_REQUEST_REMOVE_VIRTUAL_DESKTOP       : u32 : 2;
ORG_KDE_PLASMA_VIRTUAL_DESKTOP_MANAGEMENT_GET_VIRTUAL_DESKTOP_SINCE            : u32 : 1;
ORG_KDE_PLASMA_VIRTUAL_DESKTOP_MANAGEMENT_REQUEST_CREATE_VIRTUAL_DESKTOP_SINCE : u32 : 1;
ORG_KDE_PLASMA_VIRTUAL_DESKTOP_MANAGEMENT_REQUEST_REMOVE_VIRTUAL_DESKTOP_SINCE : u32 : 1;
ORG_KDE_PLASMA_VIRTUAL_DESKTOP_MANAGEMENT_DESKTOP_CREATED_SINCE                : u32 : 1;
ORG_KDE_PLASMA_VIRTUAL_DESKTOP_MANAGEMENT_DESKTOP_REMOVED_SINCE                : u32 : 1;
ORG_KDE_PLASMA_VIRTUAL_DESKTOP_MANAGEMENT_DONE_SINCE                           : u32 : 1;
ORG_KDE_PLASMA_VIRTUAL_DESKTOP_MANAGEMENT_ROWS_SINCE                           : u32 : 2;

org_kde_plasma_virtual_desktop_management_listener :: struct {
    desktop_created := _stubs_.desktop_created;
    desktop_removed := _stubs_.desktop_removed;
    done            := _stubs_.done;
    rows            := _stubs_.rows;

    _stubs_ :: struct {
        desktop_created :: (data: *void,
            self: *org_kde_plasma_virtual_desktop_management,
            desktop_id: *u8,
            position: u32) -> void #c_call {}
        desktop_removed :: (data: *void,
            self: *org_kde_plasma_virtual_desktop_management,
            desktop_id: *u8) -> void #c_call {}
        done :: (data: *void,
            self: *org_kde_plasma_virtual_desktop_management) -> void #c_call {}
        rows :: (data: *void,
            self: *org_kde_plasma_virtual_desktop_management,
            rows: u32) -> void #c_call {}
    }
}

org_kde_plasma_virtual_desktop_interface: wl_interface;
org_kde_plasma_virtual_desktop :: struct {
    #as _proxy: wl_proxy;
    _interface_ :: *org_kde_plasma_virtual_desktop_interface;

    set_user_data :: inline (self: *org_kde_plasma_virtual_desktop, user_data: *void) #c_call {
        wl_proxy.set_user_data(self, user_data);
    }

    get_user_data :: inline (self: *org_kde_plasma_virtual_desktop) -> *void #c_call {
        return wl_proxy.get_user_data(self);
    }

    get_version :: inline (self: *org_kde_plasma_virtual_desktop) -> u32 #c_call {
        return wl_proxy.get_version(self);
    }

    destroy :: inline (self: *org_kde_plasma_virtual_desktop) #c_call {
        wl_proxy.destroy(self);
    }

    request_activate :: inline (self: *org_kde_plasma_virtual_desktop) #c_call {
        wl_proxy.marshal_flags(
            self, ORG_KDE_PLASMA_VIRTUAL_DESKTOP_REQUEST_ACTIVATE,
            null, wl_proxy.get_version(self), 0);
    }

    add_listener :: inline (self: *org_kde_plasma_virtual_desktop, listener: *org_kde_plasma_virtual_desktop_listener, data: *void) -> s32 #c_call {
        return wl_proxy.add_listener(self, cast(*generic_c_call) listener, data);
    }
}

ORG_KDE_PLASMA_VIRTUAL_DESKTOP_REQUEST_ACTIVATE       : u32 : 0;
ORG_KDE_PLASMA_VIRTUAL_DESKTOP_REQUEST_ACTIVATE_SINCE : u32 : 1;
ORG_KDE_PLASMA_VIRTUAL_DESKTOP_DESKTOP_ID_SINCE       : u32 : 1;
ORG_KDE_PLASMA_VIRTUAL_DESKTOP_NAME_SINCE             : u32 : 1;
ORG_KDE_PLASMA_VIRTUAL_DESKTOP_ACTIVATED_SINCE        : u32 : 1;
ORG_KDE_PLASMA_VIRTUAL_DESKTOP_DEACTIVATED_SINCE      : u32 : 1;
ORG_KDE_PLASMA_VIRTUAL_DESKTOP_DONE_SINCE             : u32 : 1;
ORG_KDE_PLASMA_VIRTUAL_DESKTOP_REMOVED_SINCE          : u32 : 1;

org_kde_plasma_virtual_desktop_listener :: struct {
    desktop_id  := _stubs_.desktop_id;
    name        := _stubs_.name;
    activated   := _stubs_.activated;
    deactivated := _stubs_.deactivated;
    done        := _stubs_.done;
    removed     := _stubs_.removed;

    _stubs_ :: struct {
        desktop_id :: (data: *void,
            self: *org_kde_plasma_virtual_desktop,
            desktop_id: *u8) -> void #c_call {}
        name :: (data: *void,
            self: *org_kde_plasma_virtual_desktop,
            name: *u8) -> void #c_call {}
        activated :: (data: *void,
            self: *org_kde_plasma_virtual_desktop) -> void #c_call {}
        deactivated :: (data: *void,
            self: *org_kde_plasma_virtual_desktop) -> void #c_call {}
        done :: (data: *void,
            self: *org_kde_plasma_virtual_desktop) -> void #c_call {}
        removed :: (data: *void,
            self: *org_kde_plasma_virtual_desktop) -> void #c_call {}
    }
}


#scope_module
org_kde_plasma_virtual_desktop_protocol_init :: () {
    org_kde_plasma_virtual_desktop_types_storage = .[
        /* __DUMMY__ */
        null,  // 0
        /* REQUEST: org_kde_plasma_virtual_desktop_management::get_virtual_desktop */
        *org_kde_plasma_virtual_desktop_interface,   // 1
        null,  // 2
        /* REQUEST: org_kde_plasma_virtual_desktop_management::request_create_virtual_desktop */
        null,  // 3
        null,  // 4
        /* REQUEST: org_kde_plasma_virtual_desktop_management::request_remove_virtual_desktop */
        null,  // 5
        /* EVENT: org_kde_plasma_virtual_desktop_management::desktop_created */
        null,  // 6
        null,  // 7
        /* EVENT: org_kde_plasma_virtual_desktop_management::desktop_removed */
        null,  // 8
        /* EVENT: org_kde_plasma_virtual_desktop_management::rows */
        null,  // 9
        /* EVENT: org_kde_plasma_virtual_desktop::desktop_id */
        null,  // 10
        /* EVENT: org_kde_plasma_virtual_desktop::name */
        null,  // 11
    ];

    org_kde_plasma_virtual_desktop_management_requests[0] = .{"get_virtual_desktop", "ns", org_kde_plasma_virtual_desktop_types_storage.data + 1};
    org_kde_plasma_virtual_desktop_management_requests[1] = .{"request_create_virtual_desktop", "su", org_kde_plasma_virtual_desktop_types_storage.data + 3};
    org_kde_plasma_virtual_desktop_management_requests[2] = .{"request_remove_virtual_desktop", "s", org_kde_plasma_virtual_desktop_types_storage.data + 5};
    org_kde_plasma_virtual_desktop_management_events[0] = .{"desktop_created", "su", org_kde_plasma_virtual_desktop_types_storage.data + 6};
    org_kde_plasma_virtual_desktop_management_events[1] = .{"desktop_removed", "s", org_kde_plasma_virtual_desktop_types_storage.data + 8};
    org_kde_plasma_virtual_desktop_management_events[2] = .{"done", "", org_kde_plasma_virtual_desktop_types_storage.data + 0};
    org_kde_plasma_virtual_desktop_management_events[3] = .{"rows", "u", org_kde_plasma_virtual_desktop_types_storage.data + 9};
    org_kde_plasma_virtual_desktop_management_interface = .{
        "org_kde_plasma_virtual_desktop_management", 2,
        org_kde_plasma_virtual_desktop_management_requests.count, org_kde_plasma_virtual_desktop_management_requests.data,
        org_kde_plasma_virtual_desktop_management_events.count, org_kde_plasma_virtual_desktop_management_events.data,
    };

    org_kde_plasma_virtual_desktop_requests[0] = .{"request_activate", "", org_kde_plasma_virtual_desktop_types_storage.data + 0};
    org_kde_plasma_virtual_desktop_events[0] = .{"desktop_id", "s", org_kde_plasma_virtual_desktop_types_storage.data + 10};
    org_kde_plasma_virtual_desktop_events[1] = .{"name", "s", org_kde_plasma_virtual_desktop_types_storage.data + 11};
    org_kde_plasma_virtual_desktop_events[2] = .{"activated", "", org_kde_plasma_virtual_desktop_types_storage.data + 0};
    org_kde_plasma_virtual_desktop_events[3] = .{"deactivated", "", org_kde_plasma_virtual_desktop_types_storage.data + 0};
    org_kde_plasma_virtual_desktop_events[4] = .{"done", "", org_kde_plasma_virtual_desktop_types_storage.data + 0};
    org_kde_plasma_virtual_desktop_events[5] = .{"removed", "", org_kde_plasma_virtual_desktop_types_storage.data + 0};
    org_kde_plasma_virtual_desktop_interface = .{
        "org_kde_plasma_virtual_desktop", 1,
        org_kde_plasma_virtual_desktop_requests.count, org_kde_plasma_virtual_desktop_requests.data,
        org_kde_plasma_virtual_desktop_events.count, org_kde_plasma_virtual_desktop_events.data,
    };
}


#scope_file
org_kde_plasma_virtual_desktop_types_storage: []*wl_interface;

org_kde_plasma_virtual_desktop_management_requests: [3]wl_message;
org_kde_plasma_virtual_desktop_management_events  : [4]wl_message;

org_kde_plasma_virtual_desktop_requests: [1]wl_message;
org_kde_plasma_virtual_desktop_events  : [6]wl_message;

#assert size_of(org_kde_plasma_virtual_desktop_management) == 0 "wayland-scanner bug: org_kde_plasma_virtual_desktop_management is non-empty";
#assert size_of(org_kde_plasma_virtual_desktop) == 0 "wayland-scanner bug: org_kde_plasma_virtual_desktop is non-empty";
