/// @param buffer
/// @param offset
/// 
/// @jujuadams 2022-10-30

function SnapBufferRead2DArray(_buffer, _inOffset)
{
    if (_inOffset != undefined)
    {
        var _oldOffset = buffer_tell(_buffer);
        buffer_seek(_buffer, buffer_seek_start, _inOffset);
    }
    
    var _datatype = buffer_read(_buffer, buffer_u8);
    var _width    = buffer_read(_buffer, buffer_u32);
    var _height   = buffer_read(_buffer, buffer_u32);
    
    var _array = array_create(_width);
    
    var _x = 0;
    repeat(_width)
    {
        var _sub_array = array_create(_height);
        _array[@ _x] = _sub_array;
        
        var _y = 0;
        repeat(_height)
        {
            _sub_array[@ _y] = buffer_read(_buffer, _datatype);
            ++_y;
        }
        
        ++_x;
    }
    
    if (_inOffset != undefined) buffer_seek(_buffer, buffer_seek_start, _oldOffset);
    
    return _array;
}