/*
 * Auto-generated by `wayland-scanner` version 1.0.1
 * Protocol: zkde_screencast_unstable_v1
 */

zkde_screencast_unstable_v1_interface: wl_interface;
zkde_screencast_unstable_v1 :: struct {
    #as _proxy: wl_proxy;
    _interface_ :: *zkde_screencast_unstable_v1_interface;

    /* ENUM: zkde_screencast_unstable_v1::pointer */
    pointer_hidden   : u32 : 1;
    pointer_embedded : u32 : 2;
    pointer_metadata : u32 : 4;

    set_user_data :: inline (self: *zkde_screencast_unstable_v1, user_data: *void) #c_call {
        wl_proxy.set_user_data(self, user_data);
    }

    get_user_data :: inline (self: *zkde_screencast_unstable_v1) -> *void #c_call {
        return wl_proxy.get_user_data(self);
    }

    get_version :: inline (self: *zkde_screencast_unstable_v1) -> u32 #c_call {
        return wl_proxy.get_version(self);
    }

    stream_output :: inline (self: *zkde_screencast_unstable_v1, output: *wl_output, pointer: u32) -> *zkde_screencast_stream_unstable_v1 #c_call {
        ret: *wl_proxy = wl_proxy.marshal_flags(
            self, ZKDE_SCREENCAST_UNSTABLE_V1_STREAM_OUTPUT,
            *zkde_screencast_stream_unstable_v1_interface, wl_proxy.get_version(self), 0,
            null, output, pointer);
        return cast(*zkde_screencast_stream_unstable_v1) ret;
    }

    stream_window :: inline (self: *zkde_screencast_unstable_v1, window_uuid: *u8, pointer: u32) -> *zkde_screencast_stream_unstable_v1 #c_call {
        ret: *wl_proxy = wl_proxy.marshal_flags(
            self, ZKDE_SCREENCAST_UNSTABLE_V1_STREAM_WINDOW,
            *zkde_screencast_stream_unstable_v1_interface, wl_proxy.get_version(self), 0,
            null, window_uuid, pointer);
        return cast(*zkde_screencast_stream_unstable_v1) ret;
    }

    destroy :: inline (self: *zkde_screencast_unstable_v1) #c_call {
        wl_proxy.marshal_flags(
            self, ZKDE_SCREENCAST_UNSTABLE_V1_DESTROY,
            null, wl_proxy.get_version(self), WL_MARSHAL_FLAG_DESTROY);
    }

    stream_virtual_output :: inline (self: *zkde_screencast_unstable_v1, name: *u8, width: s32, height: s32, scale: wl_fixed_t, pointer: u32) -> *zkde_screencast_stream_unstable_v1 #c_call {
        ret: *wl_proxy = wl_proxy.marshal_flags(
            self, ZKDE_SCREENCAST_UNSTABLE_V1_STREAM_VIRTUAL_OUTPUT,
            *zkde_screencast_stream_unstable_v1_interface, wl_proxy.get_version(self), 0,
            null, name, width, height, scale, pointer);
        return cast(*zkde_screencast_stream_unstable_v1) ret;
    }

    stream_region :: inline (self: *zkde_screencast_unstable_v1, x: s32, y: s32, width: u32, height: u32, scale: wl_fixed_t, pointer: u32) -> *zkde_screencast_stream_unstable_v1 #c_call {
        ret: *wl_proxy = wl_proxy.marshal_flags(
            self, ZKDE_SCREENCAST_UNSTABLE_V1_STREAM_REGION,
            *zkde_screencast_stream_unstable_v1_interface, wl_proxy.get_version(self), 0,
            null, x, y, width, height, scale, pointer);
        return cast(*zkde_screencast_stream_unstable_v1) ret;
    }
}

ZKDE_SCREENCAST_UNSTABLE_V1_STREAM_OUTPUT               : u32 : 0;
ZKDE_SCREENCAST_UNSTABLE_V1_STREAM_WINDOW               : u32 : 1;
ZKDE_SCREENCAST_UNSTABLE_V1_DESTROY                     : u32 : 2;
ZKDE_SCREENCAST_UNSTABLE_V1_STREAM_VIRTUAL_OUTPUT       : u32 : 3;
ZKDE_SCREENCAST_UNSTABLE_V1_STREAM_REGION               : u32 : 4;
ZKDE_SCREENCAST_UNSTABLE_V1_STREAM_OUTPUT_SINCE         : u32 : 1;
ZKDE_SCREENCAST_UNSTABLE_V1_STREAM_WINDOW_SINCE         : u32 : 1;
ZKDE_SCREENCAST_UNSTABLE_V1_DESTROY_SINCE               : u32 : 1;
ZKDE_SCREENCAST_UNSTABLE_V1_STREAM_VIRTUAL_OUTPUT_SINCE : u32 : 2;
ZKDE_SCREENCAST_UNSTABLE_V1_STREAM_REGION_SINCE         : u32 : 3;

zkde_screencast_stream_unstable_v1_interface: wl_interface;
zkde_screencast_stream_unstable_v1 :: struct {
    #as _proxy: wl_proxy;
    _interface_ :: *zkde_screencast_stream_unstable_v1_interface;

    set_user_data :: inline (self: *zkde_screencast_stream_unstable_v1, user_data: *void) #c_call {
        wl_proxy.set_user_data(self, user_data);
    }

    get_user_data :: inline (self: *zkde_screencast_stream_unstable_v1) -> *void #c_call {
        return wl_proxy.get_user_data(self);
    }

    get_version :: inline (self: *zkde_screencast_stream_unstable_v1) -> u32 #c_call {
        return wl_proxy.get_version(self);
    }

    destroy :: inline (self: *zkde_screencast_stream_unstable_v1) #c_call {
        wl_proxy.destroy(self);
    }

    close :: inline (self: *zkde_screencast_stream_unstable_v1) #c_call {
        wl_proxy.marshal_flags(
            self, ZKDE_SCREENCAST_STREAM_UNSTABLE_V1_CLOSE,
            null, wl_proxy.get_version(self), WL_MARSHAL_FLAG_DESTROY);
    }

    add_listener :: inline (self: *zkde_screencast_stream_unstable_v1, listener: *zkde_screencast_stream_unstable_v1_listener, data: *void) -> s32 #c_call {
        return wl_proxy.add_listener(self, cast(*generic_c_call) listener, data);
    }
}

