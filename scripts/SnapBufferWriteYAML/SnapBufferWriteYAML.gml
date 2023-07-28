// Feather disable all
/// @return YAML string that encodes the struct/array nested data
/// 
/// @param struct/array          The data to be encoded. Can contain structs, arrays, strings, and numbers.   N.B. Will not encode ds_list, ds_map etc.
/// @param [alphabetizeStructs]  (bool) Sorts struct variable names is ascending alphabetical order as per ds_list_sort(). Defaults to <false>
/// 
/// @jujuadams 2022-11-26

function SnapBufferWriteYAML(_buffer, _ds, _alphabetise = false, accurateFloats = false)
{
    return __SnapToYAMLBufferValue(_buffer, _ds, _alphabetise, accurateFloats, 0);
}

function __SnapToYAMLBufferValue(_buffer, _value, _alphabetise, _accurateFloats, _indent)
{
    if (is_real(_value) || is_int32(_value) || is_int64(_value))
    {
        buffer_write(_buffer, buffer_text, SnapNumberToString(_value, _accurateFloats));
    }
    else if (is_string(_value))
    {
        var _length = string_length(_value);
            
        //Sanitise strings
        var _hasColon = (string_pos(":", _value) > 0);
        _value = string_replace_all(_value, "\\", "\\\\");
        _value = string_replace_all(_value, "\"", "\\\"");
        _value = string_replace_all(_value, "\n", "\\n");
        _value = string_replace_all(_value, "\r", "\\r");
        _value = string_replace_all(_value, "\t", "\\t");
            
        if ((_length != string_length(_value)) || _hasColon) //If our length changed then we have escaped characters
        {
            buffer_write(_buffer, buffer_u8,   0x22); // Double quote
            buffer_write(_buffer, buffer_text, _value);
            buffer_write(_buffer, buffer_u8,   0x22); // Double quote
        }
        else
        {
            buffer_write(_buffer, buffer_text, _value);
        }
    }
    else if (is_array(_value))
    {
        var _array = _value;
        var _count = array_length(_array);
        if (_count > 0)
        {
            var _i = 0;
            repeat(_count)
            {
                _value = _array[_i];
                
                if (_i > 0) repeat(_indent) buffer_write(_buffer, buffer_u16, 0x2020);
                buffer_write(_buffer, buffer_u16, 0x202D);
                _indent++;
                __SnapToYAMLBufferValue(_buffer, _value, _alphabetise, _accurateFloats, _indent);
                _indent--;
                buffer_write(_buffer, buffer_u8, 0x0A);
                    
                ++_i;
            }
            
            buffer_seek(_buffer, buffer_seek_relative, -1);
        }
        else
        {
            buffer_write(_buffer, buffer_u16, 0x5D5B); //Open then close square bracket
        }
    }
    else if (is_method(_value)) //Implicitly also a struct so we have to check this first
    {
        buffer_write(_buffer, buffer_text, string(_value));
    }
    else if (is_struct(_value))
    {
        var _struct = _value;
        var _namesArray = variable_struct_get_names(_struct);
        if (_alphabetise) array_sort(_namesArray, true);
        
        var _count = array_length(_namesArray);
        if (_count > 0)
        {
            var _i = 0;
            repeat(_count)
            {
                var _name = _namesArray[_i];
                _value = _struct[$ _name];
                
                if (is_struct(_name) || is_array(_name))
                {
                    show_error("SNAP:\nKey type \"" + typeof(_name) + "\" not supported\n ", false);
                    _name = string(ptr(_name));
                }
                
                if (_i > 0) repeat(_indent) buffer_write(_buffer, buffer_u16, 0x2020);
                buffer_write(_buffer, buffer_text, string(_name));
                buffer_write(_buffer, buffer_u16, 0x203A); //Comma followed by a space
                
                if (is_struct(_value))
                {
                    if (variable_struct_names_count(_value) > 0)
                    {
                        buffer_write(_buffer, buffer_u8, 0x0A);
                        repeat(_indent+1) buffer_write(_buffer, buffer_u16, 0x2020);
                    }
                    
                    _indent++;
                    __SnapToYAMLBufferValue(_buffer, _value, _alphabetise, _accurateFloats, _indent);
                    _indent--;
                }
                else if (is_array(_value))
                {
                    if (array_length(_value) > 0)
                    {
                        buffer_write(_buffer, buffer_u8, 0x0A);
                        repeat(_indent) buffer_write(_buffer, buffer_u16, 0x2020);
                    }
                    
                    __SnapToYAMLBufferValue(_buffer, _value, _alphabetise, _accurateFloats, _indent);
                }
                else
                {
                    _indent++;
                    __SnapToYAMLBufferValue(_buffer, _value, _alphabetise, _accurateFloats, _indent);
                    _indent--;
                }
                
                buffer_write(_buffer, buffer_u8, 0x0A);
                
                ++_i;
            }
            
            buffer_seek(_buffer, buffer_seek_relative, -1);
        }
        else
        {
            buffer_write(_buffer, buffer_u16, 0x7D7B); //Open then close curly bracket
        }
    }
    else if (is_undefined(_value))
    {
        //Empty!
    }
    else if (is_bool(_value))
    {
        buffer_write(_buffer, buffer_text, _value? "true" : "false");
    }
    else if (is_ptr(_value))
    {
        //Not 100% sure if the quote delimiting is necessary but better safe than sorry
        buffer_write(_buffer, buffer_u8,   0x22);
        buffer_write(_buffer, buffer_text, string(_value));
        buffer_write(_buffer, buffer_u8,   0x22);
    }
    else
    {
        // YoYoGames in their finite wisdom added a new datatype in GMS2022.5 that doesn't stringify nicely
        //     string(instance.id) = "ref 100001"
        // This means we end up writing a string with a space in it to YAML. This is leads to difficulties when deserializing data
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
        // We can fish out instance references by checking <is_numeric() == true> and then excluding int32 and int64 datatypes
            
        if (is_numeric(_value))
        {
            buffer_write(_buffer, buffer_text, string(real(_value))); //Save the numeric component of the instance ID
        }
        else
        {
            buffer_write(_buffer, buffer_text, string(_value));
        }
    }
    
    return _buffer;
}
