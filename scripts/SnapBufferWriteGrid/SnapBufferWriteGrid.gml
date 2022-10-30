/// @param buffer
/// @param grid
/// @param datatype
/// 
/// @jujuadams 2022-10-30

function SnapBufferWriteGrid(_buffer, _grid, _datatype)
{
    if (_datatype == buffer_text)
    {
        show_error("Cannot use buffer_text for the datatype\n ", true);
    }
    
    var _width  = ds_grid_width( _grid);
    var _height = ds_grid_height(_grid);
    
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
}