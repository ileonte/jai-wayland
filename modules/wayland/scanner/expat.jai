//
// This file was auto-generated using the following command:
//
// jai generate.jai
//



Expat_INCLUDED :: 1;

Expat_External_INCLUDED :: 1;

XML_ENABLE_VISIBILITY :: 0;

XML_TRUE :: cast(XML_Bool)1;
XML_FALSE :: cast(XML_Bool)0;

XML_GetErrorLineNumber :: XML_GetCurrentLineNumber;
XML_GetErrorColumnNumber :: XML_GetCurrentColumnNumber;
XML_GetErrorByteIndex :: XML_GetCurrentByteIndex;

XML_MAJOR_VERSION :: 2;
XML_MINOR_VERSION :: 5;
XML_MICRO_VERSION :: 0;

XML_Char :: u8;
XML_LChar :: u8;

XML_Index :: s64;
XML_Size :: u64;

XML_ParserStruct :: struct {}
XML_Parser :: *XML_ParserStruct;

XML_Bool :: u8;

/* The XML_Status enum gives the possible return values for several
API functions.  The preprocessor #defines are included so this
stanza can be added to code that still needs to support older
versions of Expat 1.95.x:

#ifndef XML_STATUS_OK
#define XML_STATUS_OK    1
#define XML_STATUS_ERROR 0
#endif

Otherwise, the #define hackery is quite ugly and would have been
dropped.
*/
XML_Status :: enum u32 {
    ERROR     :: 0;

    OK        :: 1;

    SUSPENDED :: 2;

    XML_STATUS_ERROR     :: ERROR;

    XML_STATUS_OK        :: OK;

    XML_STATUS_SUSPENDED :: SUSPENDED;
}

XML_Error :: enum u32 {
    NONE                             :: 0;
    NO_MEMORY                        :: 1;
    SYNTAX                           :: 2;
    NO_ELEMENTS                      :: 3;
    INVALID_TOKEN                    :: 4;
    UNCLOSED_TOKEN                   :: 5;
    PARTIAL_CHAR                     :: 6;
    TAG_MISMATCH                     :: 7;
    DUPLICATE_ATTRIBUTE              :: 8;
    JUNK_AFTER_DOC_ELEMENT           :: 9;
    PARAM_ENTITY_REF                 :: 10;
    UNDEFINED_ENTITY                 :: 11;
    RECURSIVE_ENTITY_REF             :: 12;
    ASYNC_ENTITY                     :: 13;
    BAD_CHAR_REF                     :: 14;
    BINARY_ENTITY_REF                :: 15;
    ATTRIBUTE_EXTERNAL_ENTITY_REF    :: 16;
    MISPLACED_XML_PI                 :: 17;
    UNKNOWN_ENCODING                 :: 18;
    INCORRECT_ENCODING               :: 19;
    UNCLOSED_CDATA_SECTION           :: 20;
    EXTERNAL_ENTITY_HANDLING         :: 21;
    NOT_STANDALONE                   :: 22;
    UNEXPECTED_STATE                 :: 23;
    ENTITY_DECLARED_IN_PE            :: 24;
    FEATURE_REQUIRES_XML_DTD         :: 25;
    CANT_CHANGE_FEATURE_ONCE_PARSING :: 26;

    UNBOUND_PREFIX                   :: 27;

    UNDECLARING_PREFIX               :: 28;
    INCOMPLETE_PE                    :: 29;
    XML_DECL                         :: 30;
    TEXT_DECL                        :: 31;
    PUBLICID                         :: 32;
    SUSPENDED                        :: 33;
    NOT_SUSPENDED                    :: 34;
    ABORTED                          :: 35;
    FINISHED                         :: 36;
    SUSPEND_PE                       :: 37;

    RESERVED_PREFIX_XML              :: 38;
    RESERVED_PREFIX_XMLNS            :: 39;
    RESERVED_NAMESPACE_URI           :: 40;

    INVALID_ARGUMENT                 :: 41;

    NO_BUFFER                        :: 42;

    AMPLIFICATION_LIMIT_BREACH       :: 43;

    XML_ERROR_NONE                             :: NONE;
    XML_ERROR_NO_MEMORY                        :: NO_MEMORY;
    XML_ERROR_SYNTAX                           :: SYNTAX;
    XML_ERROR_NO_ELEMENTS                      :: NO_ELEMENTS;
    XML_ERROR_INVALID_TOKEN                    :: INVALID_TOKEN;
    XML_ERROR_UNCLOSED_TOKEN                   :: UNCLOSED_TOKEN;
    XML_ERROR_PARTIAL_CHAR                     :: PARTIAL_CHAR;
    XML_ERROR_TAG_MISMATCH                     :: TAG_MISMATCH;
    XML_ERROR_DUPLICATE_ATTRIBUTE              :: DUPLICATE_ATTRIBUTE;
    XML_ERROR_JUNK_AFTER_DOC_ELEMENT           :: JUNK_AFTER_DOC_ELEMENT;
    XML_ERROR_PARAM_ENTITY_REF                 :: PARAM_ENTITY_REF;
    XML_ERROR_UNDEFINED_ENTITY                 :: UNDEFINED_ENTITY;
    XML_ERROR_RECURSIVE_ENTITY_REF             :: RECURSIVE_ENTITY_REF;
    XML_ERROR_ASYNC_ENTITY                     :: ASYNC_ENTITY;
    XML_ERROR_BAD_CHAR_REF                     :: BAD_CHAR_REF;
    XML_ERROR_BINARY_ENTITY_REF                :: BINARY_ENTITY_REF;
    XML_ERROR_ATTRIBUTE_EXTERNAL_ENTITY_REF    :: ATTRIBUTE_EXTERNAL_ENTITY_REF;
    XML_ERROR_MISPLACED_XML_PI                 :: MISPLACED_XML_PI;
    XML_ERROR_UNKNOWN_ENCODING                 :: UNKNOWN_ENCODING;
    XML_ERROR_INCORRECT_ENCODING               :: INCORRECT_ENCODING;
    XML_ERROR_UNCLOSED_CDATA_SECTION           :: UNCLOSED_CDATA_SECTION;
    XML_ERROR_EXTERNAL_ENTITY_HANDLING         :: EXTERNAL_ENTITY_HANDLING;
    XML_ERROR_NOT_STANDALONE                   :: NOT_STANDALONE;
    XML_ERROR_UNEXPECTED_STATE                 :: UNEXPECTED_STATE;
    XML_ERROR_ENTITY_DECLARED_IN_PE            :: ENTITY_DECLARED_IN_PE;
    XML_ERROR_FEATURE_REQUIRES_XML_DTD         :: FEATURE_REQUIRES_XML_DTD;
    XML_ERROR_CANT_CHANGE_FEATURE_ONCE_PARSING :: CANT_CHANGE_FEATURE_ONCE_PARSING;

    XML_ERROR_UNBOUND_PREFIX                   :: UNBOUND_PREFIX;

    XML_ERROR_UNDECLARING_PREFIX               :: UNDECLARING_PREFIX;
    XML_ERROR_INCOMPLETE_PE                    :: INCOMPLETE_PE;
    XML_ERROR_XML_DECL                         :: XML_DECL;
    XML_ERROR_TEXT_DECL                        :: TEXT_DECL;
    XML_ERROR_PUBLICID                         :: PUBLICID;
    XML_ERROR_SUSPENDED                        :: SUSPENDED;
    XML_ERROR_NOT_SUSPENDED                    :: NOT_SUSPENDED;
    XML_ERROR_ABORTED                          :: ABORTED;
    XML_ERROR_FINISHED                         :: FINISHED;
    XML_ERROR_SUSPEND_PE                       :: SUSPEND_PE;

    XML_ERROR_RESERVED_PREFIX_XML              :: RESERVED_PREFIX_XML;
    XML_ERROR_RESERVED_PREFIX_XMLNS            :: RESERVED_PREFIX_XMLNS;
    XML_ERROR_RESERVED_NAMESPACE_URI           :: RESERVED_NAMESPACE_URI;

    XML_ERROR_INVALID_ARGUMENT                 :: INVALID_ARGUMENT;

    XML_ERROR_NO_BUFFER                        :: NO_BUFFER;

    XML_ERROR_AMPLIFICATION_LIMIT_BREACH       :: AMPLIFICATION_LIMIT_BREACH;
}