ZKDE_SCREENCAST_STREAM_UNSTABLE_V1_CLOSE         : u32 : 0;
ZKDE_SCREENCAST_STREAM_UNSTABLE_V1_CLOSE_SINCE   : u32 : 1;
ZKDE_SCREENCAST_STREAM_UNSTABLE_V1_CLOSED_SINCE  : u32 : 1;
ZKDE_SCREENCAST_STREAM_UNSTABLE_V1_CREATED_SINCE : u32 : 1;
ZKDE_SCREENCAST_STREAM_UNSTABLE_V1_FAILED_SINCE  : u32 : 1;

zkde_screencast_stream_unstable_v1_listener :: struct {
    closed  := _stubs_.closed;
    created := _stubs_.created;
    failed  := _stubs_.failed;

    _stubs_ :: struct {
        closed :: (data: *void,
            self: *zkde_screencast_stream_unstable_v1) -> void #c_call {}
        created :: (data: *void,
            self: *zkde_screencast_stream_unstable_v1,
            node: u32) -> void #c_call {}
        failed :: (data: *void,
            self: *zkde_screencast_stream_unstable_v1,
            error: *u8) -> void #c_call {}
    }
}


#scope_module
zkde_screencast_unstable_v1_protocol_init :: () {
    zkde_screencast_unstable_v1_types_storage = .[
        /* __DUMMY__ */
        null,  // 0
        /* REQUEST: zkde_screencast_unstable_v1::stream_output */
        *zkde_screencast_stream_unstable_v1_interface,   // 1
        *wl_output_interface,   // 2
        null,  // 3
        /* REQUEST: zkde_screencast_unstable_v1::stream_window */
        *zkde_screencast_stream_unstable_v1_interface,   // 4
        null,  // 5
        null,  // 6
        /* REQUEST: zkde_screencast_unstable_v1::stream_virtual_output */
        *zkde_screencast_stream_unstable_v1_interface,   // 7
        null,  // 8
        null,  // 9
        null,  // 10
        null,  // 11
        null,  // 12
        /* REQUEST: zkde_screencast_unstable_v1::stream_region */
        *zkde_screencast_stream_unstable_v1_interface,   // 13
        null,  // 14
        null,  // 15
        null,  // 16
        null,  // 17
        null,  // 18
        null,  // 19
        /* EVENT: zkde_screencast_stream_unstable_v1::created */
        null,  // 20
        /* EVENT: zkde_screencast_stream_unstable_v1::failed */
        null,  // 21
    ];

    zkde_screencast_unstable_v1_requests[0] = .{"stream_output", "nou", zkde_screencast_unstable_v1_types_storage.data + 1};
    zkde_screencast_unstable_v1_requests[1] = .{"stream_window", "nsu", zkde_screencast_unstable_v1_types_storage.data + 4};
    zkde_screencast_unstable_v1_requests[2] = .{"destroy", "", zkde_screencast_unstable_v1_types_storage.data + 0};
    zkde_screencast_unstable_v1_requests[3] = .{"stream_virtual_output", "nsiifu", zkde_screencast_unstable_v1_types_storage.data + 7};
    zkde_screencast_unstable_v1_requests[4] = .{"stream_region", "niiuufu", zkde_screencast_unstable_v1_types_storage.data + 13};
    zkde_screencast_unstable_v1_interface = .{
        "zkde_screencast_unstable_v1", 3,
        zkde_screencast_unstable_v1_requests.count, zkde_screencast_unstable_v1_requests.data,
        0, null,
    };

    zkde_screencast_stream_unstable_v1_requests[0] = .{"close", "", zkde_screencast_unstable_v1_types_storage.data + 0};
    zkde_screencast_stream_unstable_v1_events[0] = .{"closed", "", zkde_screencast_unstable_v1_types_storage.data + 0};
    zkde_screencast_stream_unstable_v1_events[1] = .{"created", "u", zkde_screencast_unstable_v1_types_storage.data + 20};
    zkde_screencast_stream_unstable_v1_events[2] = .{"failed", "s", zkde_screencast_unstable_v1_types_storage.data + 21};
    zkde_screencast_stream_unstable_v1_interface = .{
        "zkde_screencast_stream_unstable_v1", 3,
        zkde_screencast_stream_unstable_v1_requests.count, zkde_screencast_stream_unstable_v1_requests.data,
        zkde_screencast_stream_unstable_v1_events.count, zkde_screencast_stream_unstable_v1_events.data,
    };
}


#scope_file
zkde_screencast_unstable_v1_types_storage: []*wl_interface;

zkde_screencast_unstable_v1_requests: [5]wl_message;

zkde_screencast_stream_unstable_v1_requests: [1]wl_message;
zkde_screencast_stream_unstable_v1_events  : [3]wl_message;

#assert size_of(zkde_screencast_unstable_v1) == 0 "wayland-scanner bug: zkde_screencast_unstable_v1 is non-empty";
#assert size_of(zkde_screencast_stream_unstable_v1) == 0 "wayland-scanner bug: zkde_screencast_stream_unstable_v1 is non-empty";
