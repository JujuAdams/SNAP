randomize();

arrayA = [];

var _x = 0;
repeat(3)
{
    var _sub_array = [];
    arrayA[@ _x] = _sub_array;
    
    var _y = 0;
    repeat(4)
    {
        _sub_array[@ _y] = irandom_range(4, 912);
        ++_y;
    }
    
    ++_x;
}

var _buffer = ScratchBuffer();
SnapBufferWrite2DArray(_buffer, arrayA, buffer_u16);
arrayB = SnapBufferRead2DArray(_buffer, 0);