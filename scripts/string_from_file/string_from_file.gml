/// @return String that represents all the text inside the file
///
/// @param filename  File to parse
///
/// @jujuadams 2020-08-16

function string_from_file(_filename)
{
    var _buffer = buffer_load(_filename);
    var _string = buffer_read(_buffer, buffer_string);
    buffer_delete(_buffer);
    return _string;
}