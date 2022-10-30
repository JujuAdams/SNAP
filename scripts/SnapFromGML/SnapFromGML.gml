/// @return Nested struct/array data that represents the contents of the GML string. The root node will always be a struct
/// 
/// @param string  The GML string to be decoded
/// 
/// @jujuadams 2022-10-30

function SnapFromGML(_string)
{
    var _buffer = buffer_create(string_byte_length(_string), buffer_fixed, 1);
    buffer_write(_buffer, buffer_text, _string);
    var _data = SnapBufferReadGML(_buffer, 0, buffer_get_size(_buffer));
    buffer_delete(_buffer);
    return _data;
}