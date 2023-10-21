// Feather disable all
/// @return N/A (0)
/// 
/// Executes a method call for each element of the given struct/array/data structure.
/// This iterator is shallow and will not also iterate over nested structs/arrays (though
/// you can of course call SnapForeach() inside the specified method)
/// 
/// This function can also iterate over all members of a ds_map, ds_list, or ds_grid.
/// You will need to specify a value for [dsType] to iterate over a data structure
///
/// The specified method is passed the following parameters:
/// 
/// arg0  -  Value found in the given struct/array
/// arg1  -  0-indexed index of the value e.g. =0 for the first element, =1 for the second element etc.
/// arg2  -  When iterating over structs, the name of the variable that contains the given value; otherwise <undefined>
/// 
/// The order that values are sent into <method> is guaranteed for arrays (starting at
/// index 0 and ascending), but is not guaranteed for structs due to the behaviour of
/// GameMaker's internal hashmap
/// 
/// @param struct/array/ds   Struct/array/data structure to be iterated over
/// @param method            Method to call for each element of this given struct/array/ds
/// @param [dsType]          Data structure type if iterating over a data structure
/// 
/// @jujuadams 2022-10-30

function SnapForeach()
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
            _function(_ds[_i], _i, undefined);
            ++_i;
        }
    }
    else switch(_ds_type)
    {
        case ds_type_list:
            var _i = 0;
            repeat(ds_list_size(_ds))
            {
                _function(_ds[| _i], _i, undefined);
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
            show_error("SNAP:\nCannot iterate over datatype \"" + string(typeof(_ds)) + "\"\n ", false);
        break;
    }
}
