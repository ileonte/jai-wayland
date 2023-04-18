#import "Basic";
#import "Input";
#import "GL";
LD :: #import "Linux_Display";

repaint :: (w: LD.LDWindow, color: [4]float) {
    LD.make_current(w);

    x, y, width, height, s := LD.get_dimensions(w, false);
    glViewport(0, 0, xx width, xx height);
    glClearColor(color[0], color[1], color[2], color[3]);
    glClear(GL_COLOR_BUFFER_BIT);

    LD.swap_buffers(w);
}

main :: () {
    LD.init_display();
    LD.create_gl_context();

    w1 := LD.create_window(800, 600, "Test Window 1 BOOYA!", 0, 0, LD.INVALID_WINDOW, .[0, 0, 0]);
    LD.create_gl_surface(w1);

    w2 := LD.create_window(800, 600, "Test Window 2 COWABUNGA!", 0, 0, LD.INVALID_WINDOW, .[0, 0, 0]);
    LD.create_gl_surface(w2);

    while main_loop := true {
        update_window_events();

        for event: events_this_frame {
            if event.type == {
                case .QUIT; break main_loop;
                case .KEYBOARD; {
                    if event.key_pressed {
                        if event.key_code == {
                            case .ESCAPE; break main_loop;
                            case .F1; LD.get_clipboard();
                        }
                    }
                }
            }
        }

        repaint(w1, .[.5, .0, .0, 1.0]);
        repaint(w2, .[.0, .0, .5,  .7]);
    }
}
