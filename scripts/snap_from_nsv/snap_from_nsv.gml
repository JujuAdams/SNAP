/// Decodes an NSV buffer and outputs a 2D array
///
/// @return 2D array that represents the contents of the NSV buffer
/// 
/// @param buffer    Buffer to read from
/// @param [offset]  Where to read from in the buffer
/// 
/// @jujuadams 2022-09-23

function snap_from_nsv(_buffer, _offset = buffer_tell(_buffer))
{
    var _old_tell = buffer_tell(_buffer);
    buffer_seek(_buffer, buffer_seek_start, _offset);
    
    //Read out the BOM + "J"
    var _header = buffer_read(_buffer, buffer_u32);
    if (_header != 0x4ABFBBEF) show_error("NSV header not found\n ", true);
    
    var _width  = buffer_read(_buffer, buffer_u64);
    var _height = buffer_read(_buffer, buffer_u64);
    
    var _root_array = array_create(_height);
    
    var _y = 0;
    repeat(_height)
    {
        var _row_array = array_create(_width);
        _root_array[@ _y] = _row_array;
        
        var _x = 0;
        repeat(_width)
        {
            _row_array[@ _x] = buffer_read(_buffer, buffer_string);
            ++_x;
        }
        
        ++_y;
    }
    
    buffer_seek(_buffer, buffer_seek_start, _old_tell);
    return _root_array;
}
