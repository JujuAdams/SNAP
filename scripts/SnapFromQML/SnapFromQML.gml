/// @return Nested struct/array data that represents the contents of the QML string
/// 
/// @param string            The QML string to be decoded
/// @param constructorDict
/// 
/// @jujuadams 2022-12-23

function SnapFromQML(_string, _constructorDict)
{
    var _buffer = buffer_create(string_byte_length(_string), buffer_fixed, 1);
    buffer_write(_buffer, buffer_text, _string);
    var _data = SnapBufferReadQML(_buffer, _constructorDict, 0);
    buffer_delete(_buffer);
    return _data;
}