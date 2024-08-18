// Feather disable all

/// Parses and executes simple GML code stored in a string. Returns the scope, as given by the
/// `scope` parameter. This GML parser is very stripped back and supports a small subset of GML.
/// The use of this parser should be limited to reading data in keeping with the overall intentions
/// of SNAP as a data-oriented library.
/// 
/// The parser supports:
/// - Struct / array literals (JSON)
/// - Most GML operators, including ternaries (`condition? valueIfTrue : valueIfFalse`)
/// - Executing functions
/// - Instantiating constructors (with `new`)
/// - Setting global variables
/// - Setting scoped variables
///
/// The parser does not support:
/// - if/else, while, etc. flow control
/// - Function and constructor definition
/// - Dot notation for variable access in structs/instances
/// - Square bracket notation for array value access
/// - Anything else that's not explicitly mentioned
/// 
/// Tokens for macros, GML constants, assets etc. can be added by defining them as key-value pairs
/// in the `tokenStruct` parameter. Tokens can be added globally for all executions of SnapFromGML()
/// and SnapBufferReadGML() by calling SnapEnvGMLSetToken() and SnapEnvGMLSetTokenFunction().
/// Please see those functions for more information.
/// 
/// The scope for setting variables is given by by `scope` parameter. By default, variables are set
/// in global scope. You may want to replace this with a struct or an instance depending on your
/// use case.
/// 
/// If you set the `allowAllAssets` parameter to `true` then the GML parser will treat all assets
/// in your project as accessible (effectively this adds all assets in your project as valid
/// tokens). It is not recommended to ship any code with this parameter set to `true` as it may
/// introduce security issues; instead you should explicitly add tokens for assets that you would
/// like to be made accessible.
/// 
/// @param string
/// @param [scope=global]
/// @param [aliasStruct]
/// @param [allowAllAssets=false]
/// 
/// @jujuadams 2024-08-16

function SnapFromGML(_string, _scope = global, _aliasStruct = {}, _allowAllAssets = false)
{
    var _buffer = buffer_create(string_byte_length(_string)+1, buffer_fixed, 1);
    buffer_write(_buffer, buffer_string, _string);
    var _data = SnapBufferReadGML(_buffer, 0, buffer_get_size(_buffer), _scope, _aliasStruct, _allowAllAssets);
    buffer_delete(_buffer);
    return _data;
}
