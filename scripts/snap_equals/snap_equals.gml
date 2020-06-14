/// @return <true> if the two structs contain the same data
/// 
/// @param structA
/// @param structB
/// 
/// @jujuadams 2020-05-25

function snap_equals(_a, _b)
{
    return (new __snap_equals(_a, _b)).result;
}

function __snap_equals(_a, _b) constructor
{
    static compare_struct = function(_a, _b)
    {
        var _length = variable_struct_names_count(_a);
        if (_length != variable_struct_names_count(_b)) return false; //Early out for different struct lengths
        
        var _names = variable_struct_get_names(_a);
        var _i = 0;
        repeat(_length)
        {
            var _name = _names[_i];
            if (!variable_struct_exists(_b, _name)) return false;
            if (!compare_values(variable_struct_get(_a, _name), variable_struct_get(_b, _name))) return false;
            ++_i;
        }
        
        return true;
    };
    
    
    
    static compare_array = function(_a, _b)
    {
        var _length = array_length(_a);
        if (_length != array_length(_b)) return false; //Early out for different array lengths
        
        var _i = 0;
        repeat(_length)
        {
            if (!compare_values(_a[_i], _b[_i])) return false;
            ++_i;
        }
        
        return true;
    };
    
    
    
    static compare_values = function(_a, _b)
    {
        if (is_struct(_a))
        {
            if (!is_struct(_b)) return false;
            return compare_struct(_a, _b);
        }
        else if (is_array(_a))
        {
            if (!is_array(_a)) return false;
            return compare_array(_a, _b);
        }
        else if (typeof(_a) != typeof(_b))
        {
            return false;
        }
        else
        {
            return (_a == _b);
        }
    };
    
    
    
    result = compare_values(_a, _b);
}