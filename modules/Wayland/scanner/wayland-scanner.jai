/*
 * This is a pretty "dumb" port of `wayland-scanner`. It maintains a lot of the original
 * C constructs which don't necessarily make sense in Jai. I've only kept them around to
 * allow me to better compare and contrast between the two versions. More refactoring to
 * follow at a later time.
 *
 *   - 2023.03.19 @ileonte
 */

#import "String";

#load "expat.jai";
#load "common.jai";

SCANNER_VERSION :: "1.0.1";

XML_BUFFER_SIZE :: 16384;

Side :: enum { CLIENT; SERVER; }
Visibility :: enum { PRIVATE; PUBLIC; }
Identifier_Role :: enum { STANDALONE_IDENT; TRAILING_IDENT; };

Arg_Type :: enum {
    NEW_ID;
    INT;
    UNSIGNED;
    FIXED;
    STRING;
    OBJECT;
    ARRAY;
    FD;
}

Location :: struct {
    filename: string;
    line_number: int;
}

Description :: struct {
    summary: string;
    text: string;
}

Protocol :: struct {
    name: string;
    uppercase_name: string;
    interface_list: wl_list;
    type_index: int;
    null_run_length: int;
    copyright: string;
    description: *Description;
    core_headers: bool;
}

Interface :: struct {
    loc: Location;
    name: string;
    uppercase_name: string;
    version: int;
    since: int;
    request_list: wl_list;
    event_list: wl_list;
    enumeration_list: wl_list;
    link: wl_list;
    description: *Description;
}

Message :: struct {
    loc: Location;
    name: string;
    uppercase_name: string;
    arg_list: wl_list;
    link: wl_list;
    arg_count: int;
    new_id_count: int;
    type_index: int;
    all_null: int;
    destructor: bool;
    since: int;
    description: *Description;
}

Arg :: struct {
    name: string;
    type: Arg_Type;
    nullable: bool;
    has_interface_name: bool;
    interface_name: string;
    link: wl_list;
    summary: string;
    has_summary: bool;
    enumeration_name: string;
    has_enumeration_name: bool;
}

Enumeration :: struct {
    name: string;
    uppercase_name: string;
    entry_list: wl_list;
    link: wl_list;
    description: *Description;
    bitfield: bool;
    since: int;
}

Entry :: struct {
    name: string;
    uppercase_name: string;
    value: string;
    summary: string;
    has_summary: bool;
    since: int;
    link: wl_list;
    description: *Description;
}

Parse_Context :: struct {
    loc: Location;
    parser: XML_Parser;
    protocol: *Protocol;
    intf: *Interface;
    message: *Message;
    enumeration: *Enumeration;
    entry: *Entry;
    description: *Description;
    character_data: [..]u8;
}

strdup :: (src: *u8)    -> string { return copy_string(to_string(src)); }
strdup :: (src: string) -> string { return copy_string(src); }

uppercase_dup :: (src: *u8)    -> string { return to_upper_copy(to_string(src)); }
uppercase_dup :: (src: string) -> string { return to_upper_copy(src); }

fail :: (msg: string, args: ..Any, loc := #caller_location) #expand {
    print("Internal error (%:%): ", loc.fully_pathed_filename, loc.line_number, to_standard_error = true);
    print(msg, ..args, to_standard_error = true);
    print("\n", to_standard_error = true);
    exit(1);
}

fail :: (loc: *Location, msg: string, args: ..Any) {
    print("%:%: error: ", loc.filename, loc.line_number, to_standard_error = true);
    print(msg, ..args, to_standard_error = true);
    print("\n", to_standard_error = true);
    exit(1);
}

warn :: (loc: *Location, msg: string, args: ..Any) {
    print("%:%: warning: ", loc.filename, loc.line_number, to_standard_error = true);
    print(msg, ..args, to_standard_error = true);
    print("\n", to_standard_error = true);
}

is_nullable_type :: (arg: Arg) -> bool {
    return arg.type == .STRING || arg.type == .OBJECT;
}

create_message :: (loc: Location, name: string) -> *Message {
    message : *Message = alloc(size_of(Message));
    <<message = .{};
    message.loc = loc;
    message.name = strdup(name);
    message.uppercase_name = uppercase_dup(name);
    wl_list_init(*message.arg_list);
    return message;
}

create_arg :: (name: string) -> *Arg {
    ret : *Arg = alloc(size_of(Arg));
    <<ret = .{};
    ret.name = strdup(name);
    ret.has_interface_name = false;  // ??
    wl_list_init(*ret.link);
    return ret;
}

