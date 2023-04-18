//
// This is an example of how to use GetRect.
//
// GetRect is in its period of initial creation and is still evolving quickly.
// One important thing to know is, there is no notion of global focus yet,
// so we do some manual focus wrangling in here. We'll clean that up eventually.
//
// Also, this demo will be made cosmetically nicer in the end. Right now it just
// demonstrates how to do the various types of controls, but ultimately the goal
// is that GetRect does not look ugly by default, unlike many other UI systems.
//

#import "GetRect";  // Other imports are below, but the point of this example is to use GetRect so this #import goes here.

//
// This example was copied from modules/Simp/examples/example.jai.
// It will continue to diverge over time, probably.
//

SCALE :: 1;  // I use this during development to quickly make the window real big.

my_window: Window_Type;
window_width  : s32 = 1920*SCALE;
window_height : s32 = 1080*SCALE;

current_time: float64;
last\  _time: float64;

// Data values that we manipulate with the widgets:

scroll_value: float;
scroll_value_dragdrop_region: float;

// Data values that we manipulate with the widgets:

Grocery_Info :: struct {
    name: string;
    should_get := false;
}

groceries: [..] Grocery_Info;


dropped_files: [..] string;

spells: [..] string;  // We make a radio button of which spell to cast.
current_spell := -1;

INITIAL_STRING_A :: "Lord Dimwit Flathead";
INITIAL_STRING_B :: "Flood Control Dam #3";
INITIAL_STRING_C :: "The Troll Room";

INITIAL_STRING_T :: "Golden Monkey";

// string_a, string_b, string_c are where we store the text input strings.
string_a: string;
string_b: string;
string_c: string;

string_t: string;

Damage_Resistance :: enum_flags u16 {
    PIERCING;
    SLASHING;
    CRUSHING;
    BLUNT;
    ELECTRICAL :: 0x40;
    MAGIC;
    POISON;
    ELEMENTAL;
    EMOTIONAL;
}

damage_resistance: Damage_Resistance;

THEME_NAMES : [THEME_COUNT] string : .[
    "Default",
    "Grayscale",
    "Bentonite",
    "Nimbus",
    "Blood Vampire",
    "Freddie Freeloader",
    "HIGH CONTRAST"
];

teas :: string.["Earl Gray", "Singapore Breakfast", "Bengal Spice", "Hot Cinnamon Spice", "Tie Guanyin", "Lapsang Souchong", "Royal Pu-Erh", "Chai Juice", "Snore and Peace", "Golden Monkey", "Genmaicha", "Jasmine Pearls", "Sencha", "Gyokuro", "White Claw", "Rooibos", "Alishan Oolong"];

TEXT_FIELD_1 :: #string DONE
I thence
Invoke thy aid to my adventurous song,
That with no middle flight intends to soar
Above th' Aonian mount, while it pursues
Things unattempted yet in prose or rhyme.
And chiefly thou, O Spirit, that dost prefer
Before all temples th' upright heart and pure,
Instruct me, for thou know'st; thou from the first
Wast present, and, with mighty wings outspread,
Dove-like sat'st brooding on the vast Abyss,
And mad'st it pregnant: what in me is dark
Illumine, what is low raise and support;
That, to the height of this great argument,
I may assert Eternal Providence,
And justify the ways of God to men.
DONE

slider_float_value: float = 27.02;
slider_int_value  : s32 = 3;

current_theme: s32 = xx Default_Themes.Default;
my_theme: Overall_Theme;  // This gets filled out by calling the Theme_Proc for current_theme.

picked_color: Vector3 = .{.1, .8, .6};

// For windows that move around autonomously:
subwindow_info_text:   Subwindow_Info;
subwindow_info_circle: Subwindow_Info;
subwindows_initted := false;


// @Cleanup: Get rid of the need for begins_with_count?
begins_with_count :: (str: string, prefix: string) -> int {
    for 0..prefix.count-1 {
        // Case-insensitive.
        if it >= str.count return it;

        // @Speed: This is a pretty slow compare.
        ca := Basic.to_lower(str[it]);    // :CompilerBug
        cb := Basic.to_lower(prefix[it]);
/*
        ca := to_lower(str[it]);
        cb := to_lower(prefix[it]);
*/
        if ca != cb return it;
    }

    return prefix.count;
}

