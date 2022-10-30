/// Decodes an NSV buffer and outputs a 2D array
///
/// @return 2D array that represents the contents of the NSV buffer
/// 
/// @param buffer  Buffer to read from
/// @param offset  Where to read from in the buffer
/// 
/// @jujuadams 2022-10-30

function SnapBufferReadNSV(_buffer, _offset)
{
    var _oldTell = buffer_tell(_buffer);
    buffer_seek(_buffer, buffer_seek_start, _offset);
    
    var _width  = buffer_read(_buffer, buffer_u64);
    var _height = buffer_read(_buffer, buffer_u64);
    
    var _rootArray = array_create(_height);
    
    var _y = 0;
    repeat(_height)
    {
        var _rowArray = array_create(_width);
        _rootArray[@ _y] = _rowArray;
        
        var _x = 0;
        repeat(_width)
        {
            _rowArray[@ _x] = buffer_read(_buffer, buffer_string);
            ++_x;
        }
        
        ++_y;
    }
    
    buffer_seek(_buffer, buffer_seek_start, _oldTell);
    
    return _rootArray;
}
