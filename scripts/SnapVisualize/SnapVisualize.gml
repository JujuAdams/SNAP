// Feather disable all
/// Returns a human-readable "ASCII art" diagram showing the structure of the input struct/array.
/// 
/// @param value          Value to process for display
/// @param [ascii=false]  Whether to use ASCII compatibility mode

function SnapVisualize(_value, _ascii = false)
{
    static _referenceMap = ds_map_create();
    
    static _buffer = buffer_create(1024, buffer_grow, 1);
    buffer_seek(_buffer, buffer_seek_start, 0);
    
    if (_ascii)
    {
        __SnapVisualizeASCIIInner(_buffer, " ", _value, _referenceMap);
    }
    else
    {
        __SnapVisualizeInner(_buffer, " ", _value, _referenceMap);
    }
    
    buffer_write(_buffer, buffer_u8, 0x00);
    
    ds_map_clear(_referenceMap);
    
    return buffer_peek(_buffer, 0, buffer_string);
}

function __SnapVisualizePointer(_value)
{
    return string_delete(string(ptr(_value)), 1, 8);
}

function __SnapVisualizeInner(_buffer, _prefix, _value, _referenceMap)
{
    if (is_struct(_value))
    {
        if (ds_map_exists(_referenceMap, ptr(_value)))
        {
            buffer_write(_buffer, buffer_text, "{circ ref ");
            buffer_write(_buffer, buffer_text, __SnapVisualizePointer(_value));
            buffer_write(_buffer, buffer_text, "}");
            return;
        }
        
        _referenceMap[? ptr(_value)] = true;
        
        var _struct = _value;
        
        var _instanceOf = instanceof(_struct);
        if (_instanceOf == "struct")
        {
            buffer_write(_buffer, buffer_text, "{struct ");
            buffer_write(_buffer, buffer_text, __SnapVisualizePointer(_value));
            buffer_write(_buffer, buffer_text, "}");
        }
        else
        {
            buffer_write(_buffer, buffer_text, "{");
            buffer_write(_buffer, buffer_text, _instanceOf);
            buffer_write(_buffer, buffer_text, " ");
            buffer_write(_buffer, buffer_text, __SnapVisualizePointer(_value));
            buffer_write(_buffer, buffer_text, "}");
        }
        
        if (variable_struct_names_count(_struct) > 0)
        {
            buffer_write(_buffer, buffer_text, "\n");
            
            var _oldPrefix = _prefix;
            
            var _nameArray = variable_struct_get_names(_struct);
            array_sort(_nameArray, true);
            
            var _i = 0;
            repeat(array_length(_nameArray)-1)
            {
                var _name = _nameArray[_i];
                _prefix = _oldPrefix + "│    ";
                repeat(string_length(_name)) _prefix += " ";
                
                buffer_write(_buffer, buffer_text, _oldPrefix);
                buffer_write(_buffer, buffer_text, "├─ ");
                buffer_write(_buffer, buffer_text, _name);
                buffer_write(_buffer, buffer_text, ":");
                __SnapVisualizeInner(_buffer, _prefix, _struct[$ _name], _referenceMap);
                buffer_write(_buffer, buffer_u8, 0x0a); // newline
                
                ++_i;
            }
            
            var _name = _nameArray[_i];
            buffer_write(_buffer, buffer_text, _oldPrefix);
            buffer_write(_buffer, buffer_text, "╰─ ");
            buffer_write(_buffer, buffer_text, _name);
            buffer_write(_buffer, buffer_text, ":");
            
            _prefix = _oldPrefix + "     ";
            repeat(string_length(_name)) _prefix += " ";
            __SnapVisualizeInner(_buffer, _prefix, _struct[$ _name], _referenceMap);
        }
    }
    else if (is_array(_value))
    {
        if (ds_map_exists(_referenceMap, ptr(_value)))
        {
            buffer_write(_buffer, buffer_text, "[circ ref ");
            buffer_write(_buffer, buffer_text, __SnapVisualizePointer(_value));
            buffer_write(_buffer, buffer_text, "]");
            return;
        }
        
        _referenceMap[? ptr(_value)] = true;
        
        buffer_write(_buffer, buffer_text, "[");
        buffer_write(_buffer, buffer_text, __SnapVisualizePointer(_value));
        buffer_write(_buffer, buffer_text, "]");
        
        if (array_length(_value) > 0)
        {
            buffer_write(_buffer, buffer_text, "\n");
            
            var _array = _value;
            
            var _oldPrefix = _prefix;
            _prefix += "│  ";
            
            var _i = 0;
            repeat(array_length(_array)-1)
            {
                buffer_write(_buffer, buffer_text, _oldPrefix);
                buffer_write(_buffer, buffer_text, "├─");
                __SnapVisualizeInner(_buffer, _prefix, _array[_i], _referenceMap);
                buffer_write(_buffer, buffer_u8, 0x0a); // newline
                ++_i;
            }
            
            _prefix = _oldPrefix + "   ";
            buffer_write(_buffer, buffer_text, _oldPrefix);
            buffer_write(_buffer, buffer_text, "╰─");
            __SnapVisualizeInner(_buffer, _prefix, _array[_i], _referenceMap);
        }
    }
    else if (is_string(_value))
    {
        if (_value == "")
        {
            buffer_write(_buffer, buffer_text, " \"\"");
        }
        else
        {
            buffer_write(_buffer, buffer_text, " \"");
            buffer_write(_buffer, buffer_text, _value);
            buffer_write(_buffer, buffer_text, "\"");
        }
    }
    else
    {
        buffer_write(_buffer, buffer_text, " "); // space
        buffer_write(_buffer, buffer_text, string(_value));
    }
}

