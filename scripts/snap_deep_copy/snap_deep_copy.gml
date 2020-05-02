/// @param struct/array

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
                _value = copy_struct(_source);
            }
            else if (is_array(_value))
            {
                _value = copy_array(_source);
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
                _value = copy_struct(_source);
            }
            else if (is_array(_value))
            {
                _value = copy_array(_source);
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