XML_Content_Type :: enum u32 {
    EMPTY  :: 1;
    ANY    :: 2;
    MIXED  :: 3;
    NAME   :: 4;
    CHOICE :: 5;
    SEQ    :: 6;

    XML_CTYPE_EMPTY  :: EMPTY;
    XML_CTYPE_ANY    :: ANY;
    XML_CTYPE_MIXED  :: MIXED;
    XML_CTYPE_NAME   :: NAME;
    XML_CTYPE_CHOICE :: CHOICE;
    XML_CTYPE_SEQ    :: SEQ;
}

XML_Content_Quant :: enum u32 {
    NONE :: 0;
    OPT  :: 1;
    REP  :: 2;
    PLUS :: 3;

    XML_CQUANT_NONE :: NONE;
    XML_CQUANT_OPT  :: OPT;
    XML_CQUANT_REP  :: REP;
    XML_CQUANT_PLUS :: PLUS;
}

/* If type == XML_CTYPE_EMPTY or XML_CTYPE_ANY, then quant will be
XML_CQUANT_NONE, and the other fields will be zero or NULL.
If type == XML_CTYPE_MIXED, then quant will be NONE or REP and
numchildren will contain number of elements that may be mixed in
and children point to an array of XML_Content cells that will be
all of XML_CTYPE_NAME type with no quantification.

If type == XML_CTYPE_NAME, then the name points to the name, and
the numchildren field will be zero and children will be NULL. The
quant fields indicates any quantifiers placed on the name.

CHOICE and SEQ will have name NULL, the number of children in
numchildren and children will point, recursively, to an array
of XML_Content cells.

The EMPTY, ANY, and MIXED types will only occur at top level.
*/
XML_Content :: XML_cp;

XML_cp :: struct {
    type:        XML_Content_Type;
    quant:       XML_Content_Quant;
    name:        *XML_Char;
    numchildren: u32;
    children:    *XML_Content;
}

/* This is called for an element declaration. See above for
description of the model argument. It's the user code's responsibility
to free model when finished with it. See XML_FreeContentModel.
There is no need to free the model from the handler, it can be kept
around and freed at a later stage.
*/
XML_ElementDeclHandler :: #type (userData: *void, name: *XML_Char, model: *XML_Content) -> void #c_call;

XML_SetElementDeclHandler :: (parser: XML_Parser, eldecl: XML_ElementDeclHandler) -> void #foreign libexpat;

/* The Attlist declaration handler is called for *each* attribute. So
a single Attlist declaration with multiple attributes declared will
generate multiple calls to this handler. The "default" parameter
may be NULL in the case of the "#IMPLIED" or "#REQUIRED"
keyword. The "isrequired" parameter will be true and the default
value will be NULL in the case of "#REQUIRED". If "isrequired" is
true and default is non-NULL, then this is a "#FIXED" default.
*/
XML_AttlistDeclHandler :: #type (userData: *void, elname: *XML_Char, attname: *XML_Char, att_type: *XML_Char, dflt: *XML_Char, isrequired: s32) -> void #c_call;

