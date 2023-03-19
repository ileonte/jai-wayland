#import "Basic";
#import "POSIX";

BLA :: struct {
    s: string;
    i: s32;
    link: wl_list;
}

#load "local_modules/wayland/wayland-scanner/common.jai";

main :: () {
    head: wl_list;
    bla: [3]BLA = .[
        .{"first",  0, .{}},
        .{"second", 1, .{}},
        .{"third",  2, .{}},
    ];

    wl_list_init(*head);
    for * bla {
        copy: *BLA = alloc(size_of(BLA));
        <<copy = <<it;
        wl_list_insert(head.prev, *copy.link);
    }

    for p: wl_list_each(BLA, *head) {
        for c: wl_list_each(BLA, *head) {
            print("% :: % '%' %\n", p.s, it_index, c.s, c.i);
        }
    }
    print("\n");
    for < wl_list_each(BLA, *head) {
        print("% '%' %\n", it_index, it.s, it.i);
    }
    print("=======================\n");

    array: wl_array;
    wl_array_init(*array);
    for bla {
        v := cast(*BLA) wl_array_add(*array, size_of(BLA));
        (<<v) = it;
    }
    print("%\n", array);
    for wl_array_each(BLA, *array) print("%\n", <<it);
}
