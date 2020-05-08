/// @param struct/array/ds
/// @param function
/// @param [dsType]

function foreach()
{
    var _ds       = argument[0];
    var _function = argument[1];
    var _ds_type  = (argument_count > 2)? argument[2] : undefined;
    
    if (is_struct(_ds))
    {
        var _names = variable_struct_get_names(_ds);
        var _i = 0;
        repeat(array_length(_names))
        {
            var _name = _names[_i];
            _function(variable_struct_get(_ds, _name), _i, _name);
            ++_i;
        }
    }
    else if (is_array(_ds))
    {
        var _i = 0;
        repeat(array_length(_ds))
        {
            _function(_ds[_i], _i);
            ++_i;
        }
    }
    else switch(_ds_type)
    {
        case ds_type_list:
            var _i = 0;
            repeat(ds_list_size(_ds))
            {
                _function(_ds[| _i], _i);
                ++_i;
            }
        break;
        
        case ds_type_map:
            var _i = 0;
            var _key = ds_map_find_first(_ds);
            repeat(ds_map_size(_ds))
            {
                _function(_ds[? _key], _i, _key);
                _key = ds_map_find_next(_ds, _key);
                ++_i;
            }
        break;
        
        case ds_type_grid:
            var _w = ds_grid_width( _ds);
            var _h = ds_grid_height(_ds);
            
            var _y = 0;
            repeat(_h)
            {
                var _x = 0;
                repeat(_w)
                {
                    _function(_ds[# _x, _y], _x, _y);
                    ++_x;
                }
                
                ++_y;
            }
        break;
        
        default:
            show_error("Cannot iterate over datatype \"" + string(typeof(_ds)) + "\"\n ", false);
        break;
    }
}