auto_complete_teas :: (input: string, data: *void) -> (results: [] string, longest_match_length: int) {
    results: [..] string;

    longest_match_length := 0;
    for teas {
        count := begins_with_count(it, input);
        if count == input.count {
            array_add(*results, it);
            longest_match_length = max(longest_match_length, input.count);
        }

        longest_match_length = max(longest_match_length, count);
    }

    return results, longest_match_length;
}

main :: () {
    #if OS == .WINDOWS {
        Windows :: #import "Windows";
        Windows.SetProcessDPIAware();

        // Windows is very bad at thread-switching by default unless you do this. Sad.
        Windows.timeBeginPeriod(1);
    }

    my_window = create_window(window_width, window_height, "A Window");
    #if OS == .WINDOWS {
        // @Feature: Add user-specific typelist support.
        Windows.DragAcceptFiles(my_window, cast(Windows.BOOL) true);
    } else #if OS == .LINUX {
        X11 :: #import "X11";
        typelist := string.["url/url", "text/uri-list", "text/plain", "application/octet-stream"];
        // X11.enable_drag_and_drop(my_window, typelist);
    } else #if OS == .MACOS {
        // @Incomplete
    }


    Simp.set_render_target(my_window);

    my_init_fonts();
    ui_init();

    // So that we have consistent memory handling after these
    // strings are user-modified, we heap-allocate them. You don't
    // have to do this; you just need some consistent way of
    // storing the strings.
    string_a = copy_string(INITIAL_STRING_A);
    string_b = copy_string(INITIAL_STRING_B);
    string_c = copy_string(INITIAL_STRING_C);
    string_t = copy_string(INITIAL_STRING_T);

    // Add some groceries.

    g := array_add(*groceries);
    g.name = "Apples";

    g = array_add(*groceries);
    g.name = "Bananas";

    g = array_add(*groceries);
    g.name = "Moon Chips";

    g = array_add(*groceries);
    g.name = "Chai Juice";


    array_add(*spells, "rezrov");
    array_add(*spells, "gondar");
    array_add(*spells, "gnusto");
    array_add(*spells, "aimfiz");


    quit := false;
    fullscreen := false;
    while !quit {
        current_time = get_time();
        dt := cast(float)(current_time - last_time);
        Clamp(*dt, 0, 0.1);
        last_time = current_time;

        Input.update_window_events();

        for Input.get_window_resizes() {
            Simp.update_window(it.window);

            if it.window == my_window {
                should_reinit := (it.width != window_width) || (it.height != window_height);

                window_width  = it.width;
                window_height = it.height;

                if should_reinit my_init_fonts();  // Resize the font for the new window size.
            }
        }

        for event: Input.events_this_frame {
            if event.type == .QUIT then quit = true;

            getrect_handle_event(event);

            if event.type == {
              case .KEYBOARD;
                if event.key_pressed && event.key_code == .ESCAPE {
                    active_widget_deactivate_all();
                }

                if event.key_pressed && event.key_code == .F11 {
                    ok, w, h := toggle_fullscreen(my_window, !fullscreen, null);
                    fullscreen = (ok && !fullscreen);
                }

              case .DRAG_AND_DROP_FILES;
                for dropped_files free(it);
                array_reset(*dropped_files);
                for event.files array_add(*dropped_files, copy_string(it));
            }
        }

        draw_one_frame(dt);

        reset_temporary_storage();
        sleep_milliseconds(10);
    }
}