XML_SetAttlistDeclHandler :: (parser: XML_Parser, attdecl: XML_AttlistDeclHandler) -> void #foreign libexpat;

/* The XML declaration handler is called for *both* XML declarations
and text declarations. The way to distinguish is that the version
parameter will be NULL for text declarations. The encoding
parameter may be NULL for XML declarations. The standalone
parameter will be -1, 0, or 1 indicating respectively that there
was no standalone parameter in the declaration, that it was given
as no, or that it was given as yes.
*/
XML_XmlDeclHandler :: #type (userData: *void, version: *XML_Char, encoding: *XML_Char, standalone: s32) -> void #c_call;

XML_SetXmlDeclHandler :: (parser: XML_Parser, xmldecl: XML_XmlDeclHandler) -> void #foreign libexpat;

XML_Memory_Handling_Suite :: struct {
    malloc_fcn:  #type (size: size_t) -> *void #c_call;
    realloc_fcn: #type (ptr: *void, size: size_t) -> *void #c_call;
    free_fcn:    #type (ptr: *void) -> void #c_call;
}

/* Constructs a new parser; encoding is the encoding specified by the
external protocol or NULL if there is none specified.
*/
XML_ParserCreate :: (encoding: *XML_Char) -> XML_Parser #foreign libexpat;

/* Constructs a new parser and namespace processor.  Element type
names and attribute names that belong to a namespace will be
expanded; unprefixed attribute names are never expanded; unprefixed
element type names are expanded only if there is a default
namespace. The expanded name is the concatenation of the namespace
URI, the namespace separator character, and the local part of the
name.  If the namespace separator is '\0' then the namespace URI
and the local part will be concatenated without any separator.
It is a programming error to use the separator '\0' with namespace
triplets (see XML_SetReturnNSTriplet).
If a namespace separator is chosen that can be part of a URI or
part of an XML name, splitting an expanded name back into its
1, 2 or 3 original parts on application level in the element handler
may end up vulnerable, so these are advised against;  sane choices for
a namespace separator are e.g. '\n' (line feed) and '|' (pipe).

Note that Expat does not validate namespace URIs (beyond encoding)
against RFC 3986 today (and is not required to do so with regard to
the XML 1.0 namespaces specification) but it may start doing that
in future releases.  Before that, an application using Expat must
be ready to receive namespace URIs containing non-URI characters.
*/
XML_ParserCreateNS :: (encoding: *XML_Char, namespaceSeparator: XML_Char) -> XML_Parser #foreign libexpat;

/* Constructs a new parser using the memory management suite referred to
by memsuite. If memsuite is NULL, then use the standard library memory
suite. If namespaceSeparator is non-NULL it creates a parser with
namespace processing as described above. The character pointed at
will serve as the namespace separator.

All further memory operations used for the created parser will come from
the given suite.
*/
XML_ParserCreate_MM :: (encoding: *XML_Char, memsuite: *XML_Memory_Handling_Suite, namespaceSeparator: *XML_Char) -> XML_Parser #foreign libexpat;

/* Prepare a parser object to be re-used.  This is particularly
valuable when memory allocation overhead is disproportionately high,
such as when a large number of small documnents need to be parsed.
All handlers are cleared from the parser, except for the
unknownEncodingHandler. The parser's external state is re-initialized
except for the values of ns and ns_triplets.

Added in Expat 1.95.3.
*/
XML_ParserReset :: (parser: XML_Parser, encoding: *XML_Char) -> XML_Bool #foreign libexpat;

/* atts is array of name/value pairs, terminated by 0;
names and values are 0 terminated.
*/
XML_StartElementHandler :: #type (userData: *void, name: *XML_Char, atts: **XML_Char) -> void #c_call;

XML_EndElementHandler :: #type (userData: *void, name: *XML_Char) -> void #c_call;

/* s is not 0 terminated. */
XML_CharacterDataHandler :: #type (userData: *void, s: *XML_Char, len: s32) -> void #c_call;

/* target and data are 0 terminated */
XML_ProcessingInstructionHandler :: #type (userData: *void, target: *XML_Char, data: *XML_Char) -> void #c_call;

/* data is 0 terminated */
XML_CommentHandler :: #type (userData: *void, data: *XML_Char) -> void #c_call;

XML_StartCdataSectionHandler :: #type (userData: *void) -> void #c_call;
XML_EndCdataSectionHandler :: #type (userData: *void) -> void #c_call;

/* This is called for any characters in the XML document for which
there is no applicable handler.  This includes both characters that
are part of markup which is of a kind that is not reported
(comments, markup declarations), or characters that are part of a
construct which could be reported but for which no handler has been
supplied. The characters are passed exactly as they were in the XML
document except that they will be encoded in UTF-8 or UTF-16.
Line boundaries are not normalized. Note that a byte order mark
character is not passed to the default handler. There are no
guarantees about how characters are divided between calls to the
default handler: for example, a comment might be split between
multiple calls.
*/
XML_DefaultHandler :: #type (userData: *void, s: *XML_Char, len: s32) -> void #c_call;

/* This is called for the start of the DOCTYPE declaration, before
any DTD or internal subset is parsed.
*/
XML_StartDoctypeDeclHandler :: #type (userData: *void, doctypeName: *XML_Char, sysid: *XML_Char, pubid: *XML_Char, has_internal_subset: s32) -> void #c_call;

/* This is called for the end of the DOCTYPE declaration when the
closing > is encountered, but after processing any external
subset.
*/
XML_EndDoctypeDeclHandler :: #type (userData: *void) -> void #c_call;

