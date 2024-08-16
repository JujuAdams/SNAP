// Feather disable all

/// @return Nested struct/array data that represents the contents of the GML string.
/// 
/// @param string         The GML string to be decoded
/// @param [scope={}]
/// @param [aliasStruct]
/// 
/// @jujuadams 2024-08-16

function SnapFromGML(_string, _scope = {}, _aliasStruct = {})
{
    var _buffer = buffer_create(string_byte_length(_string)+1, buffer_fixed, 1);
    buffer_write(_buffer, buffer_string, _string);
    var _data = SnapBufferReadGML(_buffer, 0, buffer_get_size(_buffer), _scope, _aliasStruct);
    buffer_delete(_buffer);
    return _data;
}
