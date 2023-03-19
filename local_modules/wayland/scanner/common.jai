#import "Basic";
#import "POSIX";

#load "../list.jai";
#load "../array.jai";

wl_list_init :: (list: *wl_list) {
    list.prev = list;
    list.next = list;
}

wl_list_insert :: (list: *wl_list, elm: *wl_list) {
    elm.prev = list;
	elm.next = list.next;
	list.next = elm;
	elm.next.prev = elm;
}

wl_list_remove :: (elm: *wl_list) {
	elm.prev.next = elm.next;
	elm.next.prev = elm.prev;
	elm.next = null;
	elm.prev = null;
}

wl_list_length :: (list: *wl_list) -> s32 {
    ret: s32 = 0;
    e := list.next;
    while e != list {
        ret += 1;
        e = e.next;
    }
    return ret;
}

wl_list_empty :: (list: *wl_list) -> s32 {
    return cast(s32) (list.next == list);
}

wl_list_insert_list :: (list: *wl_list, other: *wl_list) {
    if wl_list_empty(other) return;
	other.next.prev = list;
	other.prev.next = list.next;
	list.next.prev = other.prev;
	list.next = other.next;
}

wl_array_init :: (array: *wl_array) {
    memset(array, 0, size_of(wl_array));
}

wl_array_destroy :: (array: *wl_array) {
    free(array.data);
    array.data = cast(*void) 4;
}

wl_array_add :: (array: *wl_array, size: s64) -> *void {
    to_alloc: s64 = ifx (array.alloc > 0) array.alloc else 16;
    while to_alloc < array.size + size {
        to_alloc *= 2;
    }
    if array.alloc < to_alloc {
        data := realloc(array.data, to_alloc, array.alloc);
        if !data return null;
        array.data = data;
        array.alloc = to_alloc;
    }

    ret := cast(*u8)array.data + array.size;
    array.size += size;
    return ret;
}

wl_array_copy :: (array: *wl_array, source: *wl_array) -> s32 {
    if (array.size < source.size) {
        if (!wl_array_add(array, source.size - array.size)) return -1;
    } else {
        array.size = source.size;
    }
    if (source.size > 0) memcpy(array.data, source.data, source.size);
    return 0;
}