/* This is called for entity declarations. The is_parameter_entity
argument will be non-zero if the entity is a parameter entity, zero
otherwise.

For internal entities (<!ENTITY foo "bar">), value will
be non-NULL and systemId, publicID, and notationName will be NULL.
The value string is NOT null-terminated; the length is provided in
the value_length argument. Since it is legal to have zero-length
values, do not use this argument to test for internal entities.

For external entities, value will be NULL and systemId will be
non-NULL. The publicId argument will be NULL unless a public
identifier was provided. The notationName argument will have a
non-NULL value only for unparsed entity declarations.

Note that is_parameter_entity can't be changed to XML_Bool, since
that would break binary compatibility.
*/
XML_EntityDeclHandler :: #type (userData: *void, entityName: *XML_Char, is_parameter_entity: s32, value: *XML_Char, value_length: s32, base: *XML_Char, systemId: *XML_Char, publicId: *XML_Char, notationName: *XML_Char) -> void #c_call;

XML_SetEntityDeclHandler :: (parser: XML_Parser, handler: XML_EntityDeclHandler) -> void #foreign libexpat;

/* OBSOLETE -- OBSOLETE -- OBSOLETE
This handler has been superseded by the EntityDeclHandler above.
It is provided here for backward compatibility.

This is called for a declaration of an unparsed (NDATA) entity.
The base argument is whatever was set by XML_SetBase. The
entityName, systemId and notationName arguments will never be
NULL. The other arguments may be.
*/
XML_UnparsedEntityDeclHandler :: #type (userData: *void, entityName: *XML_Char, base: *XML_Char, systemId: *XML_Char, publicId: *XML_Char, notationName: *XML_Char) -> void #c_call;

/* This is called for a declaration of notation.  The base argument is
whatever was set by XML_SetBase. The notationName will never be
NULL.  The other arguments can be.
*/
XML_NotationDeclHandler :: #type (userData: *void, notationName: *XML_Char, base: *XML_Char, systemId: *XML_Char, publicId: *XML_Char) -> void #c_call;

/* When namespace processing is enabled, these are called once for
each namespace declaration. The call to the start and end element
handlers occur between the calls to the start and end namespace
declaration handlers. For an xmlns attribute, prefix will be
NULL.  For an xmlns="" attribute, uri will be NULL.
*/
XML_StartNamespaceDeclHandler :: #type (userData: *void, prefix: *XML_Char, uri: *XML_Char) -> void #c_call;

XML_EndNamespaceDeclHandler :: #type (userData: *void, prefix: *XML_Char) -> void #c_call;

/* This is called if the document is not standalone, that is, it has an
external subset or a reference to a parameter entity, but does not
have standalone="yes". If this handler returns XML_STATUS_ERROR,
then processing will not continue, and the parser will return a
XML_ERROR_NOT_STANDALONE error.
If parameter entity parsing is enabled, then in addition to the
conditions above this handler will only be called if the referenced
entity was actually read.
*/
XML_NotStandaloneHandler :: #type (userData: *void) -> s32 #c_call;

/* This is called for a reference to an external parsed general
entity.  The referenced entity is not automatically parsed.  The
application can parse it immediately or later using
XML_ExternalEntityParserCreate.

The parser argument is the parser parsing the entity containing the
reference; it can be passed as the parser argument to
XML_ExternalEntityParserCreate.  The systemId argument is the
system identifier as specified in the entity declaration; it will
not be NULL.

The base argument is the system identifier that should be used as
the base for resolving systemId if systemId was relative; this is
set by XML_SetBase; it may be NULL.

The publicId argument is the public identifier as specified in the
entity declaration, or NULL if none was specified; the whitespace
in the public identifier will have been normalized as required by
the XML spec.

The context argument specifies the parsing context in the format
expected by the context argument to XML_ExternalEntityParserCreate;
context is valid only until the handler returns, so if the
referenced entity is to be parsed later, it must be copied.
context is NULL only when the entity is a parameter entity.

The handler should return XML_STATUS_ERROR if processing should not
continue because of a fatal error in the handling of the external
entity.  In this case the calling parser will return an
XML_ERROR_EXTERNAL_ENTITY_HANDLING error.

Note that unlike other handlers the first argument is the parser,
not userData.
*/
XML_ExternalEntityRefHandler :: #type (parser: XML_Parser, _context: *XML_Char, base: *XML_Char, systemId: *XML_Char, publicId: *XML_Char) -> s32 #c_call;

/* This is called in two situations:
1) An entity reference is encountered for which no declaration
has been read *and* this is not an error.
2) An internal entity reference is read, but not expanded, because
XML_SetDefaultHandler has been called.
Note: skipped parameter entities in declarations and skipped general
entities in attribute values cannot be reported, because
the event would be out of sync with the reporting of the
declarations or attribute values
*/
XML_SkippedEntityHandler :: #type (userData: *void, entityName: *XML_Char, is_parameter_entity: s32) -> void #c_call;

/* This structure is filled in by the XML_UnknownEncodingHandler to
provide information to the parser about encodings that are unknown
to the parser.

The map[b] member gives information about byte sequences whose
first byte is b.

If map[b] is c where c is >= 0, then b by itself encodes the
Unicode scalar value c.

If map[b] is -1, then the byte sequence is malformed.

If map[b] is -n, where n >= 2, then b is the first byte of an
n-byte sequence that encodes a single Unicode scalar value.

The data member will be passed as the first argument to the convert
function.

The convert function is used to convert multibyte sequences; s will
point to a n-byte sequence where map[(unsigned char)*s] == -n.  The
convert function must return the Unicode scalar value represented
by this byte sequence or -1 if the byte sequence is malformed.

The convert function may be NULL if the encoding is a single-byte
encoding, that is if map[b] >= -1 for all bytes b.

When the parser is finished with the encoding, then if release is
not NULL, it will call release passing it the data member; once
release has been called, the convert function will not be called
again.

Expat places certain restrictions on the encodings that are supported
using this mechanism.

1. Every ASCII character that can appear in a well-formed XML document,
other than the characters

$@\^`{}~

must be represented by a single byte, and that byte must be the
same byte that represents that character in ASCII.

2. No character may require more than 4 bytes to encode.

3. All characters encoded must have Unicode scalar values <=
0xFFFF, (i.e., characters that would be encoded by surrogates in
UTF-16 are  not allowed).  Note that this restriction doesn't
apply to the built-in support for UTF-8 and UTF-16.

4. No Unicode character may be encoded by more than one distinct
sequence of bytes.
*/
XML_Encoding :: struct {
    map:     [256] s32;
    data:    *void;
    convert: #type (data: *void, s: *u8) -> s32 #c_call;
    release: #type (data: *void) -> void #c_call;
}

