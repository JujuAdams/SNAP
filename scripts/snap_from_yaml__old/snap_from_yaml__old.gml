/// @return Nested struct/array data that represents the contents of the YAML string
/// 
/// @param string  The YAML string to be decoded
/// 
/// @jujuadams 2020-09-16

function snap_from_yaml__old(_string)
{
    var _buffer = buffer_create(string_byte_length(_string)+1, buffer_fixed, 1);
    buffer_write(_buffer, buffer_text, _string);
    buffer_seek(_buffer, buffer_seek_start, 0);
    var _result = __snap_from_yaml_parser__old(_buffer, buffer_get_size(_buffer), 0);
    buffer_delete(_buffer);
    return _result[0];
}

function __snap_from_yaml_parser__old(_buffer, _buffer_size, _start_indent)
{
    var _result = undefined;
    
    var _in_string = false;
    
    var _in_scalar = false;
    
    var _in_struct  = false;
    var _struct_key = undefined;
    var _in_array   = false;
    
    var _indent        = _start_indent;
    var _indent_limit  = _start_indent;
    var _found_content = false;
    var _content_start = undefined;
    
    var _first_line = true;
    var _line_start = buffer_tell(_buffer);
    
    while(buffer_tell(_buffer) < _buffer_size)
    {
        var _value = buffer_read(_buffer, buffer_u8);
        show_debug_message(string_format(buffer_tell(_buffer)-1, 3, 0) + ": " + string(_value) + " " + chr(max(32, _value)));
        
        if (!_found_content)
        {
            //We haven't found non-whitespace yet...
            
            if (_value == 32)
            {
                //If the character was a space, increment our indent count
                ++_indent;
            }
            else if (_value > 32)
            {
                if ((_value == 45) && (buffer_peek(_buffer, buffer_tell(_buffer), buffer_u8) <= 32)) //Hyphen followed by whitespace, which indicates an array
                {
                    _indent += 2; //Treat "- " as indented space
                    buffer_seek(_buffer, buffer_seek_relative, 1); //Jump ahead to skip the whitespace character
                    
                    if ((_indent > _indent_limit) && !_in_array)
                    {
                        //If this indent is larger than the ident that we started at then we've started a new array
                        _indent_limit = _indent;
                        _result = [];
                        _in_array     = true;
                        var _array_ident = irandom(999999);
                        
                        show_debug_message("created array " + string(_array_ident) + ", now adding value");
                        var _returned = __snap_from_yaml_parser__old(_buffer, _buffer_size, _indent);
                        _result[@ array_length(_result)] = _returned[0];
                        show_debug_message("finished adding value, was " + string(_returned));
                        var _indent = _returned[1];
                    }
                    else if (_indent < _indent_limit)
                    {
                        //If this indent is smaller than the ident than we started at then we've exited the previous struct/array
                        break;
                    }
                    else if ((_indent == _indent_limit) && !_first_line)
                    {
                        //If this indent is the same as where we started and this wasn't the first line then we've exited the previous struct/array
                        break;
                    }
                    else if (_in_array)
                    {
                        //Otherwise read the next value from the YAML string and slot it into our array
                        show_debug_message("adding value to array " + string(_array_ident));
                        var _returned = __snap_from_yaml_parser__old(_buffer, _buffer_size, _indent);
                        _result[@ array_length(_result)] = _returned[0];
                        show_debug_message("finished adding value, was " + string(_returned));
                        var _indent = _returned[1];
                    }
                }
                else
                {
                    //We didn't find the start of an array
                    
                    if (_indent <= _indent_limit)
                    {
                        buffer_seek(_buffer, buffer_seek_relative, -1);
                        break;
                    }
                    
                    _content_start = buffer_tell(_buffer)-1;
                    _found_content = true;
                }
            }
            else if ((_value == 10) || (_value == 13))
            {
                _line_start = buffer_tell(_buffer);
                _indent = 0;
                _first_line = false;
            }
        }
        else
        {
            if ((_value == 0) || (_value == 10) || (_value == 13))
            {
                buffer_poke(_buffer, buffer_tell(_buffer)-1, buffer_u8, 0);
                buffer_seek(_buffer, buffer_seek_start, _content_start);
                _result = buffer_read(_buffer, buffer_string);
                break;
            }
        }
    }
    
    return [_result, _indent];
}