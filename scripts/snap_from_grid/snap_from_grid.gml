/// @param grid
/// @param datatype

function snap_from_grid(_grid, _datatype)
{
    if (_datatype == buffer_text)
    {
        show_error("Cannot use buffer_text for the datatype\n ", true);
    }
    
    if (_datatype == buffer_string)
    {
        var _sizeof = 1;
    }
    else
    {
        var _sizeof = buffer_sizeof(_datatype);
    }
    
    var _width  = ds_grid_width( _grid);
    var _height = ds_grid_height(_grid);
    var _size = 1 + 4 + 4 + _sizeof*_width*_height;
    
    var _buffer = buffer_create(_size, buffer_grow, 1);
    
    buffer_write(_buffer, buffer_u8,  _datatype);
    buffer_write(_buffer, buffer_u32, _width);
    buffer_write(_buffer, buffer_u32, _height);
    
    var _x = 0;
    repeat(_width)
    {
        var _y = 0;
        repeat(_height)
        {
            buffer_write(_buffer, _datatype, _grid[# _x, _y]);
            ++_y;
        }
        
        ++_x;
    }
    
    var _string = buffer_base64_encode(_buffer, 0, buffer_tell(_buffer));
    buffer_delete(_buffer);
    
    return _string;
}