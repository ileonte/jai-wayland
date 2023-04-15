main :: () {
    the_window = create_window(WINDOW_WIDTH, WINDOW_HEIGHT, "Window Creation", background_color_rgb = .[0.5, 0.5, 0.5]);
    x, y, w, h, ok := get_dimensions(the_window, false);
    print("the_window = % (pos=(%, %), size=(%,%), ok=%)\n", the_window, x, y, w, h, ok);

    LD.get_mouse_pointer_position(false);

    quit := false;
    fullscreen := false;
    while !quit {
        update_window_events();

        for events_this_frame {
            if it.type == .QUIT then quit = true;

            if it.type == .KEYBOARD {
                if it.key_pressed == 0 continue;

                if it.key_code == .ESCAPE {
                    quit = true;
                }
                if it.key_code == .F11 {
                    s, w, h := toggle_fullscreen(the_window, !fullscreen, null);
                    if s {
                        fullscreen = !fullscreen;
                        print("w = %, h = %, fullscreen = %\n", w, h, fullscreen);
                    }
                }
            }
        }
    }
}

#scope_file

LD :: #import "Linux_Display";
#import "Basic";
#import "Window_Creation";
#import "Input";

WINDOW_WIDTH  :: 1280;
WINDOW_HEIGHT :: 720;
the_window: Window_Type;
