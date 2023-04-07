/// @return Nested struct/array data that represents the contents of the "Config JSON" string
/// 
/// @param string  The "Config JSON" string to be decoded
/// 
/// @jujuadams 2023-04-07

function SnapFromConfigJSON(_string)
{
    var _buffer = buffer_create(string_byte_length(_string), buffer_fixed, 1);
    buffer_write(_buffer, buffer_text, _string);
    var _data = SnapBufferReadConfigJSON(_buffer, 0);
    buffer_delete(_buffer);
    return _data;
}