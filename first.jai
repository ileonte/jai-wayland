#import "Basic";
#import "POSIX";
#import "wayland";

print_messages :: (prefix: string, base: *wl_message, count: s32) {
    for 0..count - 1 {
        method := base + it;
        name := to_string(method.name);
        sig  := to_string(method.signature);
        print("% %(%)\n", prefix, name, sig);
    }
}

print_interface :: (intf: *wl_interface) {
    name := to_string(intf.name);
    print("INTERFACE '%' (version %) :: % method(s), % event(s)\n",
        name, intf.version, intf.method_count, intf.event_count);
    print_messages("  METHOD ", intf.methods, intf.method_count);
    print_messages("   EVENT ", intf.events, intf.event_count);
}

S :: struct {
    using enum u32 {
        bla;
    }
}

main :: () {
    print("%\n", S.bla);

    wl_global_init();

    display := wl_display.connect(null);
    registry := wl_display.get_registry(display);

    listener: wl_registry_listener = .{
        global = (data: *void, registry: *wl_registry, id: u32, intf: *u8, version: u32) -> void #c_call {
            ctx: Context;
            push_context ctx {
                name := to_string(intf);
                print("REGISTRY EVENT FOR (ID = %2, VERSION = %3) '%1'\n", name, id, version);
            }
        },
        global_remove = (data: *void, registry: *wl_registry, id: u32) -> void #c_call {}
    };
    wl_registry.add_listener(registry, *listener, null);

    wl_display.dispatch(display);
    wl_display.roundtrip(display);

    wl_display.disconnect(display);
}
