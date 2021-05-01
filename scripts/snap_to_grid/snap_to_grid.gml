/// @param string

function snap_to_grid(_string)
{
    var _buffer = buffer_base64_decode(_string);
    
    var _datatype = buffer_read(_buffer, buffer_u8);
    var _width    = buffer_read(_buffer, buffer_u32);
    var _height   = buffer_read(_buffer, buffer_u32);
    
    var _grid = ds_grid_create(_width, _height);
    
    var _x = 0;
    repeat(_width)
    {
        var _y = 0;
        repeat(_height)
        {
            _grid[# _x, _y] = buffer_read(_buffer, _datatype);
            ++_y;
        }
        
        ++_x;
    }
    
    buffer_delete(_buffer);
    
    return _grid;
}