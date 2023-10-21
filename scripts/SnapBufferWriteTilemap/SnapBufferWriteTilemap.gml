// Feather disable all
/// Stores the contents of a tilemap in a buffer, starting at the buffer's current head position.
/// 
///   N.B. The name of the tileset to use is embedded in the tilemap data so any renamed or
///        deleted tilesets will fail to read.
/// 
/// @param buffer   Buffer to write the data into
/// @param tilemap  Tilemap to serialize
/// 
/// @jujuadams 2023-04-25

function SnapBufferWriteTilemap(_buffer, _tilemap)
{
    var _width  = tilemap_get_width( _tilemap);
    var _height = tilemap_get_height(_tilemap);
    
    buffer_write(_buffer, buffer_f64, tilemap_get_x(_tilemap));
    buffer_write(_buffer, buffer_f64, tilemap_get_y(_tilemap));
    buffer_write(_buffer, buffer_u32, _width);
    buffer_write(_buffer, buffer_u32, _height);
    buffer_write(_buffer, buffer_string, tileset_get_name(tilemap_get_tileset(_tilemap)));
    
    var _x = 0;
    repeat(_width)
    {
        var _y = 0;
        repeat(_height)
        {
            buffer_write(_buffer, buffer_u32, tilemap_get(_tilemap, _x, _y));
            ++_y;
        }
        
        ++_x;
    }
}
