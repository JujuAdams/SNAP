// Feather disable all
/// @return GML string that encodes the struct
/// 
/// @param buffer
/// @param struct                The struct to be encoded. Can contain structs, arrays, strings, and numbers (but the root must be a struct).   N.B. Will not encode ds_list, ds_map etc.
/// @param [alphabetizeStructs]  (bool) Sorts struct variable names is ascending alphabetical order as per ds_list_sort(). Defaults to <false>
/// 
/// @jujuadams 2022-10-30

function SnapBufferWriteGML(_buffer, _struct, _alphabetise = false)
{
    __SnapBufferWriteGMLInner(_buffer, _struct, _alphabetise, 0, "");
}

function __SnapBufferWriteGMLInner(_buffer, _value, _alphabetise, _depth, _indent)
{
    if (is_method(_value)) //Implicitly also a struct so we have to check this first
    {
        buffer_write(_buffer, buffer_text, "\"");
        buffer_write(_buffer, buffer_text, string(_value));
        buffer_write(_buffer, buffer_text, "\"");
    }
    else if (is_struct(_value))
    {
        var _struct = _value;
        var _names = variable_struct_get_names(_struct);
        var _count = array_length(_names);
        var _i = 0;
        
        if (_alphabetise) array_sort(_names, true);
        
        if (_count > 0)
        {
            if (_depth != 0)
            {
                buffer_write(_buffer, buffer_text, "{\n");
                var _preIndent = _indent;
                _indent += "    ";
            }
            
            var _i = 0;
            repeat(_count)
            {
                var _name = _names[_i];
                if (is_struct(_name) || is_array(_name))
                {
                    show_error("SNAP:\nKey type \"" + typeof(_name) + "\" not supported\n ", false);
                    _name = string(ptr(_name));
                }
                
                if (_depth == 0)
                {
                    buffer_write(_buffer, buffer_text, _indent);
                    buffer_write(_buffer, buffer_text, string(_name));
                    buffer_write(_buffer, buffer_text, " = ");
                    __SnapBufferWriteGMLInner(_buffer, _struct[$ _name], _alphabetise, _depth+1, _indent);
                    buffer_write(_buffer, buffer_text, ";\n");
                }
                else
                {
                    buffer_write(_buffer, buffer_text, _indent);
                    buffer_write(_buffer, buffer_text, string(_name));
                    buffer_write(_buffer, buffer_text, ": ");
                    __SnapBufferWriteGMLInner(_buffer, _struct[$ _name], _alphabetise, _depth+1, _indent);
                    buffer_write(_buffer, buffer_text, ",\n");
                }
                
                ++_i;
            }
            
            if (_depth != 0)
            {
                _indent = _preIndent;
                buffer_write(_buffer, buffer_text, _indent);
                buffer_write(_buffer, buffer_text, "}");
            }
        }
        else
        {
            buffer_write(_buffer, buffer_text, "{}");
        }
    }
    else if (is_array(_value))
    {
        var _array = _value;
        var _count = array_length(_array);
        if (_count > 0)
        {
            var _preIndent = _indent;
            _indent += "    ";
            
            buffer_write(_buffer, buffer_text, "[\n");
            
            var _i = 0;
            repeat(_count)
            {
                buffer_write(_buffer, buffer_text, _indent);
                __SnapBufferWriteGMLInner(_buffer, _array[_i], _alphabetise, _depth+1, _indent);
                buffer_write(_buffer, buffer_text, ",\n");
                ++_i;
            }
            
            _indent = _preIndent;
            buffer_write(_buffer, buffer_text, _indent);
            buffer_write(_buffer, buffer_text, "]");
        }
        else
        {
            buffer_write(_buffer, buffer_text, "[]");
        }
    }
    else if (is_string(_value))
    {
        //Sanitise strings
        _value = string_replace_all(_value, "\\", "\\\\");
        _value = string_replace_all(_value, "\n", "\\n");
        _value = string_replace_all(_value, "\r", "\\r");
        _value = string_replace_all(_value, "\t", "\\t");
        _value = string_replace_all(_value, "\"", "\\\"");
        
        buffer_write(_buffer, buffer_text, "\"");
        buffer_write(_buffer, buffer_text, _value);
        buffer_write(_buffer, buffer_text, "\"");
    }
    else if (is_undefined(_value))
    {
        buffer_write(_buffer, buffer_text, "undefined");
    }
    else if (is_bool(_value))
    {
        buffer_write(_buffer, buffer_text, _value? "true" : "false");
    }
    else if (is_real(_value))
    {
        buffer_write(_buffer, buffer_text, SnapNumberToString(_value, true));
    }
    else if (is_ptr(_value))
    {
        buffer_write(_buffer, buffer_text, "ptr(0x");
        buffer_write(_buffer, buffer_text, string(_value));
        buffer_write(_buffer, buffer_text, ")");
    }
    else if (is_int32(_value) || is_int64(_value))
    {
        buffer_write(_buffer, buffer_text, "0x");
        buffer_write(_buffer, buffer_text, string(ptr(_value))); //Cheeky hack to quickly convert to a hex string
    }
    else
    {
        // YoYoGames in their finite wisdom added a new datatype in GMS2022.5 that doesn't stringify nicely
        //     string(instance.id) = "ref 100001"
        // This means we end up writing a string with a space in it to GML. This is leads to invalid output
        // We can check <typeof(id) == "ref"> but string comparison is slow and gross
        // 
        // Instance IDs have the following detectable characteristics:
        // typeof(value)       = "ref"
        // is_array(value)     = false  *
        // is_bool(value)      = false  *
        // is_infinity(value)  = false
        // is_int32(value)     = false  *
        // is_int64(value)     = false  *
        // is_method(value)    = false  *
        // is_nan(value)       = false
        // is_numeric(value)   = true
        // is_ptr(value)       = false  *
        // is_real(value)      = false  *
        // is_string(value)    = false  *
        // is_struct(value)    = false  *
        // is_undefined(value) = false  *
        // is_vec3(value)      = false  *  (covered by is_array())
        // is_vec4(value)      = false  *  (covered by is_array())
        // 
        // Up above we've already tested the datatypes marked with asterisks
        // We can fish out instance references by checking <is_numeric() == true>
        
        if (is_numeric(_value))
        {
            buffer_write(_buffer, buffer_text, string(real(_value))); //Save the numeric component of the instance ID
        }
        else
        {
            buffer_write(_buffer, buffer_text, string(_value));
        }
    }
}
