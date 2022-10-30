/// @return YAML string that encodes the struct/array nested data
/// 
/// @param struct/array          The data to be encoded. Can contain structs, arrays, strings, and numbers.   N.B. Will not encode ds_list, ds_map etc.
/// @param [alphabetizeStructs]  (bool) Sorts struct variable names is ascending alphabetical order as per array_sort(). Defaults to <false>
/// @param [accurateFloats]      (bool) Whether to output floats at a higher accuracy than GM normally defaults to. Defaults to <false>. Setting this to <true> confers a performance penalty
/// 
/// @jujuadams 2022-10-30

function SnapToYAML(_ds, _alphabetise = false, _accurateFloats = false)
{
    var _buffer = buffer_create(1024, buffer_grow, 1);
    SnapBufferWriteYAML(_buffer, _ds, _alphabetise, _accurateFloats);
    buffer_seek(_buffer, buffer_seek_start, 0);
    var _string = buffer_read(_buffer, buffer_string);
    buffer_delete(_buffer);
    return _string; 
}