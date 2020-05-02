/// @param struct/array
/// @param differenceStruct

function snap_difference_apply(_source, _diff)
{
    var _ = new __snap_difference_apply(_source, _diff);
    return _source;
}

/*
    0x01  -  no change
    0x02  -  remove
    0x03  -  add
    0x04  -  edit
    0x05  -  replace
*/

function __snap_difference_apply(_source, _diff) constructor
{
    static apply_to_struct = function(_source, _top_diff)
    {
        var _top_diff_struct = _top_diff.value;
        var _top_diff_names = variable_struct_get_names(_top_diff_struct);
        var _i = 0;
        repeat(array_length(_top_diff_names))
        {
            var _name = _top_diff_names[_i];
            var _diff = variable_struct_get(_top_diff_struct, _name);
            
            switch(_diff.state)
            {
                case "remove":
                    variable_struct_set(_source, _name, undefined); //TODO - Replace this with a proper deletion 
                break;
                
                case "add":
                    variable_struct_set(_source, _name, snap_deep_copy(_diff.value));
                break;
                
                case "edit":
                    var _value = _diff.value;
                    if (is_struct(_value))
                    {
                        apply_to_struct(variable_struct_get(_source, _name), _diff);
                    }
                    else if (is_array(_value))
                    {
                        apply_to_array(variable_struct_get(_source, _name), _diff);
                    }
                    else
                    {
                        variable_struct_set(_source, _name, _value);
                    }
                break;
                
                case "replace":
                    variable_struct_set(_source, _name, snap_deep_copy(_diff.value));
                break;
            }
            
            ++_i;
        }
    }
    
    
    
    static apply_to_array = function(_source, _top_diff)
    {
        var _top_diff_struct = _top_diff.value;
        var _top_diff_names = variable_struct_get_names(_top_diff_struct);
        var _i = 0;
        repeat(array_length(_top_diff_names))
        {
            var _name = _top_diff_names[_i];
            var _diff = variable_struct_get(_top_diff_struct, _name);
            var _index = real(_name);
            
            switch(_diff.state)
            {
                case "remove":
                    _source[@ _index] = undefined;
                break;
                
                case "add":
                    _source[@ _index] = snap_deep_copy(_diff.value);
                break;
                
                case "edit":
                    var _value = _diff.value;
                    if (is_struct(_value))
                    {
                        apply_to_struct(_source[_index], _diff);
                    }
                    else if (is_array(_value))
                    {
                        apply_to_array(_source[_index], _diff);
                    }
                    else
                    {
                        _source[@ _index] = _value;
                    }
                break;
                
                case "replace":
                    _source[@ _index] = snap_deep_copy(_diff.value);
                break;
            }
            
            ++_i;
        }
    }
    
    
    
    if (_diff.state != "no change")
    {
        if (is_struct(_source))
        {
            apply_to_struct(_source, _diff);
        }
        else if( is_array(_source))
        {
            apply_to_array(_source, _diff);
        }
        else
        {
            show_error("Input value was not a struct or array (" + typeof(_source) + ")\n ", false);
        }
    }
}