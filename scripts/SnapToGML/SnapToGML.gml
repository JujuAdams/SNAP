/// @return GML string that encodes the provided struct
/// 
/// @param struct                The struct to be encoded. Can contain structs, arrays, strings, and numbers (but the root must be a struct).   N.B. Will not encode ds_list, ds_map etc.
/// @param [alphabetizeStructs]  (bool) Sorts struct variable names is ascending alphabetical order as per ds_list_sort(). Defaults to <false>
/// 
/// @jujuadams 2022-10-30

function SnapToGML(_struct, _alphabetise = false)
{
    var _buffer = buffer_create(1024, buffer_grow, 1);
    SnapBufferWriteGML(_buffer, _struct, _alphabetise);
    buffer_seek(_buffer, buffer_seek_start, 0);
    var _string = buffer_read(_buffer, buffer_string);
    buffer_delete(_buffer);
    return _string; 
}