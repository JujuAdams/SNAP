/// Decodes an CSV string and outputs a 2D array
/// 
/// @param string              The CSV string to be decoded
/// @param [cellDelimiter]     Character to use to indicate where cells start and end. First 127 ASCII chars only. Defaults to a comma
/// @param [stringDelimiter]   Character to use to indicate where strings start and end. First 127 ASCII chars only. Defaults to a double quote
/// 
/// @jujuadams 2022-10-30

function SnapFromCSV(_string, _cellDelimiter = ",", _stringDelimiter = "\"")
{
    var _buffer = buffer_create(string_byte_length(_string)+1, buffer_fixed, 1);
    buffer_write(_buffer, buffer_string, _string);
    var _data = SnapBufferReadCSV(_buffer, 0, buffer_get_size(_buffer), _cellDelimiter, _stringDelimiter);
    buffer_delete(_buffer);
    return _data;
}