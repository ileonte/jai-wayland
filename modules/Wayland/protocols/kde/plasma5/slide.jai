/*
 * Auto-generated by `wayland-scanner` version 1.0.1
 * Protocol: slide
 */

org_kde_kwin_slide_manager_interface: wl_interface;
org_kde_kwin_slide_manager :: struct {
    #as _proxy: wl_proxy;
    _interface_ :: *org_kde_kwin_slide_manager_interface;

    set_user_data :: inline (self: *org_kde_kwin_slide_manager, user_data: *void) #c_call {
        wl_proxy.set_user_data(self, user_data);
    }

    get_user_data :: inline (self: *org_kde_kwin_slide_manager) -> *void #c_call {
        return wl_proxy.get_user_data(self);
    }

    get_version :: inline (self: *org_kde_kwin_slide_manager) -> u32 #c_call {
        return wl_proxy.get_version(self);
    }

    destroy :: inline (self: *org_kde_kwin_slide_manager) #c_call {
        wl_proxy.destroy(self);
    }

    create :: inline (self: *org_kde_kwin_slide_manager, surface: *wl_surface) -> *org_kde_kwin_slide #c_call {
        ret: *wl_proxy = wl_proxy.marshal_flags(
            self, ORG_KDE_KWIN_SLIDE_MANAGER_CREATE,
            *org_kde_kwin_slide_interface, wl_proxy.get_version(self), 0,
            null, surface);
        return cast(*org_kde_kwin_slide) ret;
    }

    unset :: inline (self: *org_kde_kwin_slide_manager, surface: *wl_surface) #c_call {
        wl_proxy.marshal_flags(
            self, ORG_KDE_KWIN_SLIDE_MANAGER_UNSET,
            null, wl_proxy.get_version(self), 0,
            surface);
    }
}

ORG_KDE_KWIN_SLIDE_MANAGER_CREATE       : u32 : 0;
ORG_KDE_KWIN_SLIDE_MANAGER_UNSET        : u32 : 1;
ORG_KDE_KWIN_SLIDE_MANAGER_CREATE_SINCE : u32 : 1;
ORG_KDE_KWIN_SLIDE_MANAGER_UNSET_SINCE  : u32 : 1;

org_kde_kwin_slide_interface: wl_interface;
org_kde_kwin_slide :: struct {
    #as _proxy: wl_proxy;
    _interface_ :: *org_kde_kwin_slide_interface;

    /* ENUM: org_kde_kwin_slide::location */
    location_left   : u32 : 0;
    location_top    : u32 : 1;
    location_right  : u32 : 2;
    location_bottom : u32 : 3;

    set_user_data :: inline (self: *org_kde_kwin_slide, user_data: *void) #c_call {
        wl_proxy.set_user_data(self, user_data);
    }

    get_user_data :: inline (self: *org_kde_kwin_slide) -> *void #c_call {
        return wl_proxy.get_user_data(self);
    }

    get_version :: inline (self: *org_kde_kwin_slide) -> u32 #c_call {
        return wl_proxy.get_version(self);
    }

    destroy :: inline (self: *org_kde_kwin_slide) #c_call {
        wl_proxy.destroy(self);
    }

    commit :: inline (self: *org_kde_kwin_slide) #c_call {
        wl_proxy.marshal_flags(
            self, ORG_KDE_KWIN_SLIDE_COMMIT,
            null, wl_proxy.get_version(self), 0);
    }

    set_location :: inline (self: *org_kde_kwin_slide, location: u32) #c_call {
        wl_proxy.marshal_flags(
            self, ORG_KDE_KWIN_SLIDE_SET_LOCATION,
            null, wl_proxy.get_version(self), 0,
            location);
    }

    set_offset :: inline (self: *org_kde_kwin_slide, offset: s32) #c_call {
        wl_proxy.marshal_flags(
            self, ORG_KDE_KWIN_SLIDE_SET_OFFSET,
            null, wl_proxy.get_version(self), 0,
            offset);
    }

    release :: inline (self: *org_kde_kwin_slide) #c_call {
        wl_proxy.marshal_flags(
            self, ORG_KDE_KWIN_SLIDE_RELEASE,
            null, wl_proxy.get_version(self), WL_MARSHAL_FLAG_DESTROY);
    }
}

ORG_KDE_KWIN_SLIDE_COMMIT             : u32 : 0;
ORG_KDE_KWIN_SLIDE_SET_LOCATION       : u32 : 1;
ORG_KDE_KWIN_SLIDE_SET_OFFSET         : u32 : 2;
ORG_KDE_KWIN_SLIDE_RELEASE            : u32 : 3;
ORG_KDE_KWIN_SLIDE_COMMIT_SINCE       : u32 : 1;
ORG_KDE_KWIN_SLIDE_SET_LOCATION_SINCE : u32 : 1;
ORG_KDE_KWIN_SLIDE_SET_OFFSET_SINCE   : u32 : 1;
ORG_KDE_KWIN_SLIDE_RELEASE_SINCE      : u32 : 1;


#scope_module
slide_protocol_init :: () {
    slide_types_storage = .[
        /* __DUMMY__ */
        null,  // 0
        /* REQUEST: org_kde_kwin_slide_manager::create */
        *org_kde_kwin_slide_interface,   // 1
        *wl_surface_interface,   // 2
        /* REQUEST: org_kde_kwin_slide_manager::unset */
        *wl_surface_interface,   // 3
        /* REQUEST: org_kde_kwin_slide::set_location */
        null,  // 4
        /* REQUEST: org_kde_kwin_slide::set_offset */
        null,  // 5
    ];

    org_kde_kwin_slide_manager_requests[0] = .{"create", "no", slide_types_storage.data + 1};
    org_kde_kwin_slide_manager_requests[1] = .{"unset", "o", slide_types_storage.data + 3};
    org_kde_kwin_slide_manager_interface = .{
        "org_kde_kwin_slide_manager", 1,
        org_kde_kwin_slide_manager_requests.count, org_kde_kwin_slide_manager_requests.data,
        0, null,
    };

    org_kde_kwin_slide_requests[0] = .{"commit", "", slide_types_storage.data + 0};
    org_kde_kwin_slide_requests[1] = .{"set_location", "u", slide_types_storage.data + 4};
    org_kde_kwin_slide_requests[2] = .{"set_offset", "i", slide_types_storage.data + 5};
    org_kde_kwin_slide_requests[3] = .{"release", "", slide_types_storage.data + 0};
    org_kde_kwin_slide_interface = .{
        "org_kde_kwin_slide", 1,
        org_kde_kwin_slide_requests.count, org_kde_kwin_slide_requests.data,
        0, null,
    };
}


#scope_file
slide_types_storage: []*wl_interface;

org_kde_kwin_slide_manager_requests: [2]wl_message;

org_kde_kwin_slide_requests: [4]wl_message;

#assert size_of(org_kde_kwin_slide_manager) == 0 "wayland-scanner bug: org_kde_kwin_slide_manager is non-empty";
#assert size_of(org_kde_kwin_slide) == 0 "wayland-scanner bug: org_kde_kwin_slide is non-empty";
