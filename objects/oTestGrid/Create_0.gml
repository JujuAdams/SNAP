randomize();

gridA = ds_grid_create(3, 4);

var _y = 0;
repeat(ds_grid_height(gridA))
{
    var _x = 0;
    repeat(ds_grid_width(gridA))
    {
        gridA[# _x, _y] = irandom_range(4, 912);
        ++_x;
    }
    
    ++_y;
}

var _buffer = ScratchBuffer();
SnapBufferWriteGrid(_buffer, gridA, buffer_u16);
gridB = SnapBufferReadGrid(_buffer, 0);