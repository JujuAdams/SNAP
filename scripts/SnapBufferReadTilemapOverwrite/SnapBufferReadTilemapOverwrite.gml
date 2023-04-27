/// @param buffer
/// @param offset
/// @param tilemap
/// @param [readPosition=false]
/// 
/// @jujuadams 2023-04-25

function SnapBufferReadTilemapOverwrite(_buffer, _inOffset, _tilemap, _readPosition = false)
{
    if (_inOffset != undefined)
    {
        var _oldOffset = buffer_tell(_buffer);
        buffer_seek(_buffer, buffer_seek_start, _inOffset);
    }
    
    var _x           = buffer_read(_buffer, buffer_f64);
    var _y           = buffer_read(_buffer, buffer_f64);
    var _width       = buffer_read(_buffer, buffer_u32);
    var _height      = buffer_read(_buffer, buffer_u32);
    var _tilesetName = buffer_read(_buffer, buffer_string); //Not used in this function
    
    if ((tilemap_get_width(_tilemap) != _width) || (tilemap_get_height(_tilemap) != _height))
    {
        show_debug_message("SNAP: Warning! Tilemap size mismatch (read as " + string(_width) + " x " + string(_height) + ", currently " + string(tilemap_get_width(_tilemap)) + " x " + string(tilemap_get_height(_tilemap)) + ")");
    }
    
    if ((tilemap_get_width(_tilemap) > _width) || (tilemap_get_height(_tilemap) > _height))
    {
        tilemap_clear(_tilemap, 0);
    }
    
    if (_readPosition)
    {
        tilemap_x(_tilemap, _x);
        tilemap_y(_tilemap, _y);
    }
    
    var _x = 0;
    repeat(_width)
    {
        var _y = 0;
        repeat(_height)
        {
            tilemap_set(_tilemap, buffer_read(_buffer, buffer_u32), _x, _y);
            ++_y;
        }
        
        ++_x;
    }
    
    if (_inOffset != undefined) buffer_seek(_buffer, buffer_seek_start, _oldOffset);
}