set_arg_type :: (arg: *Arg, type: string) -> bool {
    if type == {
        case "int"; arg.type = .INT;
        case "uint"; arg.type = .UNSIGNED;
        case "fixed"; arg.type = .FIXED;
        case "string"; arg.type = .STRING;
        case "array"; arg.type = .ARRAY;
        case "fd"; arg.type = .FD;
        case "new_id"; arg.type = .NEW_ID;
        case "object"; arg.type = .OBJECT;
        case; return false;
    }
    return true;
}

create_enumeration :: (name: string) -> *Enumeration {
    enumeration : *Enumeration = alloc(size_of(Enumeration));
    enumeration.name = strdup(name);
    enumeration.uppercase_name = uppercase_dup(name);
    enumeration.since = 1;
    wl_list_init(*enumeration.entry_list);
    return enumeration;
}

create_entry :: (name: string, value: string) -> *Entry {
    entry : *Entry = alloc(size_of(Entry));
    <<entry = .{};
    entry.name = strdup(name);
    entry.uppercase_name = uppercase_dup(name);
    entry.value = strdup(value);
    return entry;
}

create_interface :: (loc: Location, name: string, version: int) -> *Interface {
    intf : *Interface = alloc(size_of(Interface));
    <<intf = .{};
    intf.loc = loc;
    intf.name = strdup(name);
    intf.uppercase_name = uppercase_dup(name);
    intf.version = version;
    intf.since = 1;
    wl_list_init(*intf.request_list);
    wl_list_init(*intf.event_list);
    wl_list_init(*intf.enumeration_list);
    return intf;
}

strtouint :: (str: string) -> int {
    ret, ok, remainder := to_integer(str);
    if (!ok) return -1;
    if (ret < 0) return -1;
    if (remainder.count > 0) return -1;
    return ret;
}

