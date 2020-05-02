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
    
    
    
    static snap_diff = function(_state) constructor
    {
        state = _state; //No change
    }
    
    
    
    static diff_struct = function(_source, _target)
    {
        var _changed = false;
        var _total_diff_struct = {};
        var _total_diff = new snap_diff("no change");
        
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
                variable_struct_set(_total_diff_struct, _name, new snap_diff("remove"));
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
                if (_diff.state != "no change") //Only record the diff if something was changed
                {
                    _changed = true;
                    variable_struct_set(_total_diff_struct, _name, _diff);
                }
            }
            else
            {
                _changed = true;
                
                var _diff = new snap_diff("add");
                _diff.value = snap_deep_copy(variable_struct_get(_target, _name));
                variable_struct_set(_total_diff_struct, _name, _diff);
            }
            
            ++_i;
        }
        
        if (_changed)
        {
            _total_diff.state = "edit";
            _total_diff.value = _total_diff_struct;
        }
        
        return _total_diff;
    };
    
    
    
    static diff_array = function(_source, _target)
    {
        var _changed = false;
        var _total_diff_struct = {};
        var _total_diff = new snap_diff("no change");
        
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
                    variable_struct_set(_total_diff_struct, _i, new snap_diff("remove"));
                    ++_i;
                }
            }
            else //_source_length > _target_length
            {
                var _i = _target_length;
                repeat(_target_length - _source_length)
                {
                    var _diff = new snap_diff("add");
                    _diff.value = snap_deep_copy(_target[_i]);
                    
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
            if (_diff.state != "no change") //Only record the diff if something was changed
            {
                _changed = true;
                variable_struct_set(_total_diff_struct, _i, _diff);
            }
            
            ++_i;
        }
        
        if (_changed)
        {
            _total_diff.state = "edit";
            _total_diff.value = _total_diff_struct;
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
                var _diff = new snap_diff("replace");
                _diff.value = snap_deep_copy(_target);
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
            var _diff = new snap_diff("edit");
            _diff.value = _target;
        }
        else
        {
            var _diff = new snap_diff("no change");
        }
        
        return _diff;
    }
    
    
    
    diff = diff_value(source, target);
}