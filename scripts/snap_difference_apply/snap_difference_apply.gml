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
        var _top_diff_struct = _top_diff[1];
        var _top_diff_names = variable_struct_get_names(_top_diff_struct);
        var _i = 0;
        repeat(array_length(_top_diff_names))
        {
            var _name = _top_diff_names[_i];
            var _diff = variable_struct_get(_top_diff_struct, _name);
            
            switch(_diff[0])
            {
                case 0x02: //Remove
                    variable_struct_set(_source, _name, undefined); //TODO - Replace this with a proper deletion once GMS2.3.0 supports it
                break;
                
                case 0x03: //Add
                    variable_struct_set(_source, _name, snap_deep_copy(_diff[1]));
                break;
                
                case 0x04: //Edit
                    var _value = _diff[1];
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
                
                case 0x05: //Replace
                    variable_struct_set(_source, _name, snap_deep_copy(_diff[1]));
                break;
            }
            
            ++_i;
        }
    }
    
    
    
    static apply_to_array = function(_source, _top_diff)
    {
        var _top_diff_struct = _top_diff[1];
        var _top_diff_names = variable_struct_get_names(_top_diff_struct);
        var _i = 0;
        repeat(array_length(_top_diff_names))
        {
            var _name = _top_diff_names[_i];
            var _diff = variable_struct_get(_top_diff_struct, _name);
            var _index = real(_name);
            
            switch(_diff[0])
            {
                case 0x02: //Remove
                    _source[@ _index] = undefined; //TODO - Replace this with a proper deletion once GMS2.3.0 supports it
                break;
                
                case 0x03: //Add
                    _source[@ _index] = snap_deep_copy(_diff[1]);
                break;
                
                case 0x04: //Edit
                    var _value = _diff[1];
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
                
                case 0x05: //Replace
                    _source[@ _index] = snap_deep_copy(_diff[1]);
                break;
            }
            
            ++_i;
        }
    }
    
    
    
    if (_diff[0] != 0x01) //If we have changes
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