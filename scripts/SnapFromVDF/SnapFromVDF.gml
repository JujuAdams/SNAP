// Feather disable all
/// @return Nested struct data that represents the contents of the VDF string
/// 
/// @param string  The VDF string to be decoded
/// 
/// @jujuadams 2023-03-25

function SnapFromVDF(_string)
{
    var _buffer = buffer_create(string_byte_length(_string), buffer_fixed, 1);
    buffer_write(_buffer, buffer_text, _string);
    var _data = SnapBufferReadVDF(_buffer, 0, buffer_get_size(_buffer));
    buffer_delete(_buffer);
    return _data;
}