/* This is called for an encoding that is unknown to the parser.

The encodingHandlerData argument is that which was passed as the
second argument to XML_SetUnknownEncodingHandler.

The name argument gives the name of the encoding as specified in
the encoding declaration.

If the callback can provide information about the encoding, it must
fill in the XML_Encoding structure, and return XML_STATUS_OK.
Otherwise it must return XML_STATUS_ERROR.

If info does not describe a suitable encoding, then the parser will
return an XML_ERROR_UNKNOWN_ENCODING error.
*/
XML_UnknownEncodingHandler :: #type (encodingHandlerData: *void, name: *XML_Char, info: *XML_Encoding) -> s32 #c_call;

XML_SetElementHandler :: (parser: XML_Parser, start: XML_StartElementHandler, end: XML_EndElementHandler) -> void #foreign libexpat;

XML_SetStartElementHandler :: (parser: XML_Parser, handler: XML_StartElementHandler) -> void #foreign libexpat;

XML_SetEndElementHandler :: (parser: XML_Parser, handler: XML_EndElementHandler) -> void #foreign libexpat;

XML_SetCharacterDataHandler :: (parser: XML_Parser, handler: XML_CharacterDataHandler) -> void #foreign libexpat;

XML_SetProcessingInstructionHandler :: (parser: XML_Parser, handler: XML_ProcessingInstructionHandler) -> void #foreign libexpat;

XML_SetCommentHandler :: (parser: XML_Parser, handler: XML_CommentHandler) -> void #foreign libexpat;

XML_SetCdataSectionHandler :: (parser: XML_Parser, start: XML_StartCdataSectionHandler, end: XML_EndCdataSectionHandler) -> void #foreign libexpat;

XML_SetStartCdataSectionHandler :: (parser: XML_Parser, start: XML_StartCdataSectionHandler) -> void #foreign libexpat;

XML_SetEndCdataSectionHandler :: (parser: XML_Parser, end: XML_EndCdataSectionHandler) -> void #foreign libexpat;

/* This sets the default handler and also inhibits expansion of
internal entities. These entity references will be passed to the
default handler, or to the skipped entity handler, if one is set.
*/
XML_SetDefaultHandler :: (parser: XML_Parser, handler: XML_DefaultHandler) -> void #foreign libexpat;

/* This sets the default handler but does not inhibit expansion of
internal entities.  The entity reference will not be passed to the
default handler.
*/
XML_SetDefaultHandlerExpand :: (parser: XML_Parser, handler: XML_DefaultHandler) -> void #foreign libexpat;

XML_SetDoctypeDeclHandler :: (parser: XML_Parser, start: XML_StartDoctypeDeclHandler, end: XML_EndDoctypeDeclHandler) -> void #foreign libexpat;

XML_SetStartDoctypeDeclHandler :: (parser: XML_Parser, start: XML_StartDoctypeDeclHandler) -> void #foreign libexpat;

XML_SetEndDoctypeDeclHandler :: (parser: XML_Parser, end: XML_EndDoctypeDeclHandler) -> void #foreign libexpat;

XML_SetUnparsedEntityDeclHandler :: (parser: XML_Parser, handler: XML_UnparsedEntityDeclHandler) -> void #foreign libexpat;

XML_SetNotationDeclHandler :: (parser: XML_Parser, handler: XML_NotationDeclHandler) -> void #foreign libexpat;

XML_SetNamespaceDeclHandler :: (parser: XML_Parser, start: XML_StartNamespaceDeclHandler, end: XML_EndNamespaceDeclHandler) -> void #foreign libexpat;

XML_SetStartNamespaceDeclHandler :: (parser: XML_Parser, start: XML_StartNamespaceDeclHandler) -> void #foreign libexpat;

XML_SetEndNamespaceDeclHandler :: (parser: XML_Parser, end: XML_EndNamespaceDeclHandler) -> void #foreign libexpat;

XML_SetNotStandaloneHandler :: (parser: XML_Parser, handler: XML_NotStandaloneHandler) -> void #foreign libexpat;

XML_SetExternalEntityRefHandler :: (parser: XML_Parser, handler: XML_ExternalEntityRefHandler) -> void #foreign libexpat;

/* If a non-NULL value for arg is specified here, then it will be
passed as the first argument to the external entity ref handler
instead of the parser object.
*/
XML_SetExternalEntityRefHandlerArg :: (parser: XML_Parser, arg: *void) -> void #foreign libexpat;

XML_SetSkippedEntityHandler :: (parser: XML_Parser, handler: XML_SkippedEntityHandler) -> void #foreign libexpat;

XML_SetUnknownEncodingHandler :: (parser: XML_Parser, handler: XML_UnknownEncodingHandler, encodingHandlerData: *void) -> void #foreign libexpat;

