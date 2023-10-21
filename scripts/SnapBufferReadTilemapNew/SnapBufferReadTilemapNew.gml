// Feather disable all
/// Creates a new tilemap on the given layer. The tilemap's dimensions and position will be set to
/// whatever is in the data found in the buffer. If you do **not** specify an offset then SNAP will
/// modify the buffer's "head" position. This allows you to read sequential data more easily.
/// 
///   N.B. The name of the tileset to use is embedded in the tilemap data so any renamed or
///        deleted tilesets will fail to read.
/// 
/// @param buffer  Buffer to write the data into                                                                                                                      
/// @param offset  The position in the buffer to read the tilemap from, relative to the start of the buffer. If set to <undefined>, the buffer's head position is used
/// @param layer   Name of room layer to create the tilemap on                                                                                                        
/// 
/// @jujuadams 2023-04-25

function SnapBufferReadTilemapNew(_buffer, _inOffset, _layer)
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
    var _tilesetName = buffer_read(_buffer, buffer_string);
    
    var _assetType = asset_get_type(_tilesetName);
    var _tileset   = asset_get_index(_tilesetName);
    
    if (_tileset < 0) show_error("SNAP:\nTileset \"" + string(_tilesetName) + "\" not found\n ", true);
    if (_assetType != asset_tiles) show_error("SNAP:\nAsset \"" + string(_tilesetName) + "\" is not a tileset\n ", true);
    
    var _tilemap = layer_tilemap_create(_layer, _x, _y, _tileset, _width, _height);
    
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
