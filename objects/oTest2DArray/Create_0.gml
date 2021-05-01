randomize();

array = [];

var _x = 0;
repeat(3)
{
    var _sub_array = [];
    array[@ _x] = _sub_array;
    
    var _y = 0;
    repeat(4)
    {
        _sub_array[@ _y] = irandom_range(4, 912);
        ++_y;
    }
    
    ++_x;
}

var _string = snap_from_2d_array(array, buffer_u16);
show_debug_message(_string);
array_b = snap_to_2d_array(_string);
show_debug_message(snap_from_2d_array(array_b, buffer_u16));