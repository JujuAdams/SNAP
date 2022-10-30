/// @return JSON string that encodes the struct/array nested data
/// 
/// @param buffer                Buffer to write data into
/// @param struct/array          The data to be encoded. Can contain structs, arrays, strings, and numbers.   N.B. Will not encode ds_list, ds_map etc.
/// @param [pretty]              (bool) Whether to format the string to be human readable. Defaults to <false>
/// @param [alphabetizeStructs]  (bool) Sorts struct variable names is ascending alphabetical order as per ds_list_sort(). Defaults to <false>
/// @param [accurateFloats]      (bool) Whether to output floats at a higher accuracy than GM normally defaults to. Defaults to <false>. Setting this to <true> confers a performance penalty
/// 
/// @jujuadams 2022-10-30

function SnapToJSONBuffer(_buffer, _value, _pretty = false, _alphabetise = false, _accurateFloats = false)
{
    return __SnapToJSONBufferValue(_buffer, _value, _pretty, _alphabetise, _accurateFloats, "");
}

function __SnapToJSONBufferValue(_buffer, _value, _pretty, _alphabetise, _accurateFloats, _indent)
{
    if (is_real(_value) || is_int32(_value) || is_int64(_value))
    {
        buffer_write(_buffer, buffer_text, SnapNumberToString(_value, _accurateFloats));
    }
    else if (is_string(_value))
    {
        //Sanitise strings
        _value = string_replace_all(_value, "\\", "\\\\");
        _value = string_replace_all(_value, "\n", "\\n");
        _value = string_replace_all(_value, "\r", "\\r");
        _value = string_replace_all(_value, "\t", "\\t");
        _value = string_replace_all(_value, "\"", "\\\"");
        
        buffer_write(_buffer, buffer_u8,   0x22); // Double quote
        buffer_write(_buffer, buffer_text, _value);
        buffer_write(_buffer, buffer_u8,   0x22); // Double quote
    }
    else if (is_array(_value))
    {
        var _array = _value;
        var _count = array_length(_array);
        var _i = 0;
        
        if (_pretty)
        {
            if (_count > 0)
            {
                buffer_write(_buffer, buffer_u16, 0x0A5B); //Open square bracket + newline
                
                var _preIndent = _indent;
                _indent += chr(0x09); //Tab
                
                repeat(_count)
                {
                    buffer_write(_buffer, buffer_text, _indent);
                    __SnapToJSONBufferValue(_buffer, _array[_i], _pretty, _alphabetise, _accurateFloats, _indent);
                    buffer_write(_buffer, buffer_u16, 0x0A2C); //Comma + newline
                    ++_i;
                }
                
                _indent = _preIndent;
                
                buffer_seek(_buffer, buffer_seek_relative, -2);
                buffer_write(_buffer, buffer_u8, 0x0A); //Newline
                buffer_write(_buffer, buffer_text, _indent);
                buffer_write(_buffer, buffer_u8, 0x5D); //Close square bracket
            }
            else
            {
                buffer_write(_buffer, buffer_u16, 0x5D5B); //Open then close square bracket
            }
        }
        else
        {
            buffer_write(_buffer, buffer_u8, 0x5B); //Open square bracket
            
            repeat(_count)
            {
                __SnapToJSONBufferValue(_buffer, _array[_i], _pretty, _alphabetise, _accurateFloats, _indent);
                buffer_write(_buffer, buffer_u8, 0x2C); //Comma
                ++_i;
            }
            
            if (_count > 0) buffer_seek(_buffer, buffer_seek_relative, -1);
            buffer_write(_buffer, buffer_u8, 0x5D); //Close square bracket
        }
    }
    else if (is_method(_value)) //Implicitly also a struct so we have to check this first
    {
        buffer_write(_buffer, buffer_u8,   0x22); // Double quote
        buffer_write(_buffer, buffer_text, string(_value));
        buffer_write(_buffer, buffer_u8,   0x22); // Double quote
    }
    else if (is_struct(_value))
    {
        var _struct = _value;
        
        var _names = variable_struct_get_names(_struct);
        if (_alphabetise) array_sort(_names, true);
        
        var _count = array_length(_names);
        var _i = 0;
        
        if (_pretty)
        {
            if (_count > 0)
            {
                buffer_write(_buffer, buffer_u16, 0x0A7B); //Open curly bracket + newline
                
                var _preIndent = _indent;
                _indent += chr(0x09); //Tab
                
                repeat(_count)
                {
                    var _name = _names[_i];
                    if (!is_string(_name)) show_error("Keys must be strings\n ", true);
                    
                    buffer_write(_buffer, buffer_text, _indent);
                    buffer_write(_buffer, buffer_u8,   0x22); // Double quote
                    buffer_write(_buffer, buffer_text, string(_name));
                    buffer_write(_buffer, buffer_u32,  0x203A2022); // <" : >
                    
                    __SnapToJSONBufferValue(_buffer, _struct[$ _name], _pretty, _alphabetise, _accurateFloats, _indent);
                    
                    buffer_write(_buffer, buffer_u16, 0x0A2C); //Comma + newline
                    
                    ++_i;
                }
                
                _indent = _preIndent;
                
                buffer_seek(_buffer, buffer_seek_relative, -2);
                buffer_write(_buffer, buffer_u8, 0x0A); //Newline
                buffer_write(_buffer, buffer_text, _indent);
                buffer_write(_buffer, buffer_u8, 0x7D); //Close curly bracket
            }
            else
            {
                buffer_write(_buffer, buffer_u16, 0x7D7B); //Open then close curly bracket
            }
        }
        else
        {
            buffer_write(_buffer, buffer_u8, 0x7B); //Open curly bracket
            
            repeat(_count)
            {
                var _name = _names[_i];
                if (!is_string(_name)) show_error("Keys must be strings\n ", true);
                
                buffer_write(_buffer, buffer_u8,   0x22); // Double quote
                buffer_write(_buffer, buffer_text, string(_name));
                buffer_write(_buffer, buffer_u16,  0x3A22); // Double quote then colon
                
                __SnapToJSONBufferValue(_buffer, _struct[$ _name], _pretty, _alphabetise, _accurateFloats, _indent);
                
                buffer_write(_buffer, buffer_u8, 0x2C); //Comma
                
                ++_i;
            }
            
            buffer_seek(_buffer, buffer_seek_relative, -1);
            buffer_write(_buffer, buffer_u8, 0x7D); //Close curly bracket
        }
    }
    else if (is_undefined(_value))
    {
        buffer_write(_buffer, buffer_text, "null");
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
        // This means we end up writing a string with a space in it to JSON. This is leads to invalid output
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