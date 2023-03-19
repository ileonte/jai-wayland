wl_proxy :: struct {}
wl_event_queue :: struct {};
wl_display :: struct { #as _proxy: wl_proxy; }

WL_MARSHAL_FLAG_DESTROY :: 1;

wl_event_queue_destroy :: (queue: *wl_event_queue) #foreign wlc;

wl_proxy_marshal_flags :: (
    proxy: *wl_proxy, opcode: u32,
    intf: *wl_interface,
    version: u32,
    flags: u32, args: ..Any) -> *wl_proxy #foreign wlc;

wl_proxy_marshal_array_flags :: (
    proxy: *wl_proxy, opcode: u32,
    intf: *wl_interface,
    version: u32,
    flags: u32,
    args: *wl_argument) -> *wl_proxy #foreign wlc;

wl_proxy_marshal :: (p: *wl_proxy, opcode: u32, args: ..Any) #foreign wlc;

wl_proxy_marshal_array :: (p: *wl_proxy, opcode: u32, args: *wl_argument) #foreign wlc;

wl_proxy_create :: (factory: *wl_proxy, intf: *wl_interface) -> *wl_proxy #foreign wlc;

wl_proxy_create_wrapper :: (proxy: *void) -> *void #foreign wlc;

wl_proxy_wrapper_destroy :: (proxy_wrapper: *void) #foreign wlc;

wl_proxy_marshal_constructor :: (
    proxy: *wl_proxy,
    opcode: u32,
    intf: *wl_interface,
    args: ..Any) -> *wl_proxy #foreign wlc;

wl_proxy_marshal_constructor_versioned :: (
    proxy: *wl_proxy,
    opcode: u32,
    intf: *wl_interface,
    version: u32,
    args: ..Any) -> *wl_proxy #foreign wlc;

wl_proxy_marshal_array_constructor :: (
    proxy: *wl_proxy,
    opcode: u32,
    args: *wl_argument,
    intf: *wl_interface) -> *wl_proxy #foreign wlc;

wl_proxy_marshal_array_constructor_versioned :: (
    proxy: *wl_proxy,
    opcode: u32,
    args: *wl_argument,
    intf: *wl_interface,
    version: u32) -> *wl_proxy #foreign wlc;

wl_proxy_destroy :: (proxy: *wl_proxy) #foreign wlc;

wl_proxy_add_listener :: (proxy: *wl_proxy, impl: *generic_c_call, data: *void) -> s32 #foreign wlc;

wl_proxy_get_listener :: (proxy: *wl_proxy) -> *void #foreign wlc;

wl_proxy_add_dispatcher :: (
    proxy: *wl_proxy,
    func: wl_dispatcher_func_t,
    dispatcher_data: *void, data: *void) -> s32 #foreign wlc;

wl_proxy_set_user_data :: (proxy: *wl_proxy, user_data: *void) #foreign wlc;

wl_proxy_get_user_data :: (proxy: *wl_proxy) -> *void #foreign wlc;

wl_proxy_get_version :: (proxy: *wl_proxy) -> u32 #foreign wlc;

wl_proxy_get_id :: (proxy: *wl_proxy) -> u32 #foreign wlc;

wl_proxy_set_tag :: (proxy: *wl_proxy, tag: *u8) #foreign wlc;

wl_proxy_get_tag :: (proxy: *wl_proxy) -> *u8 #foreign wlc;

wl_proxy_get_class :: (proxy: *wl_proxy) -> *u8 #foreign wlc;

wl_proxy_set_queue :: (proxy: *wl_proxy, queue: *wl_event_queue) #foreign wlc;

wl_display_connect :: (name: *u8) -> *wl_display #foreign wlc;

wl_display_connect_to_fd :: (fd: s32) -> *wl_display #foreign wlc;

wl_display_disconnect :: (display: *wl_display) #foreign wlc;

wl_display_get_fd :: (display: *wl_display) -> s32 #foreign wlc;

wl_display_dispatch :: (display: *wl_display) -> s32 #foreign wlc;

wl_display_dispatch_queue :: (display: *wl_display, queue: wl_event_queue) -> s32 #foreign wlc;

wl_display_dispatch_queue_pending :: (display: *wl_display, queue: wl_event_queue) -> s32 #foreign wlc;

wl_display_dispatch_pending :: (display: *wl_display) -> s32 #foreign wlc;

wl_display_get_error :: (display: *wl_display) -> s32 #foreign wlc;

wl_display_get_protocol_error :: (display: *wl_display, intf: **wl_interface, id: *u32) -> u32 #foreign wlc;

wl_display_flush :: (display: *wl_display) -> s32 #foreign wlc;

wl_display_roundtrip_queue :: (display: *wl_display, queue: *wl_event_queue) -> s32 #foreign wlc;

wl_display_roundtrip :: (display: *wl_display) -> s32 #foreign wlc;

wl_display_create_queue :: (display: *wl_display) -> *wl_event_queue #foreign wlc;

wl_display_prepare_read_queue :: (display: *wl_display, queue: *wl_event_queue) -> s32 #foreign wlc;

wl_display_prepare_read :: (display: *wl_display) -> s32 #foreign wlc;

wl_display_cancel_read :: (display: *wl_display) #foreign wlc;

wl_display_read_events :: (display: *wl_display) -> s32 #foreign wlc;

wl_log_set_handler_client :: (handler: wl_log_func_t) #foreign wlc;
