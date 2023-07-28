// Feather disable all
/// @param buffer
/// @param array2D
/// @param datatype
/// 
/// @jujuadams 2022-10-30

function SnapBufferWrite2DArray(_buffer, _array, _datatype)
{
    if (_datatype == buffer_text)
    {
        show_error("SNAP:\nCannot use buffer_text for the datatype\n ", true);
    }
    
    var _width  = array_length(_array);
    var _height = array_length(_array[0]);
    
    buffer_write(_buffer, buffer_u8,  _datatype);
    buffer_write(_buffer, buffer_u32, _width);
    buffer_write(_buffer, buffer_u32, _height);
    
    var _x = 0;
    repeat(_width)
    {
        var _sub_array = _array[_x];
        var _y = 0;
        repeat(_height)
        {
            buffer_write(_buffer, _datatype, _sub_array[_y]);
            ++_y;
        }
        
        ++_x;
    }
}
