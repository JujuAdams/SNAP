/// @return VDF string that encodes the struct/array nested data
/// 
/// N.B. This function cannot encode arrays, and any numbers will be stringified
/// 
/// @param buffer            Buffer to write data into
/// @param struct            The data to be encoded. Can contain structs and strings.   N.B. Will not encode a ds_map
/// @param [alphabetize]     (bool) Sorts struct keys in ascending alphabetical order as per array_sort(). Defaults to <false>
/// @param [accurateFloats]  (bool) Whether to stringify floats at a higher accuracy than GM normally defaults to. Defaults to <false>. Setting this to <true> confers a performance penalty
/// 
/// @jujuadams 2023-03-25

function SnapBufferWriteVDF(_buffer, _value, _alphabetise = false, _accurateFloats = false)
{
    return __SnapToVDFBufferValue(_buffer, _value, _alphabetise, _accurateFloats, "");
}

function __SnapToVDFBufferValue(_buffer, _value, _alphabetise, _accurateFloats, _indent)
{
    if (is_array(_value))
    {
        show_error("SNAP:\nArrays are not supported by the VDF format\n ", true);
    }
    else if (is_method(_value)) //Implicitly also a struct so we have to check this first
    {
        buffer_write(_buffer, buffer_u16,  0x2220); // Space + double quote
        buffer_write(_buffer, buffer_text, string(_value));
        buffer_write(_buffer, buffer_u8,   0x22); // Double quote
    }
    else if (is_struct(_value))
    {
        var _struct = _value;
        
        var _names = variable_struct_get_names(_struct);
        if (_alphabetise) array_sort(_names, true);
        
        buffer_write(_buffer, buffer_u8,  0x0A); //Newline
        buffer_write(_buffer, buffer_text, _indent);
        buffer_write(_buffer, buffer_u16, 0x0A7B); //Open curly bracket + newline
        
        var _count = array_length(_names);
        if (_count > 0)
        {
            var _preIndent = _indent;
            _indent += chr(0x09); //Tab
            
            var _i = 0;
            repeat(_count)
            {
                var _name = _names[_i];
                if (!is_string(_name)) show_error("SNAP:\nKeys must be strings\n ", true);
                
                buffer_write(_buffer, buffer_text, _indent);
                buffer_write(_buffer, buffer_u8,   0x22); // Double quote
                buffer_write(_buffer, buffer_text, string(_name));
                buffer_write(_buffer, buffer_u8,  0x22); // Double quote
                
                __SnapToVDFBufferValue(_buffer, _struct[$ _name], _alphabetise, _accurateFloats, _indent);
                
                buffer_write(_buffer, buffer_u8, 0x0A); //Newline
                
                ++_i;
            }
            
            _indent = _preIndent;
        }
        
        buffer_write(_buffer, buffer_text, _indent);
        buffer_write(_buffer, buffer_u8, 0x7D); //Close curly bracket
    }
    else
    {
        _value = string(_value);
        
        //Sanitise strings
        _value = string_replace_all(_value, "\\", "\\\\");
        _value = string_replace_all(_value, "\n", "\\n");
        _value = string_replace_all(_value, "\r", "\\r");
        _value = string_replace_all(_value, "\t", "\\t");
        _value = string_replace_all(_value, "\"", "\\\"");
        
        buffer_write(_buffer, buffer_u16,  0x2220); // Space + double quote
        buffer_write(_buffer, buffer_text, _value);
        buffer_write(_buffer, buffer_u8,   0x22); // Double quote
    }
    
    return _buffer;
}
