/// @return VDF string that encodes the struct data
/// 
/// N.B. This function cannot encode arrays, and any numbers will be stringified
/// 
/// @param struct            The data to be encoded. Can contain structs and strings.   N.B. Will not encode a ds_map
/// @param [alphabetize]     (bool) Sorts struct keys in ascending alphabetical order as per array_sort(). Defaults to <false>
/// @param [accurateFloats]  (bool) Whether to stringify floats at a higher accuracy than GM normally defaults to. Defaults to <false>. Setting this to <true> confers a performance penalty
/// 
/// @jujuadams 2023-03-25

function SnapToVDF(_ds, _alphabetise = false, _accurateFloats = false)
{
    var _buffer = buffer_create(1024, buffer_grow, 1);
    SnapBufferWriteVDF(_buffer, _ds, _alphabetise, _accurateFloats);
    buffer_seek(_buffer, buffer_seek_start, 0);
    var _string = buffer_read(_buffer, buffer_string);
    buffer_delete(_buffer);
    return _string; 
}