/// @param string

function snap_to_2d_array(_string)
{
    var _buffer = buffer_base64_decode(_string);
    
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
    
    buffer_delete(_buffer);
    
    return _array;
}