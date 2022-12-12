/// Generates an MD5 hash of the data in a struct/array
/// This function can also be used on non-struct/array data, though the hash may not line up with other MD5 implementations
/// 
/// @param value  Value to hash
/// 
/// @jujuadams 2022-12-12

function SnapMD5(_value)
{
    var _buffer = buffer_create(1024, buffer_grow, 1);
    SnapBufferWriteBinary(_buffer, _value, true);
    var _hash = buffer_md5(_buffer, 0, buffer_tell(_buffer));
    buffer_delete(_buffer);
    return _hash;
}