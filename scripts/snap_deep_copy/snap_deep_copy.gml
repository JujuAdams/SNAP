/// @returm Copy of the given struct/array, including a copy of any nested structs and arrays
/// 
/// This function is designed to copy simple tree-like structures that have been imported from 
/// 
/// @param struct/array   The struct/array to be copied
/// 
/// @jujuadams 2021-02-14

function snap_deep_copy(_value)
{
    return (new __snap_deep_copy(_value)).copy;
}

function __snap_deep_copy(_value) constructor
{
    source = _value;
    copy = undefined;
    
    
    static copy_struct = function(_source)
    {
        var _copy = {};
        
        var _names = variable_struct_get_names(_source);
        var _i = 0;
        repeat(array_length(_names))
        {
            var _name = _names[_i];
            var _value = variable_struct_get(_source, _name);
            
            if (is_struct(_value))
            {
                _value = copy_struct(_value);
            }
            else if (is_array(_value))
            {
                _value = copy_array(_value);
            }
            else if (is_method(_value))
            {
                var _self = method_get_self(_value);
                if (_self == _source)
                {
                    //If this method is bound to the source struct, create a new method bound to the new struct
                    _value = method(_copy, method_get_index(_value));
                }
                else if (_self != undefined)
                {
                    //If the scope of the method isn't <undefined> (global) then spit out a warning
                    show_debug_message("snap_deep_copy(): Warning! Deep copy found a method reference that could not be appropriately handled");
                }
            }
            
            variable_struct_set(_copy, _name, _value);
            
            ++_i;
        }
        
        return _copy;
    };
    
    
    
    static copy_array = function(_source)
    {
        var _length = array_length(_source);
        var _copy = array_create(_length,);
        
        var _i = 0;
        repeat(_length)
        {
            var _value = _source[_i];
            
            if (is_struct(_value))
            {
                _value = copy_struct(_value);
            }
            else if (is_array(_value))
            {
                _value = copy_array(_value);
            }
            
            _copy[@ _i] = _value;
            
            ++_i;
        }
        
        return _copy;
    };
    
    
    
    if (is_struct(source))
    {
        copy = copy_struct(source);
    }
    else if (is_array(source))
    {
        copy = copy_array(source);
    }
    else
    {
        copy = source;
    }
}