draw_one_frame :: (dt: float) {
    proc := default_theme_procs[current_theme];
    my_theme = proc();
    set_default_theme(my_theme);  // Just in case we don't explicitly pass themes sometimes...!

    bg_col := my_theme.background_color;
    Simp.clear_render_target(bg_col.x, bg_col.y, bg_col.z, 1);

    x, y, width, height := get_dimensions(my_window, true);
    ui_per_frame_update(my_window, width, height, current_time);

    button_theme := my_theme.button_theme;
    button_theme.font = button_font;
    button_theme.enable_variable_frame_thickness = true;
    // 'k' is some resolution-adjusting unit of distance. Right now it is
    // 1/10 of the screen height, so, 108 pixels at 1920x1080.
    k := window_height * .1;
    r := get_rect(k*.5, 2.1*k, 3*k, k);

    button_theme.label_theme.alignment = .Left;
    pressed := button(r, "Hello, Sailor!", *button_theme);

    r.y -= k;
    button_theme.label_theme.alignment = .Center;
    pressed  = button(r, "there are", *button_theme);

    r.y -= k;
    button_theme.label_theme.alignment = .Right;
    pressed  = button(r, "69,105 leaves.", *button_theme);



    checkbox_theme := my_theme.checkbox_theme;
    checkbox_theme.font = button_font; // @Cleanup: We have to manually set a font for now.

    radio_theme := my_theme.checkbox_theme;
    radio_theme.font = button_font; // @Cleanup: We have to manually set a font for now.
    radio_theme.is_radio_button = true;

    r = get_rect(4*k, 1.8*k, 2*k, xx button_font.character_height);
    old_y := r.y;

    // Check Boxes:
    vertical_pad := r.h * .35;
    for * groceries {
        pressed := base_checkbox(r, it.name, it.should_get, *checkbox_theme, it_index);
        it.should_get ^= pressed;
        r.y -= button_font.character_height + vertical_pad;
    }

    // Radio Buttons:
    r = get_rect(6*k, old_y, 2*k, xx button_font.character_height);
    for spells {
        // This version of 'radio_button' will change current_spell when selected.
        pressed := radio_button(r, it, *current_spell, it_index, *radio_theme, it_index);

        r.y -= button_font.character_height + vertical_pad;
    }

    r = get_rect(8*k, old_y + 5 * (button_font.character_height + vertical_pad), 2*k, xx button_font.character_height);


    //
    // Text Input stuff:
    //

    text_theme := my_theme.text_input_theme;
    text_theme.font = button_font;

    r = get_rect(1*k, 4*k, 5*k, button_font.character_height*1.35);
    action_a, new_text_a := text_input(r, string_a, *text_theme);
    if action_a & .ENTERED  modify_string(*string_a, new_text_a);

    text_theme.alignment = .Center;
    r.y -= button_font.character_height * 1.5;
    action_b, new_text_b := text_input(r, string_b, *text_theme);
    if action_b & .ENTERED  modify_string(*string_b, new_text_b);

    text_theme.alignment = .Right;
    r.y -= button_font.character_height * 1.5;
    action_c, new_text_c := text_input(r, string_c, *text_theme);
    if action_c & .ENTERED  modify_string(*string_c, new_text_c);

    // The teas:
    r = get_rect(3*k, 7*k, 3*k, button_font.character_height*1.35);
    text_theme.alignment = .Left;
    action_t, new_text_t := text_input(r, string_t, *text_theme, auto_complete=auto_complete_teas, null);
    if action_t & .ENTERED  modify_string(*string_t, new_text_t);

    {
        r.y -= r.h;
 	    label_theme: Label_Theme;
 	    label_theme.alignment = .Left;
 	    label_theme.text_color = .{.5, .5, .5, 1};
        label(r, "This input field will auto-complete.", *label_theme);
    }

    //
    // Slider:
    //

    // Float value:
    slider_theme := my_theme.slider_theme;
    slider_theme.foreground.font = button_font;
    r = get_rect(7*k, 7*k, 3*k, button_font.character_height*1.35);
    slider(r, *slider_float_value, 0.0, 60.0, 3.0, *slider_theme, "", "fps");

    slider_theme.surface_style = .NUB;

    // Integer value:
    r.y -= r.h * 1.2;
    slider(r, *slider_int_value, 0, 10, 1, *slider_theme, "number ");


    button_height := window_height * .03;

    //
    // Dropdown stuff.
    //
    {
        r = get_rect(13.8*k, 4.1*k, 2.2*k, button_height);
        dropdown_theme := *my_theme.dropdown_theme;

        // The 'dropdown' function causes a popup to be created, which
        // gets rendered at the end of the frame when we call draw_popups().
        // The theme and choices array must remain valid until after that time!
        // The 'current_theme' pointer also needs to remain pointing at valid memory
        // until after that time, as that is when it will be changed.
        dropdown(r, THEME_NAMES, *current_theme, dropdown_theme);
    }

    //
    // Slidable Region stuff.
    //

    {
        r = get_rect(7*k, 1*k, 2*k, 5*k);

        theme := my_theme.slidable_region_theme;
        theme.orientation = .VERTICAL;
        theme.first_\background.shape.rounding_flags   = Rectangle_Shape.Rounding_Flags.NORTHEAST | .NORTHWEST;
        theme.second_background.shape.rounding_flags   = Rectangle_Shape.Rounding_Flags.SOUTHEAST | .SOUTHWEST;
        theme.first_\background.shape.roundedness_type = .RELATIVE_TO_WIDTH;
        theme.second_background.shape.roundedness_type = .RELATIVE_TO_WIDTH;

        state, left_or_top, right_or_bottom, divider := slidable_region(r, *theme);
        {
            xpad := em(1, button_font);
            ypad := .8 * button_font.character_height;

            orig_s := cut_top(left_or_top, ypad);
            junk, s := cut_left(orig_s, xpad);

            //
            // Using type_info, we can very quickly generate some checkboxes for
            // any enum_flags type. The loop below is the only code needed!
            //
            info := type_info(Damage_Resistance);
            stride := button_font.character_height + vertical_pad;
            s.h = stride;
            s.y -= stride;
            for name: info.names {
                value := cast(Damage_Resistance) info.values[it_index];

                checkbox_flags(s, name, *damage_resistance, value, *checkbox_theme, xx value);
                s.y -= stride;
            }
        }


        switch_to_bottom_rect(state);

        {
            // s := get_rect(8*k, 1*k, 5*k, 2*k);
            s := right_or_bottom;

            theme := my_theme.slidable_region_theme;
            theme.orientation = .HORIZONTAL;
            theme.divider_theme.rectangle_shape.frame_thickness_type = .RELATIVE_TO_WIDTH;
            theme.divider_theme.rectangle_shape.roundedness_type     = .RELATIVE_TO_WIDTH;

            // Disable drawing the background, since we are already inside a background that is fine.
            theme.first_background .color.w  = 0;
            theme.second_background.color.w = 0;
            theme.first_background .frame_color.w = 0;
            theme.second_background.frame_color.w = 0;

            state, left_or_top, right_or_bottom, divider := slidable_region(s, *theme);
            switch_to_bottom_rect(state);

            {
                //
                // Scrollable Region stuff.
                //

                {
//                    r = get_rect(10.5*k, 4*k, 1.8*k, 3*k);
                    region, inside := begin_scrollable_region(right_or_bottom);

                    NUM_BUTTONS :: 30;
                    // button_height = floor(inside.w * .22 + .5);

                    // @Incomplete: Add the scrolling offset when we have it.
                    // @Incomplete: Scroll value is in pixels, what happens if the screen changes resolution?
                    s := inside;
                    s.y = s.y + s.h - button_height;
                    s.h = button_height;
                    s.y += scroll_value;
                    button_theme.label_theme.alignment = .Center;
                    button_theme.font = null;

                    for 1..NUM_BUTTONS {
                        text := tprint("Button %", it);
                        pressed := button(s, text, *button_theme, it);

                        if  it != NUM_BUTTONS  {
                            s.y -= floor(button_height * 1.1 + 0.5);  // Just so r.y is in the right place for end_scrollable_region().
                        }
                    }

                    end_scrollable_region(region, s.x + s.w, s.y, *scroll_value);
                }
            }

            finish(state);
        }

        finish(state);
    }

    {
        //
 	    // Drag and drop scrollable region.
        // Submitted by Jens Frederich.
 	    //

 	    theme := my_theme.scrollable_region_theme;
 	    theme.region_background.shape.rounding_flags = 0;

        r = get_rect(9.5*k, 1*k, 4*k, 5*k);

 	    region, inside := begin_scrollable_region(r, *theme);

 	    label_height := window_height * .03;
 	    s := inside;
 	    s.y = s.y + s.h - label_height;
 	    s.h = label_height;
 	    s.y += scroll_value_dragdrop_region;

 	    label_theme := my_theme.label_theme;
 	    label_theme.alignment = .Left;

 	    if dropped_files {
 	  	    for dropped_files {
 	 	        label(s, it, *label_theme);
 	 	        s.y -= floor(label_height * 1.1 + 0.5);
 	 	    }
        } else {
 	 	    label(s, "Drag/drop files will appear here.", *label_theme);
        }

 	    end_scrollable_region(region, s.x + s.w, s.y, *scroll_value_dragdrop_region);
    }


    {
        //
        // Subwindows:
        //

        if !subwindows_initted {
            r := get_rect(7.5*k, 3*k, 4*k, 5*k);
            subwindow_info_text.rect = r;
            subwindow_info_text.draw                 = draw_subwindow_text;
            subwindow_info_text.title_text           = "Text";

            r = get_rect(9.5*k, 3*k, 3*k, 3.7*k);
            subwindow_info_circle.rect = r;
            subwindow_info_circle.draw                 = draw_subwindow_circle;
            subwindow_info_circle.title_text           = "Color Picker";
            subwindow_info_circle.fixed_aspect_ratio   = r.w/r.h;

            subwindows_initted = true;
        }

        theme := my_theme.subwindow_theme;

        if subwindow_info_text.open {  // The Subwindow starts open, but pressing the Close button can close it.
            subwindow_state := add_subwindow(*subwindow_info_text, *theme);
        }

        if subwindow_info_circle.open {  // The Subwindow starts open, but pressing the Close button can close it.
            theme.region_background.frame_color.w = 0;
            theme.region_background.color.w = 0;
            theme.title_bar.rectangle_shape.rounding_flags = Rectangle_Shape.Rounding_Flags.NORTHEAST | .NORTHWEST | .SOUTHEAST | .SOUTHWEST;
            subwindow_state := add_subwindow(*subwindow_info_circle, *theme);
        }
    }

    //
    // Draw the title:
    //

    label_theme := my_theme.label_theme;
    label_theme.font       = title_font;
    label_height := title_font.character_height*1.5;
    r = get_rect(0, window_height - label_height, xx window_width, label_height);
    label(r, "Some Widgets", *label_theme);


    draw_popups();  // This draws Subwindows as well.


    //
    // Swap buffers!
    //

    Simp.swap_buffers(my_window);
}

