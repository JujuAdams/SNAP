// Feather disable all
/// Executes a method call for each element of every struct found recursively by iterating over an input struct/array assembly.
/// This iterator is deep and will also iterate over nested structs/arrays.
///
/// The specified method is passed the following parameters:
/// 
/// arg0  -  Value found in the given struct/array
/// arg1  -  0-indexed index of the value e.g. =0 for the first element, =1 for the second element etc.
/// arg2  -  The name of the variable that contains the given value; otherwise <undefined>
/// 
/// The order that values are sent into <method> is not guaranteed due to the behaviour of
/// GameMaker's internal hashmap
/// 
/// @param struct/array  Struct/array to be iterated over recursively
/// @param method        Method to call for each element of each struct in the given root struct/array
/// 
/// @jujuadams 2023-10-31

function SnapDeepForeachStruct(_ds, _function)
{
    if (is_struct(_ds))
    {
        var _names = variable_struct_get_names(_ds);
        var _i = 0;
        repeat(array_length(_names))
        {
            var _name  = _names[_i];
            var _value = _ds[$ _name];
            
            _function(_value, _i, _name);
            SnapDeepForeachStruct(_value, _function);
            
            ++_i;
        }
    }
    else if (is_array(_ds))
    {
        var _i = 0;
        repeat(array_length(_ds))
        {
            SnapDeepForeachStruct(_ds[_i], _function);
            ++_i;
        }
    }
}