/* This can be called within a handler for a start element, end
element, processing instruction or character data.  It causes the
corresponding markup to be passed to the default handler.
*/
XML_DefaultCurrent :: (parser: XML_Parser) -> void #foreign libexpat;

/* If do_nst is non-zero, and namespace processing is in effect, and
a name has a prefix (i.e. an explicit namespace qualifier) then
that name is returned as a triplet in a single string separated by
the separator character specified when the parser was created: URI
+ sep + local_name + sep + prefix.

If do_nst is zero, then namespace information is returned in the
default manner (URI + sep + local_name) whether or not the name
has a prefix.

Note: Calling XML_SetReturnNSTriplet after XML_Parse or
XML_ParseBuffer has no effect.
*/
XML_SetReturnNSTriplet :: (parser: XML_Parser, do_nst: s32) -> void #foreign libexpat;

/* This value is passed as the userData argument to callbacks. */
XML_SetUserData :: (parser: XML_Parser, userData: *void) -> void #foreign libexpat;

/* This is equivalent to supplying an encoding argument to
XML_ParserCreate. On success XML_SetEncoding returns non-zero,
zero otherwise.
Note: Calling XML_SetEncoding after XML_Parse or XML_ParseBuffer
has no effect and returns XML_STATUS_ERROR.
*/
XML_SetEncoding :: (parser: XML_Parser, encoding: *XML_Char) -> XML_Status #foreign libexpat;

/* If this function is called, then the parser will be passed as the
first argument to callbacks instead of userData.  The userData will
still be accessible using XML_GetUserData.
*/
XML_UseParserAsHandlerArg :: (parser: XML_Parser) -> void #foreign libexpat;

/* If useDTD == XML_TRUE is passed to this function, then the parser
will assume that there is an external subset, even if none is
specified in the document. In such a case the parser will call the
externalEntityRefHandler with a value of NULL for the systemId
argument (the publicId and context arguments will be NULL as well).
Note: For the purpose of checking WFC: Entity Declared, passing
useDTD == XML_TRUE will make the parser behave as if the document
had a DTD with an external subset.
Note: If this function is called, then this must be done before
the first call to XML_Parse or XML_ParseBuffer, since it will
have no effect after that.  Returns
XML_ERROR_CANT_CHANGE_FEATURE_ONCE_PARSING.
Note: If the document does not have a DOCTYPE declaration at all,
then startDoctypeDeclHandler and endDoctypeDeclHandler will not
be called, despite an external subset being parsed.
Note: If XML_DTD is not defined when Expat is compiled, returns
XML_ERROR_FEATURE_REQUIRES_XML_DTD.
Note: If parser == NULL, returns XML_ERROR_INVALID_ARGUMENT.
*/
XML_UseForeignDTD :: (parser: XML_Parser, useDTD: XML_Bool) -> XML_Error #foreign libexpat;

/* Sets the base to be used for resolving relative URIs in system
identifiers in declarations.  Resolving relative identifiers is
left to the application: this value will be passed through as the
base argument to the XML_ExternalEntityRefHandler,
XML_NotationDeclHandler and XML_UnparsedEntityDeclHandler. The base
argument will be copied.  Returns XML_STATUS_ERROR if out of memory,
XML_STATUS_OK otherwise.
*/
XML_SetBase :: (parser: XML_Parser, base: *XML_Char) -> XML_Status #foreign libexpat;

XML_GetBase :: (parser: XML_Parser) -> *XML_Char #foreign libexpat;

/* Returns the number of the attribute/value pairs passed in last call
to the XML_StartElementHandler that were specified in the start-tag
rather than defaulted. Each attribute/value pair counts as 2; thus
this corresponds to an index into the atts array passed to the
XML_StartElementHandler.  Returns -1 if parser == NULL.
*/
XML_GetSpecifiedAttributeCount :: (parser: XML_Parser) -> s32 #foreign libexpat;

/* Returns the index of the ID attribute passed in the last call to
XML_StartElementHandler, or -1 if there is no ID attribute or
parser == NULL.  Each attribute/value pair counts as 2; thus this
corresponds to an index into the atts array passed to the
XML_StartElementHandler.
*/
XML_GetIdAttributeIndex :: (parser: XML_Parser) -> s32 #foreign libexpat;

/* Parses some input. Returns XML_STATUS_ERROR if a fatal error is
detected.  The last call to XML_Parse must have isFinal true; len
may be zero for this call (or any other).

Though the return values for these functions has always been
described as a Boolean value, the implementation, at least for the
1.95.x series, has always returned exactly one of the XML_Status
values.
*/
XML_Parse :: (parser: XML_Parser, s: *u8, len: s32, isFinal: s32) -> XML_Status #foreign libexpat;

XML_GetBuffer :: (parser: XML_Parser, len: s32) -> *void #foreign libexpat;

XML_ParseBuffer :: (parser: XML_Parser, len: s32, isFinal: s32) -> XML_Status #foreign libexpat;

/* Stops parsing, causing XML_Parse() or XML_ParseBuffer() to return.
Must be called from within a call-back handler, except when aborting
(resumable = 0) an already suspended parser. Some call-backs may
still follow because they would otherwise get lost. Examples:
- endElementHandler() for empty elements when stopped in
startElementHandler(),
- endNameSpaceDeclHandler() when stopped in endElementHandler(),
and possibly others.

Can be called from most handlers, including DTD related call-backs,
except when parsing an external parameter entity and resumable != 0.
Returns XML_STATUS_OK when successful, XML_STATUS_ERROR otherwise.
Possible error codes:
- XML_ERROR_SUSPENDED: when suspending an already suspended parser.
- XML_ERROR_FINISHED: when the parser has already finished.
- XML_ERROR_SUSPEND_PE: when suspending while parsing an external PE.

When resumable != 0 (true) then parsing is suspended, that is,
XML_Parse() and XML_ParseBuffer() return XML_STATUS_SUSPENDED.
Otherwise, parsing is aborted, that is, XML_Parse() and XML_ParseBuffer()
return XML_STATUS_ERROR with error code XML_ERROR_ABORTED.

*Note*:
This will be applied to the current parser instance only, that is, if
there is a parent parser then it will continue parsing when the
externalEntityRefHandler() returns. It is up to the implementation of
the externalEntityRefHandler() to call XML_StopParser() on the parent
parser (recursively), if one wants to stop parsing altogether.

When suspended, parsing can be resumed by calling XML_ResumeParser().
*/
XML_StopParser :: (parser: XML_Parser, resumable: XML_Bool) -> XML_Status #foreign libexpat;

