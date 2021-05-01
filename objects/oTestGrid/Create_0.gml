randomize();

grid = ds_grid_create(3, 4);

var _y = 0;
repeat(ds_grid_height(grid))
{
    var _x = 0;
    repeat(ds_grid_width(grid))
    {
        grid[# _x, _y] = irandom_range(4, 912);
        ++_x;
    }
    
    ++_y;
}

var _string = snap_from_grid(grid, buffer_u16);
show_debug_message(_string);
grid_b = snap_to_grid(_string);
show_debug_message(snap_from_grid(grid_b, buffer_u16));