draw_subwindow_text :: (r: Rect, data: *void) {
    font := story_font;
    lines := split(TEXT_FIELD_1, "\n");

    K :: .5;
    color := Vector4.{K, K, K, 1};

    xpad := floor(font.default_line_spacing * .5 + .5);

    x := r.x + xpad;
    y := r.y + r.h - cast(float) font.default_line_spacing;
    for lines {
        trimmed := trim_right(it, " \t\r\n");
        Simp.draw_text(font, xx x, xx y, trimmed, color);
        y -= cast(float) font.default_line_spacing;
    }
}

draw_subwindow_circle :: (r: Rect, data: *void) {
    color_picker_theme := *my_theme.color_picker_theme;
    applied := color_picker(r, *picked_color, color_picker_theme);
}

my_init_fonts :: () {
    if !working_directory_set {
        // So that we can load our font, set to path of running executable.
        path := path_strip_filename(get_path_of_running_executable());
        set_working_directory(path);

        working_directory_set = true;
    }

    pixel_height := window_height / 24;
    my_font = Simp.get_font_at_size("data", "OpenSans-BoldItalic.ttf", pixel_height);
    assert(my_font != null);

    pixel_height /= 2;
    button_font = Simp.get_font_at_size("data", "OpenSans-BoldItalic.ttf", pixel_height);
    assert(button_font != null);

    pixel_height = window_height / 7;
    title_font = Simp.get_font_at_size("data", "Miama.otf", pixel_height);

    pixel_height = window_height / 30;
    story_font = Simp.get_font_at_size("data", "OpenSans-BoldItalic.ttf", pixel_height);
//    title_font = Simp.get_font_at_size("data", "OpenSans-BoldItalic.ttf", pixel_height);
}

Font :: Simp.Dynamic_Font;

my_font:     *Font;
button_font: *Font;
title_font:  *Font;
story_font:  *Font;

working_directory_set := false;

Simp  :: #import "Simp";
Input :: #import "Input";

#import "Window_Creation";

#import "Basic";
Basic :: #import "Basic"; // :CompilerBug  We need this to resolve to_lower for some reason?!
#import "Math";
#import "System";  // For get_path_of_running_executable. @Cleanup.
#import "String";  // For path_strip_filename. @Cleanup.

modify_string :: (ps: *string, new_value: string) {
    free(<<ps);
    <<ps = copy_string(new_value);
}
