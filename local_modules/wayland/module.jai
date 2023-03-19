#load "util.jai";
#load "client-core.jai";

#load "protocols/core/wayland.jai";
#load "protocols/core/stable/presentation-time.jai";
#load "protocols/core/stable/viewporter.jai";
#load "protocols/core/stable/xdg-shell.jai";

#load "protocols/core/unstable/fullscreen-shell-unstable-v1.jai";

wl_global_init :: () {
    wayland_protocol_init();
    presentation_time_protocol_init();
    xdg_shell_protocol_init();
    viewporter_protocol_init();

    fullscreen_shell_unstable_v1_protocol_init();
}

#scope_module

#import "Basic";
#import "POSIX";

wlc :: #system_library "libwayland-client";
generic_c_call :: #type () -> void #c_call;
