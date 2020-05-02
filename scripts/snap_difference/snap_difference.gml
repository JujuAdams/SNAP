/// @param source
/// @param target

/*
    0x01  -  no change
    0x02  -  remove
    0x03  -  add
    0x04  -  edit
    0x05  -  replace
*/

function snap_difference(_source, _target)
{
    return (new __snap_difference(_source, _target)).diff;
}

function __snap_difference(_source, _target) constructor
{
    source = _source;
    target = _target;
    
    
    
    static diff_struct = function(_source, _target)
    {
        var _changed = false;
        var _total_diff_struct = {};
        var _total_diff = [0x01]; //Default to no change
        
        var _source_names = variable_struct_get_names(_source);
        var _target_names = variable_struct_get_names(_target);
        
        //Figure out if anything from the source has been deleted
        var _i = 0;
        repeat(array_length(_source_names))
        {
            var _name = _source_names[_i];
            if (!variable_struct_exists(_target, _name))
            {
                _changed = true;
                variable_struct_set(_total_diff_struct, _name, [0x02]); //Remove
            }
            
            ++_i;
        }
        
        //Check for any added/editted values
        var _i = 0;
        repeat(array_length(_target_names))
        {
            var _name = _target_names[_i];
            if (variable_struct_exists(_source, _name))
            {
                var _diff = diff_value(variable_struct_get(_source, _name), variable_struct_get(_target, _name));
                if (_diff[0] != 0x01) //Only write this diff if there's been a change
                {
                    _changed = true;
                    variable_struct_set(_total_diff_struct, _name, _diff);
                }
            }
            else
            {
                _changed = true;
                
                var _diff = [0x03, snap_deep_copy(variable_struct_get(_target, _name))]; //Add
                variable_struct_set(_total_diff_struct, _name, _diff);
            }
            
            ++_i;
        }
        
        if (_changed)
        {
            _total_diff = [0x04, _total_diff_struct]; //Edit
        }
        
        return _total_diff;
    };
    
    
    
    static diff_array = function(_source, _target)
    {
        var _changed = false;
        var _total_diff_struct = {};
        var _total_diff = [0x01]; //Default to no change
        
        var _source_length = array_length(_source);
        var _target_length = array_length(_target);
        
        if (_source_length != _target_length)
        {
            _changed = true;
            
            if (_source_length > _target_length)
            {
                var _i = _target_length;
                repeat(_source_length - _target_length)
                {
                    variable_struct_set(_total_diff_struct, _i, [0x02]); //Remove
                    ++_i;
                }
            }
            else //_source_length > _target_length
            {
                var _i = _target_length;
                repeat(_target_length - _source_length)
                {
                    var _diff = [0x03, snap_deep_copy(_target[_i])]; //Add
                    
                    variable_struct_set(_total_diff_struct, _i, _diff);
                    ++_i;
                }
            }
        }
        
        //Check for any editted values
        var _i = 0;
        repeat(min(_source_length, _target_length))
        {
            var _diff = diff_value(_source[_i], _target[_i]);
            if (_diff[0] != 0x01) //Only write this diff if there's been a change
            {
                _changed = true;
                variable_struct_set(_total_diff_struct, _i, _diff);
            }
            
            ++_i;
        }
        
        if (_changed)
        {
            _total_diff = [0x04, _total_diff_struct]; //Edit
        }
        
        return _total_diff;
    };
    
    
    
    static diff_value = function(_source, _target)
    {
        if (is_struct(_source) || is_array(_source)
        ||  is_struct(_target) || is_array(_target))
        {
            if (typeof(_source) != typeof(_target))
            {
                var _diff = [0x05, snap_deep_copy(_target)]; //Replace
            }
            else if (is_struct(_source))
            {
                var _diff = diff_struct(_source, _target);
            }
            else if (is_array(_source))
            {
                var _diff = diff_array(_source, _target);
            }
        }
        else if (_source != _target)
        {
            var _diff = [0x04, _target]; //Edit
        }
        else
        {
            var _diff = [0x01]; //No change
        }
        
        return _diff;
    }
    
    
    
    diff = diff_value(source, target);
}