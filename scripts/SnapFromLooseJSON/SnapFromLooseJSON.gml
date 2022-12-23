/// @return Nested struct/array data that represents the contents of the "Loose JSON" string
/// 
/// @param string  The "Loose JSON" string to be decoded
/// 
/// @jujuadams 2022-12-23

function SnapFromLooseJSON(_string)
{
    var _buffer = buffer_create(string_byte_length(_string), buffer_fixed, 1);
    buffer_write(_buffer, buffer_text, _string);
    var _data = SnapBufferReadLooseJSON(_buffer, 0);
    buffer_delete(_buffer);
    return _data;
}