function __SnapVisualizeASCIIInner(_buffer, _prefix, _value, _referenceMap)
{
    if (is_struct(_value))
    {
        if (ds_map_exists(_referenceMap, ptr(_value)))
        {
            buffer_write(_buffer, buffer_text, "{circ ref ");
            buffer_write(_buffer, buffer_text, __SnapVisualizePointer(_value));
            buffer_write(_buffer, buffer_text, "}");
            return;
        }
        
        _referenceMap[? ptr(_value)] = true;
        
        var _struct = _value;
        
        var _instanceOf = instanceof(_struct);
        if (_instanceOf == "struct")
        {
            buffer_write(_buffer, buffer_text, "{struct ");
            buffer_write(_buffer, buffer_text, __SnapVisualizePointer(_value));
            buffer_write(_buffer, buffer_text, "}");
        }
        else
        {
            buffer_write(_buffer, buffer_text, "{");
            buffer_write(_buffer, buffer_text, _instanceOf);
            buffer_write(_buffer, buffer_text, " ");
            buffer_write(_buffer, buffer_text, __SnapVisualizePointer(_value));
            buffer_write(_buffer, buffer_text, "}");
        }
        
        if (variable_struct_names_count(_value) > 0)
        {
            buffer_write(_buffer, buffer_text, "\n");
            
            var _oldPrefix = _prefix;
            
            var _nameArray = variable_struct_get_names(_struct);
            array_sort(_nameArray, true);
            
            var _i = 0;
            repeat(array_length(_nameArray)-1)
            {
                var _name = _nameArray[_i];
                _prefix = _oldPrefix + "|    ";
                repeat(string_length(_name)) _prefix += " ";
                
                buffer_write(_buffer, buffer_text, _oldPrefix);
                buffer_write(_buffer, buffer_text, "|- ");
                buffer_write(_buffer, buffer_text, _name);
                buffer_write(_buffer, buffer_text, ":");
                __SnapVisualizeASCIIInner(_buffer, _prefix, _struct[$ _name], _referenceMap);
                buffer_write(_buffer, buffer_text, "\n");
                
                ++_i;
            }
            
            var _name = _nameArray[_i];
            buffer_write(_buffer, buffer_text, _oldPrefix);
            buffer_write(_buffer, buffer_text, "\\- ");
            buffer_write(_buffer, buffer_text, _name);
            buffer_write(_buffer, buffer_text, ":");
            
            _prefix = _oldPrefix + "     ";
            repeat(string_length(_name)) _prefix += " ";
            __SnapVisualizeASCIIInner(_buffer, _prefix, _struct[$ _name], _referenceMap);
        }
    }
    else if (is_array(_value))
    {
        if (ds_map_exists(_referenceMap, ptr(_value)))
        {
            buffer_write(_buffer, buffer_text, "[circ ref ");
            buffer_write(_buffer, buffer_text, __SnapVisualizePointer(_value));
            buffer_write(_buffer, buffer_text, "]");
            return;
        }
        
        _referenceMap[? ptr(_value)] = true;
        
        buffer_write(_buffer, buffer_text, "[");
        buffer_write(_buffer, buffer_text, __SnapVisualizePointer(_value));
        buffer_write(_buffer, buffer_text, "]");
        
        if (array_length(_value) > 0)
        {
            buffer_write(_buffer, buffer_text, "\n");
            
            var _array = _value;
            
            var _oldPrefix = _prefix;
            _prefix += "|  ";
            
            var _array = _value;
            var _i = 0;
            repeat(array_length(_array)-1)
            {
                buffer_write(_buffer, buffer_text, _oldPrefix);
                buffer_write(_buffer, buffer_text, "|-");
                __SnapVisualizeASCIIInner(_buffer, _prefix, _array[_i], _referenceMap);
                buffer_write(_buffer, buffer_text, "\n");
                ++_i;
            }
            
            buffer_write(_buffer, buffer_text, _oldPrefix);
            _prefix = _oldPrefix + "   ";
            
            buffer_write(_buffer, buffer_text, "\\-");
            __SnapVisualizeASCIIInner(_buffer, _prefix, _array[_i], _referenceMap);
        }
    }
    else if (is_string(_value))
    {
        if (_value == "")
        {
            buffer_write(_buffer, buffer_text, " \"\"");
        }
        else
        {
            buffer_write(_buffer, buffer_text, " \"");
            buffer_write(_buffer, buffer_text, _value);
            buffer_write(_buffer, buffer_text, "\"");
        }
    }
    else
    {
        buffer_write(_buffer, buffer_text, " ");
        buffer_write(_buffer, buffer_text, string(_value));
    }
}
