/// @return QML string that encodes the struct/array nested data
/// 
/// @param buffer                   Buffer to write data into
/// @param struct/array             The data to be encoded. Can contain structs, arrays, strings, and numbers.   N.B. Will not encode ds_list, ds_map etc.
/// @param instanceofDict
/// @param [relaxed=false]
/// @param [accurateFloats=false]   (bool) Whether to output floats at a higher accuracy than GM normally defaults to. Setting this to <true> confers a performance penalty
/// 
/// @jujuadams 2023-01-08

function SnapBufferWriteQML(_buffer, _value, _instanceofDict, _relaxed = false, _accurateFloats = false)
{
    //Invert the instanceof dict for easier lookups
    var _invertedInstanceofDict = {};
    var _namesArray = variable_struct_get_names(_instanceofDict);
    var _i = 0;
    repeat(array_length(_namesArray))
    {
        var _name = _namesArray[_i];
        _invertedInstanceofDict[$ script_get_name(_instanceofDict[$ _name])] = _name;
        ++_i;
    }
    
    return __SnapToQMLBufferValue(_buffer, _value, _invertedInstanceofDict, _relaxed, _accurateFloats, "");
}

function __SnapToQMLBufferValue(_buffer, _value, _invertedInstanceofDict, _relaxed, _accurateFloats, _indent)
{
    var _childrenArrayVariableName = "children";
    
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
        
        //If the string uses reserved characters, wrap the string in quote marks
        //TODO - Use a buffer here since that's probably faster than all these string_pos() checks
        if ((_value == "true")
         || (_value == "false")
         || (_value == "null")
         || (string_pos(":", _value) > 0)
         || (string_pos(";", _value) > 0)
         || (string_pos("{", _value) > 0)
         || (string_pos("}", _value) > 0)
         || (string_pos("[", _value) > 0)
         || (string_pos("]", _value) > 0)
         || (ord(string_char_at(_value, 1)) <= 0x20)
         || (ord(string_char_at(_value, string_length(_value))) <= 0x20))
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
        if (_count <= 0)
        {
            buffer_write(_buffer, buffer_u16, 0x5D5B); //Open then close square bracket
        }
        else
        {
            buffer_write(_buffer, buffer_u16, 0x0A5B); //Open square bracket + newline
            
            var _preIndent = _indent;
            _indent += chr(0x09); //Tab
            
            var _i = 0;
            repeat(_count)
            {
                buffer_write(_buffer, buffer_text, _indent);
                __SnapToQMLBufferValue(_buffer, _array[_i], _invertedInstanceofDict, _relaxed, _accurateFloats, _indent);
                buffer_write(_buffer, buffer_u8, 0x0A); //Newline
                ++_i;
            }
            
            _indent = _preIndent;
            
            buffer_seek(_buffer, buffer_seek_relative, -1);
            buffer_write(_buffer, buffer_u8, 0x0A); //Newline
            buffer_write(_buffer, buffer_text, _indent);
            buffer_write(_buffer, buffer_u8, 0x5D); //Close square bracket
        }
    }
    else if (is_method(_value)) //Implicitly also a struct so we have to check this first
    {
        buffer_write(_buffer, buffer_text, string(_value));
    }
    else if (is_struct(_value))
    {
        var _struct = _value;
        
        var _instanceof = instanceof(_struct);
        var _name = _invertedInstanceofDict[$ _instanceof];
        if (_relaxed && (_name == undefined)) _name = _instanceof;
        if (!is_string(_name)) show_error("SNAP:\nFound struct with unrecognised instanceof \"" + string(_instanceof) + "\"\n ", true);
        
        buffer_write(_buffer, buffer_text, _name);
        buffer_write(_buffer, buffer_u8, 0x20); //Space
        
        var _names = variable_struct_get_names(_struct);
        array_sort(_names, true);
        
        var _count = array_length(_names);
        if (_count <= 0)
        {
            buffer_write(_buffer, buffer_u16, 0x7D7B); //Open then close curly bracket
        }
        else
        {
            buffer_write(_buffer, buffer_u16, 0x0A7B); //Open curly bracket + newline
            
            var _preIndent = _indent;
            _indent += chr(0x09); //Tab
            
            var _hasAttributes = false;
            var _i = 0;
            repeat(_count)
            {
                var _name = _names[_i];
                if (!is_string(_name)) show_error("SNAP:\nKeys must be strings\n ", true);
                
                if not ((_name == _childrenArrayVariableName) && is_array(_struct[$ _name]))
                {
                    _hasAttributes = true;
                    
                    buffer_write(_buffer, buffer_text, _indent);
                    __SnapToQMLBufferValue(_buffer, _name, _invertedInstanceofDict, _relaxed, _accurateFloats, _indent);
                    buffer_write(_buffer, buffer_u16,  0x203A); // <: >
                    
                    __SnapToQMLBufferValue(_buffer, _struct[$ _name], _invertedInstanceofDict, _relaxed, _accurateFloats, _indent);
                    
                    buffer_write(_buffer, buffer_u8, 0x0A); //Newline
                }
                
                ++_i;
            }
            
            //Write children too
            var _childrenArray = _struct[$ _childrenArrayVariableName];
            if (is_array(_childrenArray))
            {
                var _i = 0;
                repeat(array_length(_childrenArray))
                {
                    //Add some spacing between children (and attributes)
                    if ((_i > 0) || _hasAttributes)
                    {
                        buffer_write(_buffer, buffer_text, _indent);
                        buffer_write(_buffer, buffer_u8, 0x0A);
                    }
                    
                    buffer_write(_buffer, buffer_text, _indent);
                    __SnapToQMLBufferValue(_buffer, _childrenArray[_i], _invertedInstanceofDict, _relaxed, _accurateFloats, _indent);
                    buffer_write(_buffer, buffer_u8, 0x0A); //Newline
                    ++_i;
                }
            }
            
            _indent = _preIndent;
            buffer_write(_buffer, buffer_text, _indent);
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
        buffer_write(_buffer, buffer_text, string(_value));
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
