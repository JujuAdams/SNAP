// Feather disable all
/// @return CSV string that encodes the provided 2D array
/// 
/// @param array2D             The 2D array to encode
/// @param [cellDelimiter]     Character to use to indicate where cells start and end. First 127 ASCII chars only. Defaults to a comma
/// @param [stringDelimiter]   Character to use to indicate where strings start and end. First 127 ASCII chars only. Defaults to a double quote
/// @param [accurateFloats]    (bool) Whether to output floats at a higher accuracy than GM normally defaults to. Defaults to <false>. Setting this to <true> confers a performance penalty
/// 
/// @jujuadams 2022-10-30

function SnapToCSV(_array, _cellDelimiter = ",", _stringDelimiter = "\"", _accurateFloats = false)
{
    var _buffer = buffer_create(1024, buffer_grow, 1);
    SnapBufferWriteCSV(_buffer, _array, _cellDelimiter, _stringDelimiter, _accurateFloats);
    buffer_seek(_buffer, buffer_seek_start, 0);
    var _string = buffer_read(_buffer, buffer_string);
    buffer_delete(_buffer);
    return _string; 
}
