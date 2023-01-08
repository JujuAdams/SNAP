/// @return Nested struct/array data that represents the contents of the QML string
/// 
/// @param string            The QML string to be decoded
/// @param instanceofDict
/// @param [relaxed=false]
/// 
/// @jujuadams 2023-01-08

function SnapFromQML(_string, _instanceofDict, _relaxed = false)
{
    var _buffer = buffer_create(string_byte_length(_string), buffer_fixed, 1);
    buffer_write(_buffer, buffer_text, _string);
    var _data = SnapBufferReadQML(_buffer, _instanceofDict, _relaxed, 0);
    buffer_delete(_buffer);
    return _data;
}