/* Resumes parsing after it has been suspended with XML_StopParser().
Must not be called from within a handler call-back. Returns same
status codes as XML_Parse() or XML_ParseBuffer().
Additional error code XML_ERROR_NOT_SUSPENDED possible.

*Note*:
This must be called on the most deeply nested child parser instance
first, and on its parent parser only after the child parser has finished,
to be applied recursively until the document entity's parser is restarted.
That is, the parent parser will not resume by itself and it is up to the
application to call XML_ResumeParser() on it at the appropriate moment.
*/
XML_ResumeParser :: (parser: XML_Parser) -> XML_Status #foreign libexpat;

XML_Parsing :: enum u32 {
    INITIALIZED :: 0;
    PARSING     :: 1;
    FINISHED    :: 2;
    SUSPENDED   :: 3;
    XML_INITIALIZED :: INITIALIZED;
    XML_PARSING     :: PARSING;
    XML_FINISHED    :: FINISHED;
    XML_SUSPENDED   :: SUSPENDED;
}

XML_ParsingStatus :: struct {
    parsing:     XML_Parsing;
    finalBuffer: XML_Bool;
}

/* Returns status of parser with respect to being initialized, parsing,
finished, or suspended and processing the final buffer.
XXX XML_Parse() and XML_ParseBuffer() should return XML_ParsingStatus,
XXX with XML_FINISHED_OK or XML_FINISHED_ERROR replacing XML_FINISHED
*/
XML_GetParsingStatus :: (parser: XML_Parser, status: *XML_ParsingStatus) -> void #foreign libexpat;

/* Creates an XML_Parser object that can parse an external general
entity; context is a '\0'-terminated string specifying the parse
context; encoding is a '\0'-terminated string giving the name of
the externally specified encoding, or NULL if there is no
externally specified encoding.  The context string consists of a
sequence of tokens separated by formfeeds (\f); a token consisting
of a name specifies that the general entity of the name is open; a
token of the form prefix=uri specifies the namespace for a
particular prefix; a token of the form =uri specifies the default
namespace.  This can be called at any point after the first call to
an ExternalEntityRefHandler so longer as the parser has not yet
been freed.  The new parser is completely independent and may
safely be used in a separate thread.  The handlers and userData are
initialized from the parser argument.  Returns NULL if out of memory.
Otherwise returns a new XML_Parser object.
*/
XML_ExternalEntityParserCreate :: (parser: XML_Parser, _context: *XML_Char, encoding: *XML_Char) -> XML_Parser #foreign libexpat;

XML_ParamEntityParsing :: enum u32 {
    NEVER             :: 0;
    UNLESS_STANDALONE :: 1;
    ALWAYS            :: 2;

    XML_PARAM_ENTITY_PARSING_NEVER             :: NEVER;
    XML_PARAM_ENTITY_PARSING_UNLESS_STANDALONE :: UNLESS_STANDALONE;
    XML_PARAM_ENTITY_PARSING_ALWAYS            :: ALWAYS;
}

/* Controls parsing of parameter entities (including the external DTD
subset). If parsing of parameter entities is enabled, then
references to external parameter entities (including the external
DTD subset) will be passed to the handler set with
XML_SetExternalEntityRefHandler.  The context passed will be 0.

Unlike external general entities, external parameter entities can
only be parsed synchronously.  If the external parameter entity is
to be parsed, it must be parsed during the call to the external
entity ref handler: the complete sequence of
XML_ExternalEntityParserCreate, XML_Parse/XML_ParseBuffer and
XML_ParserFree calls must be made during this call.  After
XML_ExternalEntityParserCreate has been called to create the parser
for the external parameter entity (context must be 0 for this
call), it is illegal to make any calls on the old parser until
XML_ParserFree has been called on the newly created parser.
If the library has been compiled without support for parameter
entity parsing (ie without XML_DTD being defined), then
XML_SetParamEntityParsing will return 0 if parsing of parameter
entities is requested; otherwise it will return non-zero.
Note: If XML_SetParamEntityParsing is called after XML_Parse or
XML_ParseBuffer, then it has no effect and will always return 0.
Note: If parser == NULL, the function will do nothing and return 0.
*/
XML_SetParamEntityParsing :: (parser: XML_Parser, parsing: XML_ParamEntityParsing) -> s32 #foreign libexpat;

/* Sets the hash salt to use for internal hash calculations.
Helps in preventing DoS attacks based on predicting hash
function behavior. This must be called before parsing is started.
Returns 1 if successful, 0 when called after parsing has started.
Note: If parser == NULL, the function will do nothing and return 0.
*/
XML_SetHashSalt :: (parser: XML_Parser, hash_salt: u64) -> s32 #foreign libexpat;

/* If XML_Parse or XML_ParseBuffer have returned XML_STATUS_ERROR, then
XML_GetErrorCode returns information about the error.
*/
XML_GetErrorCode :: (parser: XML_Parser) -> XML_Error #foreign libexpat;

