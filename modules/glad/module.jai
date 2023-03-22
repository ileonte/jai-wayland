#load "glad_core.jai";

using gl;

gl_load :: (procs: *GL_Procedures, GetProcAddress: GetProcAddressFunction) {
    info_struct := type_info(GL_Procedures);

    print("GL_LOAD\n");

    dest_bytes := cast(*u8) procs;
    table := get_type_table();

    // Get GL version.
    gl_version_major, gl_version_minor = gl_get_version();
    // print ("GL_VERSION = %.%\n", gl_version_major, gl_version_minor);
    if gl_version_major == 0 return;

    for * info_struct.members {
        if it.flags & .CONSTANT continue;

        is_intentional_void_pointer := cast(bool)(it.flags & .PROCEDURE_WITH_VOID_POINTER_TYPE_INFO);  // Let us use #type_info_procedures_are_void_pointers.
        if (it.type.type == .PROCEDURE) || is_intentional_void_pointer {
            ptype := cast(*Type_Info_Procedure) it.type;

            if !is_intentional_void_pointer {
                assert ((ptype.procedure_flags & .IS_ELSEWHERE) != 0,
                        "Proc '%' is not elsewhere! (member_address %, type_address %, procedure_flags = %, % arguments, % returns, index = %)",
                        it.name, it, ptype, formatInt(ptype.procedure_flags, base=16), ptype.argument_types.count, ptype.return_types.count,
                        array_find(table, it.type));
            }

            // Okay, do the work.
            c_string := it.name.data;  // Strings in Type_Info are guaranteed to be zero-terminated now.  -jblow, 23 December 2018

            address := GetProcAddress(c_string);
            // print("GLPROC: % -> %\n", it.name, address);
            if address {
                dest := cast(**void) (dest_bytes + it.offset_in_bytes);
                <<dest = address;
            }
        } else if it.type.type == .BOOL {
            poke := false;

            if begins_with(it.name, "GL_VERSION_") {
                major, minor := gl_parse_version(it.name);
                poke = ((gl_version_major >= major) || (gl_version_major == major && gl_version_minor >= minor));
            } else if begins_with(it.name, "GL_") || begins_with(it.name, "WGL_") || begins_with(it.name, "GLX_") {
                poke = gl_supports_extension(it.name);
            } else {
                assert(false, "Unexpected variable '%' in GL struct.", it.name);
            }

            if poke {
                //print ("% found\\n", it.name);
                dest := cast(*bool) (dest_bytes + it.offset_in_bytes);
                <<dest = true;
            }
        } else {
            if !begins_with(it.name, "gl_version_") {
                builder: String_Builder;
                print_type_to_builder(*builder, it.type);
                type_string := builder_to_string(*builder);
                defer free(type_string);

                assert(false, "Unexpected variable '%' in GL struct. (The type was: %).", it.name, type_string);
            }
        }
    }
}

#scope_file

#import "Basic";    // assert
#import "Compiler"; // get_type_table
#import "String";

gl_parse_version :: (version: string) -> major:s32, minor:s32 {
    major, minor : s32;
    scan2(version, "GL_VERSION_%_%", *major, *minor);
    return major, minor;
}

gl_get_version :: () -> major:s32, minor:s32 {
    major, minor: s32;

    if GL_VERSION_3_0 {
        assert(glGetIntegerv != null);
        glGetIntegerv(GL_MAJOR_VERSION, *major);
        glGetIntegerv(GL_MINOR_VERSION, *minor);
    }
    else {
        assert(glGetString != null);
        version_string := glGetString(GL_VERSION);
        if !version_string return major, minor;

        // @@ In OpenGL ES we should skip the prefix.
        scan2(to_string(version_string), "%.%", *major, *minor);
    }

    return major, minor;
}

gl_supports_extension :: (ext: string) -> bool {

    // Features are always initialized before extensions.
    if GL_VERSION_3_0 {
        num :s32= 0;
        assert(glGetIntegerv != null);
        glGetIntegerv(GL_NUM_EXTENSIONS, *num);
        for 0..num-1 {
            exti := to_string(glGetStringi(GL_EXTENSIONS, xx it));
            if ext == exti return true;
        }
        return false;
    }
    else {
        extn := to_string(glGetString(GL_EXTENSIONS));
        return contains(extn, ext);
    }
}

GetProcAddressFunction :: #type (proc: *u8) -> *void #foreign #c_call;
