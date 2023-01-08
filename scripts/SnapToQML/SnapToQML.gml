/// @return QML string that encodes the struct/array nested data
/// 
/// @param struct/array             The data to be encoded. Can contain structs, arrays, strings, and numbers.   N.B. Will not encode ds_list, ds_map etc.
/// @param instanceofDict
/// @param [relaxed=false]
/// @param [accurateFloats=false]   (bool) Whether to output floats at a higher accuracy than GM normally defaults to. Setting this to <true> confers a performance penalty
/// 
/// @jujuadams 2023-01-08

function SnapToQML(_ds, _instanceofDict, _relaxed = false, _accurateFloats = false)
{
    var _buffer = buffer_create(1024, buffer_grow, 1);
    SnapBufferWriteQML(_buffer, _ds, _instanceofDict, _relaxed, _accurateFloats);
    buffer_seek(_buffer, buffer_seek_start, 0);
    var _string = buffer_read(_buffer, buffer_string);
    buffer_delete(_buffer);
    return _string; 
}