/* These functions return information about the current parse
location.  They may be called from any callback called to report
some parse event; in this case the location is the location of the
first of the sequence of characters that generated the event.  When
called from callbacks generated by declarations in the document
prologue, the location identified isn't as neatly defined, but will
be within the relevant markup.  When called outside of the callback
functions, the position indicated will be just past the last parse
event (regardless of whether there was an associated callback).

They may also be called after returning from a call to XML_Parse
or XML_ParseBuffer.  If the return value is XML_STATUS_ERROR then
the location is the location of the character at which the error
was detected; otherwise the location is the location of the last
parse event, as described above.

Note: XML_GetCurrentLineNumber and XML_GetCurrentColumnNumber
return 0 to indicate an error.
Note: XML_GetCurrentByteIndex returns -1 to indicate an error.
*/
XML_GetCurrentLineNumber :: (parser: XML_Parser) -> XML_Size #foreign libexpat;
XML_GetCurrentColumnNumber :: (parser: XML_Parser) -> XML_Size #foreign libexpat;
XML_GetCurrentByteIndex :: (parser: XML_Parser) -> XML_Index #foreign libexpat;

/* Return the number of bytes in the current event.
Returns 0 if the event is in an internal entity.
*/
XML_GetCurrentByteCount :: (parser: XML_Parser) -> s32 #foreign libexpat;

/* If XML_CONTEXT_BYTES is defined, returns the input buffer, sets
the integer pointed to by offset to the offset within this buffer
of the current parse position, and sets the integer pointed to by size
to the size of this buffer (the number of input bytes). Otherwise
returns a NULL pointer. Also returns a NULL pointer if a parse isn't
active.

NOTE: The character pointer returned should not be used outside
the handler that makes the call.
*/
XML_GetInputContext :: (parser: XML_Parser, offset: *s32, size: *s32) -> *u8 #foreign libexpat;

/* Frees the content model passed to the element declaration handler */
XML_FreeContentModel :: (parser: XML_Parser, model: *XML_Content) -> void #foreign libexpat;

/* Exposing the memory handling functions used in Expat */
XML_MemMalloc :: (parser: XML_Parser, size: size_t) -> *void #foreign libexpat;

XML_MemRealloc :: (parser: XML_Parser, ptr: *void, size: size_t) -> *void #foreign libexpat;

XML_MemFree :: (parser: XML_Parser, ptr: *void) -> void #foreign libexpat;

/* Frees memory used by the parser. */
XML_ParserFree :: (parser: XML_Parser) -> void #foreign libexpat;

/* Returns a string describing the error. */
XML_ErrorString :: (code: XML_Error) -> *XML_LChar #foreign libexpat;

/* Return a string containing the version number of this expat */
XML_ExpatVersion :: () -> *XML_LChar #foreign libexpat;

XML_Expat_Version :: struct {
    major: s32;
    minor: s32;
    micro: s32;
}

/* Return an XML_Expat_Version structure containing numeric version
number information for this version of expat.
*/
XML_ExpatVersionInfo :: () -> XML_Expat_Version #foreign libexpat;

/* Added in Expat 1.95.5. */
XML_FeatureEnum :: enum u32 {
    END                                                            :: 0;
    UNICODE                                                        :: 1;
    UNICODE_WCHAR_T                                                :: 2;
    DTD                                                            :: 3;
    CONTEXT_BYTES                                                  :: 4;
    MIN_SIZE                                                       :: 5;
    SIZEOF_XML_CHAR                                                :: 6;
    SIZEOF_XML_LCHAR                                               :: 7;
    NS                                                             :: 8;
    LARGE_SIZE                                                     :: 9;
    ATTR_INFO                                                      :: 10;

    BILLION_LAUGHS_ATTACK_PROTECTION_MAXIMUM_AMPLIFICATION_DEFAULT :: 11;
    BILLION_LAUGHS_ATTACK_PROTECTION_ACTIVATION_THRESHOLD_DEFAULT  :: 12;

    XML_FEATURE_END                                                            :: END;
    XML_FEATURE_UNICODE                                                        :: UNICODE;
    XML_FEATURE_UNICODE_WCHAR_T                                                :: UNICODE_WCHAR_T;
    XML_FEATURE_DTD                                                            :: DTD;
    XML_FEATURE_CONTEXT_BYTES                                                  :: CONTEXT_BYTES;
    XML_FEATURE_MIN_SIZE                                                       :: MIN_SIZE;
    XML_FEATURE_SIZEOF_XML_CHAR                                                :: SIZEOF_XML_CHAR;
    XML_FEATURE_SIZEOF_XML_LCHAR                                               :: SIZEOF_XML_LCHAR;
    XML_FEATURE_NS                                                             :: NS;
    XML_FEATURE_LARGE_SIZE                                                     :: LARGE_SIZE;
    XML_FEATURE_ATTR_INFO                                                      :: ATTR_INFO;

    XML_FEATURE_BILLION_LAUGHS_ATTACK_PROTECTION_MAXIMUM_AMPLIFICATION_DEFAULT :: BILLION_LAUGHS_ATTACK_PROTECTION_MAXIMUM_AMPLIFICATION_DEFAULT;
    XML_FEATURE_BILLION_LAUGHS_ATTACK_PROTECTION_ACTIVATION_THRESHOLD_DEFAULT  :: BILLION_LAUGHS_ATTACK_PROTECTION_ACTIVATION_THRESHOLD_DEFAULT;
}

XML_Feature :: struct {
    feature: XML_FeatureEnum;
    name:    *XML_LChar;
    value:   s64;
}

XML_GetFeatureList :: () -> *XML_Feature #foreign libexpat;

#scope_file

libexpat :: #system_library "libexpat";