validate_identifier :: (loc: *Location, str: string, role: Identifier_Role) {
    if !str.count fail(loc, "element name is empty");
    for 0..str.count - 1 {
        c := str[it];
        leading_char := (it == 0) && (role == .STANDALONE_IDENT);
        if (is_alpha(c) || c == #char "_" || (!leading_char && is_digit(c))) continue;
        if role == .TRAILING_IDENT fail(loc, "'%' is not a valid trailing identifier part", str);
        else fail(loc, "'%' is not a valid standalone identifier", str);
    }
}

version_from_since :: (ctx: *Parse_Context, since: string) -> int {
    version: int;
    if since.count {
        version = strtouint(since);
        if version < 0 {
            fail(*ctx.loc, "invalid integer ('%')", since);
        } else if version > ctx.intf.version {
            fail(*ctx.loc, "since (%) larger than version (%)", version, ctx.intf.version);
        }
    } else {
        version = 1;
    }
    return version;
}

start_element :: (data: *void, _element_name: *u8, atts: **u8) {
    ctx : *Parse_Context = data;
    name: string;
    type: string;
    has_type := false;
    interface_name: string;
    has_interface_name := false;
    value: string;
    has_value := false;
    summary: string;
    has_summary := false;
    since: string;
    has_since := false;
    allow_null: string;
    has_allow_null := false;
    enumeration_name: string;
    has_enumeration_name := false;
    bitfield: string;
    has_bitfield := false;
    version := 0;

    ctx.loc.line_number = cast(int) XML_GetCurrentLineNumber(ctx.parser);

    i := 0;
    while true {
        if !atts[i] break;
        n := to_string(atts[i]);
        v := to_string(atts[i + 1]);
        i += 2;

        if n == {
            case "name"; name = v;
            case "version";
                version = strtouint(v);
                if version < 0 fail(*ctx.loc, "wrong version ('%')", v);
            case "type"; type = v; has_type = true;
            case "value"; value = v; has_value = true;
            case "interface"; interface_name = v; has_interface_name = true;
            case "summary"; summary = v; has_summary = true;
            case "since"; since = v; has_since = true;
            case "allow-null"; allow_null = v; has_allow_null = true;
            case "enum"; enumeration_name = v; has_enumeration_name = true;
            case "bitfield"; bitfield = v; has_bitfield = true;
            case; warn(*ctx.loc, "unhandled attribute '%'", n);
        }
    }

    element_name := to_string(_element_name);
    if element_name == {
        case "protocol"; {
            if !name.count fail(*ctx.loc, "no protocol name given");
            validate_identifier(*ctx.loc, name, .STANDALONE_IDENT);
            ctx.protocol.name = strdup(name);
            ctx.protocol.uppercase_name = uppercase_dup(name);
        }
        case "copyright"; {}
        case "interface"; {
            if !name.count fail(*ctx.loc, "no interface name given");
            if !version fail(*ctx.loc, "no interface version given");

            validate_identifier(*ctx.loc, name, .STANDALONE_IDENT);
            ctx.intf = create_interface(ctx.loc, name, version);
            wl_list_insert(ctx.protocol.interface_list.prev, *ctx.intf.link);
        }
        case "request"; #through;
        case "event"; {
            if !name.count fail(*ctx.loc, "no message name given");

            validate_identifier(*ctx.loc, name, .STANDALONE_IDENT);
            message := create_message(ctx.loc, name);

            if element_name == "request" {
                wl_list_insert(ctx.intf.request_list.prev, *message.link);
            } else {
                wl_list_insert(ctx.intf.event_list.prev, *message.link);
            }

            message.destructor = (type == "destructor");

            version = version_from_since(ctx, since);
            if version < ctx.intf.since {
                warn(*ctx.loc, "since version (%) not increasing (%)", version, ctx.intf.since);
            }
            ctx.intf.since = version;
            message.since = version;

            if (name == "destroy") && !message.destructor {
                fail(*ctx.loc, "destroy request should be destructor type");
            }

            ctx.message = message;
        }
        case "arg"; {
            if !name.count fail(*ctx.loc, "no argument name given");
            validate_identifier(*ctx.loc, name, .STANDALONE_IDENT);

            arg := create_arg(name);
            if !set_arg_type(arg, type) {
                fail(*ctx.loc, "unknown type (%)", type);
            }

            if arg.type == {
                case .NEW_ID;
                    ctx.message.new_id_count += 1;
                    #through;
                case .OBJECT; {
                    if has_interface_name {
                        validate_identifier(*ctx.loc, interface_name, .STANDALONE_IDENT);
                        arg.has_interface_name = true;
                        arg.interface_name = strdup(interface_name);
                    }
                }
                case; {
                    if has_interface_name {
                        fail(*ctx.loc, "'interface' attribute not allowd for type '%'", type);
                    }
                }
            }

            if has_allow_null {
                if allow_null == {
                    case "true"; arg.nullable = true;
                    case "false"; arg.nullable = false;
                    case; fail(*ctx.loc, "invalid value for 'allow-null' attribute ('%')", allow_null);
                }
                if !is_nullable_type(arg) {
                    fail(*ctx.loc, "'allow-null' is only valid for objects, strings and arrays");
                }
            }

            arg.has_enumeration_name = has_enumeration_name;
            arg.has_summary = has_summary;
            if has_enumeration_name
                arg.enumeration_name = strdup(enumeration_name);
            if has_summary
                arg.summary = strdup(summary);

            wl_list_insert(ctx.message.arg_list.prev, *arg.link);
            ctx.message.arg_count += 1;
        }
        case "enum"; {
            if !name.count fail(*ctx.loc, "no enum name given");

            validate_identifier(*ctx.loc, name, .TRAILING_IDENT);
            enumeration := create_enumeration(name);

            enumeration.bitfield = false;
            if has_bitfield {
                if bitfield == {
                    case "false"; enumeration.bitfield = false;
                    case "true"; enumeration.bitfield = true;
                    case; fail(*ctx.loc, "invalid value ('%') for 'bitfield' attribute", bitfield);
                }
            }

            wl_list_insert(ctx.intf.enumeration_list.prev, *enumeration.link);
            ctx.enumeration = enumeration;
        }
        case "entry"; {
            if !name.count fail(*ctx.loc, "no entry name given");

            validate_identifier(*ctx.loc, name, .TRAILING_IDENT);
            entry := create_entry(name, value);
            version = version_from_since(ctx, since);

            if version < ctx.enumeration.since {
                warn(*ctx.loc, "since version not increasing");
            }
            ctx.enumeration.since = version;
            entry.since = version;

            entry.has_summary = has_summary;
            if has_summary
                entry.summary = strdup(summary);

            wl_list_insert(ctx.enumeration.entry_list.prev, *entry.link);
            ctx.entry = entry;
        }
        case "description"; {
            if !has_summary fail(*ctx.loc, "description without summary");

            description: *Description = alloc(size_of(Description));
            memset(description, 0, size_of(Description));
            description.summary = strdup(summary);

            if ctx.message ctx.message.description = description;
            else if ctx.entry ctx.entry.description = description;
            else if ctx.enumeration ctx.enumeration.description = description;
            else if ctx.intf ctx.intf.description = description;
            else if ctx.protocol ctx.protocol.description = description;

            ctx.description = description;
        }
    }
}

find_enumeration :: (protocol: *Protocol, intf: *Interface, attr: string) -> *Enumeration {
    found, interface_name, enumeration_name := split_from_right(attr, #char ".");
    if found {
        for intf: wl_list_each(Interface, *protocol.interface_list) {
            if intf.name != interface_name continue;
            for enumeration: wl_list_each(Enumeration, *intf.enumeration_list) {
                if enumeration.name == enumeration_name return enumeration;
            }
        }
    } else {
        for enumeration: wl_list_each(Enumeration, *intf.enumeration_list) {
            if enumeration.name == enumeration_name return enumeration;
        }
    }
    return null;
}

verify_arguments :: (ctx: *Parse_Context, intf: *Interface, messages: *wl_list, enumerations: *wl_list) {
    for msg: wl_list_each(Message, messages) {
        for arg: wl_list_each(Arg, *msg.arg_list) {
            if !arg.has_enumeration_name continue;

            if arg.type == {
                case .INT; {
                    enumeration := find_enumeration(ctx.protocol, intf, arg.enumeration_name);
                    if enumeration && enumeration.bitfield {
                        fail(*ctx.loc, "bitfield-style enum must only be referenced by uint");
                    }
                }
                case .UNSIGNED; {}
                case; fail(*ctx.loc, "enumeration-style argument has wrong type");
            }
        }
    }
}

end_element :: (data: *void, element_name: *u8) {
    ctx: *Parse_Context = data;
    name := to_string(element_name);

    if name == {
        case "copyright"; {
            ctx.protocol.copyright = strdup(ctx.character_data.data);
        }
        case "description"; {
            ctx.description.text = strdup(ctx.character_data.data);
            ctx.description = null;
        }
        case "enum"; {
            if wl_list_empty(*ctx.enumeration.entry_list) {
                fail(*ctx.loc, "enumeration '%' was empty", ctx.enumeration.name);
            }
            ctx.enumeration = null;
        }
        case "entry"; {
            ctx.entry = null;
        }
        case "protocol"; {
            for intf: wl_list_each(Interface, *ctx.protocol.interface_list) {
                verify_arguments(ctx, intf, *intf.request_list, *intf.enumeration_list);
                verify_arguments(ctx, intf, *intf.event_list,   *intf.enumeration_list);
            }
        }
    }

    array_reset_keeping_memory(*ctx.character_data);
}

character_data :: (data: *void, s: *u8, len: s32) {
    ctx: *Parse_Context = data;
    array_reserve(*ctx.character_data, ctx.character_data.count + len + 1);
    dst := ctx.character_data.data + ctx.character_data.count;
    memcpy(dst, s, len);
    dst[len] = 0;
    ctx.character_data.count += len;
}

get_sig :: (msg: *Message) -> string {
    ret: [..]u8;
    array_reserve(*ret, 16);
    for arg: wl_list_each(Arg, *msg.arg_list) {
        if (arg.type == .OBJECT || arg.type == .STRING) && arg.nullable  array_add(*ret, #char "?");

        if arg.type == {
            case .INT; array_add(*ret, #char "i");
            case .NEW_ID; {
                if !arg.has_interface_name {
                    array_add(*ret, #char "s");
                    array_add(*ret, #char "u");
                }
                array_add(*ret, #char "n");
            }
            case .UNSIGNED; array_add(*ret, #char "u");
            case .FIXED; array_add(*ret, #char "f");
            case .STRING; array_add(*ret, #char "s");
            case .OBJECT; array_add(*ret, #char "o");
            case .ARRAY; array_add(*ret, #char "a");
            case .FD; array_add(*ret, #char "h");
        }
    }
    zero := array_add(*ret);
    <<zero = 0;
    return to_string(ret.data);
}

_indent_data: [..]u8;
make_spacing :: inline (count: s64) -> string {
    if _indent_data.count < count {
        array_reserve(*_indent_data, count + 1);
        memset(_indent_data.data, #char " ", count);
        _indent_data.data[count] = 0;
        _indent_data.count = count;
    }
    ret: string;
    ret.data = _indent_data.data;
    ret.count = count;
    return ret;
}

emit_header :: (ctx: *Parse_Context) {
    tpl :: #string DONE
/*
 * Auto-generated by `wayland-scanner` version %
 * Protocol: %
 */

DONE
    print(tpl, SCANNER_VERSION, ctx.protocol.name);
}

emit_id_list :: (names: *[..]string, types: *[..]string, values: *[..]string,
    as_constants := true, indent := "", reset_arrays := true)
{
    if names.count != types.count fail("internal error"); // ????
    if names.count != values.count fail("internal error"); // ????

    max_name_len := 0;
    for * <<names max_name_len = max(max_name_len, it.count);

    max_type_len := 0;
    for * <<types max_type_len = max(max_type_len, it.count);

    for i: 0..names.count - 1 {
        name := names.data[i];
        type := types.data[i];
        val  := values.data[i];

        ending := ifx ends_with(val, "}") "" else ";";

        suffix := make_spacing(max_name_len - name.count);
        print("%0%0%0 :", indent, name, suffix);

        if max_type_len > 0 {
            suffix := make_spacing(max_type_len - type.count);
            print(" %0%0 ", type, suffix);
        }

        if val.count print("% %", ifx as_constants ":" else "=", val);
        print("%\n", ending);
    }

    if reset_arrays {
        array_reset_keeping_memory(names);
        array_reset_keeping_memory(types);
        array_reset_keeping_memory(values);
    }
}

isdigit :: (char: u8) -> bool {
    return (char >= #char "0") && (char <= #char "9");
}

emit_export_scope :: (ctx: *Parse_Context) {
    names: [..]string;
    types: [..]string;
    vals : [..]string;

    last_intf := *ctx.protocol.interface_list;
    for intf: wl_list_each(Interface, *ctx.protocol.interface_list) {
        print("%_interface: wl_interface;\n", intf.name);
        print("% :: struct {\n", intf.name);
        print("    #as _proxy: wl_proxy;\n");
        print("    _interface_ :: *%1_interface;\n\n", intf.name);

        display_tpl :: #string DONE
    connect                :: wl_display_connect;
    connect_to_fd          :: wl_display_connect_to_fd;
    disconnect             :: wl_display_disconnect;
    get_fd                 :: wl_display_get_fd;
    dispatch               :: wl_display_dispatch;
    dispatch_queue         :: wl_display_dispatch_queue;
    dispatch_queue_pending :: wl_display_dispatch_queue_pending;
    dispatch_pending       :: wl_display_dispatch_pending;
    get_error              :: wl_display_get_error;
    get_protocol_error     :: wl_display_get_protocol_error;
    flush                  :: wl_display_flush;
    roundtrip_queue        :: wl_display_roundtrip_queue;
    roundtrip              :: wl_display_roundtrip;
    create_queue           :: wl_display_create_queue;
    prepare_read_queue     :: wl_display_prepare_read_queue;
    prepare_read           :: wl_display_prepare_read;
    cancel_read            :: wl_display_cancel_read;
    read_events            :: wl_display_read_events;

DONE
        if intf.name == "wl_display" print(display_tpl);

        for e: wl_list_each(Enumeration, *intf.enumeration_list) {
            print("    /* ENUM: %::% */\n", intf.name, e.name);
            for member: wl_list_each(Entry, *e.entry_list) {
                array_add(*names, sprint("%_%", e.name, member.name));
                array_add(*types, "u32");
                array_add(*vals, member.value);
            }
            emit_id_list(*names, *types, *vals, indent = "    ");
            print("\n");
        }

        basic_tpl :: #string DONE
    set_user_data :: inline (self: *%1, user_data: *void) #c_call {
        wl_proxy.set_user_data(self, user_data);
    }

    get_user_data :: inline (self: *%1) -> *void #c_call {
        return wl_proxy.get_user_data(self);
    }

    get_version :: inline (self: *%1) -> u32 #c_call {
        return wl_proxy.get_version(self);
    }

DONE
        print(basic_tpl, intf.name);

        has_destructor := false;
        has_destroy := false;
        for m: wl_list_each(Message, *intf.request_list) {
            if m.destructor        has_destructor = true;
            if m.name == "destroy" has_destroy = true;
        }
        if !has_destructor && has_destroy {
            fail(*intf.loc, "Interface '%' has method named 'destroy' but no destructor", intf.name);
        }

        if !has_destroy && intf.name != "wl_display" {
            destroy_tpl :: #string DONE
    destroy :: inline (self: *%1) #c_call {
        wl_proxy.destroy(self);
    }

DONE
            print(destroy_tpl, intf.name);
        }

        last_req := *intf.request_list;
        for m: wl_list_each(Message, *intf.request_list) {
            if m.new_id_count > 1 {
                warn(*m.loc, "request '%::%' has more than one `new_arg` id, not emmitting stub", intf.name, m.name);
                continue;
            }

            new_id_arg: *Arg = null;
            for a: wl_list_each(Arg, *m.arg_list) {
                if a.type == .NEW_ID {
                    new_id_arg = a;
                    break;
                }
            }

            ret_type_str: string;
            if new_id_arg && !new_id_arg.has_interface_name ret_type_str = " -> *void";
            else if new_id_arg ret_type_str = sprint(" -> *%", new_id_arg.interface_name);
            else ret_type_str = "";

            print("    % :: inline (self: *%", m.name, intf.name);
            for a: wl_list_each(Arg, *m.arg_list) {
                if a.type == .NEW_ID && !a.has_interface_name {
                    print(", intf: *wl_interface, version: u32");
                    continue;
                } else if a.type == .NEW_ID {
                    continue;
                }
                print(", %: ", a.name);
                if a.type == {
                    case .UNSIGNED; print("u32");
                    case .FIXED; print("wl_fixed_t");
                    case .STRING; print("*u8");
                    case .OBJECT; print("*%", a.interface_name);
                    case .ARRAY; print("*wl_array");
                    case .INT; #through;
                    case .FD; #through;
                    case; print("s32");
                }
            }
            print(")% #c_call {\n", ret_type_str);
            if new_id_arg print("        ret: *wl_proxy = ");
            else print("        ");
            print("wl_proxy.marshal_flags(\n");
            print("            self, %_%,\n", intf.uppercase_name, m.uppercase_name);

            if new_id_arg {
                if new_id_arg.has_interface_name print("            *%_interface", new_id_arg.interface_name);
                else print("            intf");
            } else {
                print("            null");
            }

            if new_id_arg && !new_id_arg.has_interface_name print(", version");
            else print(", wl_proxy.get_version(self)");

            print(", %", ifx m.destructor "WL_MARSHAL_FLAG_DESTROY" else "0");

            first_arg := m.arg_list.next;
            for a: wl_list_each(Arg, *m.arg_list) {
                comma := ifx *a.link == first_arg ",\n            " else ", ";
                if a.type == .NEW_ID {
                    if !a.has_interface_name print("%intf.name, version", comma);
                    print("%null", comma);
                } else {
                    print("%0%0", comma, a.name);
                }
            }

            print(");\n");
            if new_id_arg && !new_id_arg.has_interface_name print("        return cast(*void) ret;\n");
            else if new_id_arg print("        return cast(*%) ret;\n", new_id_arg.interface_name);
            print("    }\n");
            if !wl_list_empty(*intf.event_list) || (m.link.next != last_req) print("\n");
        }

        listener_tpl :: #string DONE
    add_listener :: inline (self: *%1, listener: *%1_listener, data: *void) -> s32 #c_call {
        return wl_proxy.add_listener(self, cast(*generic_c_call) listener, data);
    }
DONE
        if !wl_list_empty(*intf.event_list) print(listener_tpl, intf.name);

        print("}\n");
        if (intf.link.next != last_intf) || !wl_list_empty(*intf.request_list) print("\n");

        opcode := 0;
        for msg: wl_list_each(Message, *intf.request_list) {
            array_add(*names, sprint("%_%", intf.uppercase_name, msg.uppercase_name));
            array_add(*types, "u32");
            array_add(*vals,  sprint("%", opcode));
            opcode += 1;
        }
        for msg: wl_list_each(Message, *intf.request_list) {
            array_add(*names, sprint("%_%_SINCE", intf.uppercase_name, msg.uppercase_name));
            array_add(*types, "u32");
            array_add(*vals,  sprint("%", msg.since));
        }
        for msg: wl_list_each(Message, *intf.event_list) {
            array_add(*names, sprint("%_%_SINCE", intf.uppercase_name, msg.uppercase_name));
            array_add(*types, "u32");
            array_add(*vals,  sprint("%", msg.since));
        }
        emit_id_list(*names, *types, *vals);
        print("\n");

        if wl_list_empty(*intf.event_list) continue;

        print("%_listener :: struct {\n", intf.name);
        for event: wl_list_each(Message, *intf.event_list) {
            array_add(*names, event.name);
            array_add(*types, "");
            array_add(*vals,  sprint("_stubs_.%", event.name));
        }
        emit_id_list(*names, *types, *vals, as_constants = false, indent = "    ");

        print("\n");
        print("    _stubs_ :: struct {\n");
        for event: wl_list_each(Message, *intf.event_list) {
            print("        % :: (data: *void,\n            self: *%0%",
                event.name, intf.name,
                ifx event.arg_count ",\n            " else "");

            last_arg := *event.arg_list;
            for arg: wl_list_each(Arg, *event.arg_list) {
                print("%0%0: ", ifx arg.name != "interface" "" else "_", arg.name);
                if arg.type == {
                    case .OBJECT; {
                        if !arg.has_interface_name print("*void");
                        else print("*%", arg.interface_name);
                    }
                    case .NEW_ID; print("*%", arg.interface_name);
                    case .INT; #through;
                    case .FD; print("s32");
                    case .UNSIGNED; print("u32");
                    case .FIXED; print("wl_fixed_t");
                    case .STRING; print("*u8");
                    case .ARRAY; print("*wl_array");
                }
                if arg.link.next != last_arg print(",\n            ");
            }
            print(") -> void #c_call {}\n");
        }
        print("    }\n");

        print("}\n\n");
    }
}

emit_module_scope :: (ctx: *Parse_Context) {
    print("\n#scope_module\n%_protocol_init :: () {\n", ctx.protocol.name);

    StorageMap :: struct {
        intf: *Interface;
        msg: *Message;
        storage_idx: s64;
    }
    storage_map: [..]StorageMap;
    storage_idx := 0;

    print("    %_types_storage = .[\n", ctx.protocol.name);
    print("        /* __DUMMY__ */\n");
    print("        null,  // %\n", storage_idx);

    array_add(*storage_map, .{null, null, 0});
    storage_idx += 1;

    for intf: wl_list_each(Interface, *ctx.protocol.interface_list) {
        for msg: wl_list_each(Message, *intf.request_list) {
            if !msg.arg_count continue;

            array_add(*storage_map, .{intf, msg, storage_idx});
            print("        /* REQUEST: %::% */\n", intf.name, msg.name);
            for arg: wl_list_each(Arg, *msg.arg_list) {
                if !arg.has_interface_name print("        null,  // %\n", storage_idx);
                else print("        *%_interface,   // %\n", arg.interface_name, storage_idx);
                storage_idx += 1;
            }
        }
        for msg: wl_list_each(Message, *intf.event_list) {
            if !msg.arg_count continue;

            array_add(*storage_map, .{intf, msg, storage_idx});
            print("        /* EVENT: %::% */\n", intf.name, msg.name);
            for arg: wl_list_each(Arg, *msg.arg_list) {
                if !arg.has_interface_name print("        null,  // %\n", storage_idx);
                else print("        *%_interface,  // %\n", arg.interface_name, storage_idx);
                storage_idx += 1;
            }
        }
    }
    print("    ];\n\n");

    map := storage_map.data;
    last := *ctx.protocol.interface_list;
    has_display_intf := false;
    for intf: wl_list_each(Interface, *ctx.protocol.interface_list) {
        if intf.name == "wl_display" has_display_intf = true;

        req_idx := 0;
        for msg: wl_list_each(Message, *intf.request_list) {
            sig := get_sig(msg);
            defer free(sig.data);
            print("    %_requests[%] = .{\"%\", \"%\", %_types_storage.data + %};\n",
                intf.name, req_idx, msg.name, sig, ctx.protocol.name,
                ifx msg.arg_count map.storage_idx else 0);
            req_idx += 1;
            if msg.arg_count map += 1;
        }

        event_idx := 0;
        for msg: wl_list_each(Message, *intf.event_list) {
            sig := get_sig(msg);
            defer free(sig.data);
            print("    %_events[%] = .{\"%\", \"%\", %_types_storage.data + %};\n",
                intf.name, event_idx, msg.name, sig, ctx.protocol.name,
                ifx msg.arg_count map.storage_idx else 0);
            event_idx += 1;
            if msg.arg_count map += 1;
        }

        print("    %_interface = .{\n", intf.name);
        print("        \"%\", %,\n", intf.name, intf.version);
        print("        %, %,\n",
            ifx req_idx sprint("%_requests.count", intf.name) else "0",
            ifx req_idx sprint("%_requests.data", intf.name) else "null");
        print("        %, %,\n",
            ifx event_idx sprint("%_events.count", intf.name) else "0",
            ifx event_idx sprint("%_events.data", intf.name) else "null");
        print("    };\n%", ifx intf.link.next != last "\n" else "");
    }

    print("}\n\n");

    display_tpl :: #string DONE
wl_display_connect                :: (name: *u8) -> *wl_display #foreign libwayland_client;
wl_display_connect_to_fd          :: (fd: s32) -> *wl_display #foreign libwayland_client;
wl_display_disconnect             :: (display: *wl_display) -> void #foreign libwayland_client;
wl_display_get_fd                 :: (display: *wl_display) -> s32 #foreign libwayland_client;
wl_display_dispatch               :: (display: *wl_display) -> s32 #foreign libwayland_client;
wl_display_dispatch_queue         :: (display: *wl_display, queue: wl_event_queue) -> s32 #foreign libwayland_client;
wl_display_dispatch_queue_pending :: (display: *wl_display, queue: wl_event_queue) -> s32 #foreign libwayland_client;
wl_display_dispatch_pending       :: (display: *wl_display) -> s32 #foreign libwayland_client;
wl_display_get_error              :: (display: *wl_display) -> s32 #foreign libwayland_client;
wl_display_get_protocol_error     :: (display: *wl_display, intf: **wl_interface, id: *u32) -> u32 #foreign libwayland_client;
wl_display_flush                  :: (display: *wl_display) -> s32 #foreign libwayland_client;
wl_display_roundtrip_queue        :: (display: *wl_display, queue: *wl_event_queue) -> s32 #foreign libwayland_client;
wl_display_roundtrip              :: (display: *wl_display) -> s32 #foreign libwayland_client;
wl_display_create_queue           :: (display: *wl_display) -> *wl_event_queue #foreign libwayland_client;
wl_display_prepare_read_queue     :: (display: *wl_display, queue: *wl_event_queue) -> s32 #foreign libwayland_client;
wl_display_prepare_read           :: (display: *wl_display) -> s32 #foreign libwayland_client;
wl_display_cancel_read            :: (display: *wl_display) -> void #foreign libwayland_client;
wl_display_read_events            :: (display: *wl_display) -> s32 #foreign libwayland_client;
DONE
    if has_display_intf {
        print(display_tpl);
        print("\n");
    }
}

emit_file_scope :: (ctx: *Parse_Context) {
    print("\n#scope_file\n");

    print("%_types_storage: []*wl_interface;\n\n", ctx.protocol.name);

    last := *ctx.protocol.interface_list;
    for intf: wl_list_each(Interface, *ctx.protocol.interface_list) {
        num_requests := wl_list_length(*intf.request_list);
        num_events   := wl_list_length(*intf.event_list);
        if num_requests print("%_requests: [%]wl_message;\n", intf.name, num_requests);
        if num_events   print("%_events  : [%]wl_message;\n", intf.name, num_events);
        print("\n");
    }

    for intf: wl_list_each(Interface, *ctx.protocol.interface_list) {
        print("#assert size_of(%1) == 0 \"wayland-scanner bug: %1 is non-empty\";\n", intf.name);
    }
}

main :: () {
    args := get_command_line_arguments();
    defer array_reset(*args);

    if args.count != 2 {
        print("Usage: % <path>\n", args[0]);
        exit(1);
    }

    ctx: Parse_Context;
    protocol: Protocol;

    memset(*protocol, 0, size_of(Protocol));
    wl_list_init(*protocol.interface_list);
    // protocol.core_headers = core_headers;

    memset(*ctx, 0, size_of(Parse_Context));
    ctx.protocol = *protocol;
    ctx.loc.filename = args[1];

    input := open(ctx.loc.filename.data, O_RDONLY);
    if input < 0 {
        print("Can not open '%' for reading: %\n", ctx.loc.filename, errno());
        exit(1);
    }
    defer close(input);

    ctx.parser = XML_ParserCreate(null);
    XML_SetUserData(ctx.parser, *ctx);
    XML_SetElementHandler(ctx.parser,
        (data: *void, element_name: *u8, atts: **u8) -> void #c_call {
            jc: Context;
            push_context jc { start_element(data, element_name, atts); }
        },
        (data: *void, name: *u8) -> void #c_call {
            jc: Context;
            push_context jc { end_element(data, name); }
        });
    XML_SetCharacterDataHandler(ctx.parser,
        (data: *void, s: *u8, len: s32) -> void #c_call {
            jc: Context;
            push_context jc { character_data(data, s, len); }
        });

    while true {
        buf := XML_GetBuffer(ctx.parser, XML_BUFFER_SIZE);
        len := read(input, buf, XML_BUFFER_SIZE);
        if len < 0 {
            print("Failed to read from '%': %\n", ctx.loc.filename, errno());
            exit(1);
        }

        if XML_ParseBuffer(ctx.parser, cast(s32) len, cast(s32) (len == 0)) == .ERROR {
            print("Error parsing XML at line % col %: %\n",
				XML_GetCurrentLineNumber(ctx.parser),
				XML_GetCurrentColumnNumber(ctx.parser),
				XML_ErrorString(XML_GetErrorCode(ctx.parser)));
            exit(1);
        }

        if !len break;
    }

    XML_ParserFree(ctx.parser);

    emit_header(*ctx);
    emit_export_scope(*ctx);
    emit_module_scope(*ctx);
    emit_file_scope(*ctx);
}
