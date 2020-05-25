/// @return <true> if the two structs contain the same data
/// 
/// @param structA
/// @param structB
/// 
/// @jujuadams 2020-05-25

function snap_equals(_a, _b)
{
    var _length = variable_struct_names_count(_a);
    if (_length != variable_struct_names_count(_b)) return false; //Early out for different struct lengths
    
    var _names = variable_struct_get_names(_a);
    var _i = 0;
    repeat(_length)
    {
        var _name = _names[_i];
        if (variable_struct_get(_a, _name) != variable_struct_get(_b, _name)) return false;
        ++_i;
    }
    
    return true;
}