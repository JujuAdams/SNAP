
/// @return Nested struct/array data that represents the contents of the JSON string
/// 
/// @param string  The JSON string to be decoded
/// 
/// @jujuadams 2022-10-30

function SnapFromJSON(_string)
{
    var _buffer = buffer_create(string_byte_length(_string), buffer_fixed, 1);
    buffer_write(_buffer, buffer_text, _string);
    var _data = SnapBufferReadJSON(_buffer, 0);
    buffer_delete(_buffer);
    return _data;
}