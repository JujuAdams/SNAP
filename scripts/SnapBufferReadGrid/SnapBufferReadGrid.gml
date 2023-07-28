// Feather disable all
/// @param buffer
/// @param offset
/// 
/// @jujuadams 2022-10-30

function SnapBufferReadGrid(_buffer, _inOffset)
{
    if (_inOffset != undefined)
    {
        var _oldOffset = buffer_tell(_buffer);
        buffer_seek(_buffer, buffer_seek_start, _inOffset);
    }
    
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
    
    if (_inOffset != undefined) buffer_seek(_buffer, buffer_seek_start, _oldOffset);
    
    return _grid;
}
