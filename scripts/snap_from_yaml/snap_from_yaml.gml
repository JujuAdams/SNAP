/// @return Nested struct/array data that represents the contents of the YAML string
/// 
/// @param string  The YAML string to be decoded
/// 
/// @jujuadams 2020-09-16

function snap_from_yaml(_string)
{
    var _buffer = buffer_create(string_byte_length(_string)+1, buffer_fixed, 1);
    buffer_write(_buffer, buffer_text, _string);
    buffer_seek(_buffer, buffer_seek_start, 0);
    var _result = __snap_from_yaml_parser(_buffer, buffer_get_size(_buffer), 0);
    buffer_delete(_buffer);
    return _result;
}

function __snap_from_yaml_parser(_buffer, _buffer_size, _base_indent)
{
    var _result = undefined;
    
    var _indent = _base_indent;
    while(buffer_tell(_buffer) < _buffer_size)
    {
        var _value = buffer_read(_buffer, buffer_u8);
        
        if (_value <= 32)
        {
            if ((_value == 0) || (_value == 10) || (_value == 13))
            {
                break;
            }
            else if (_value == 32)
            {
                ++_indent;
            }
        }
        else if (_value == 45)
        {
            var _next_value = buffer_peek(_buffer, buffer_tell(_buffer), buffer_u8);
            if ((_next_value == 10) || (_next_value == 13) || (_next_value == 32))
            {
                //Gender Reveal: it's an array
                buffer_seek(_buffer, buffer_seek_relative, -1);
                _result = __snap_from_yaml_array(_buffer, _buffer_size, _indent);
                break;
            }
        }
        else
        {
            //It's either a scalar or a struct
            buffer_seek(_buffer, buffer_seek_relative, -1);
            _result = __snap_from_yaml_scalar(_buffer, _buffer_size, _indent, true);
            break;
        }
    }
    
    return _result;
}

function __snap_from_yaml_scalar(_buffer, _buffer_size, _base_indent, _allow_struct)
{
    var _result = undefined;
    var _start_tell = buffer_tell(_buffer);
    
    while(buffer_tell(_buffer) < _buffer_size)
    {
        var _value = buffer_read(_buffer, buffer_u8);
        if (_value <= 32)
        {
            if ((_value == 0) || (_value == 10) || (_value == 13))
            {
                buffer_poke(_buffer, buffer_tell(_buffer)-1, buffer_u8, 0);
                buffer_seek(_buffer, buffer_seek_start, _start_tell);
                var _result = buffer_read(_buffer, buffer_string);
                buffer_poke(_buffer, buffer_tell(_buffer)-1, buffer_u8, _value);
                break;
            }
        }
        else
        {
            if (_value == 58) //Colon :
            {
                if (_allow_struct)
                {
                    buffer_poke(_buffer, buffer_tell(_buffer)-1, buffer_u8, 0);
                    buffer_seek(_buffer, buffer_seek_start, _start_tell);
                    var _key = buffer_read(_buffer, buffer_string);
                    buffer_poke(_buffer, buffer_tell(_buffer)-1, buffer_u8, _value);
                    
                    var _next_value = buffer_peek(_buffer, buffer_tell(_buffer), buffer_u8);
                    if ((_next_value == 10) || (_next_value == 13) || (_next_value == 32))
                    {
                        if (_next_value == 32) buffer_seek(_buffer, buffer_seek_relative, 1);
                        _result = __snap_from_yaml_struct(_buffer, _buffer_size, _base_indent, _key);
                        break;
                    }
                }
                else
                {
                    buffer_poke(_buffer, buffer_tell(_buffer)-1, buffer_u8, 0);
                    buffer_seek(_buffer, buffer_seek_start, _start_tell);
                    var _result = buffer_read(_buffer, buffer_string);
                    buffer_poke(_buffer, buffer_tell(_buffer)-1, buffer_u8, _value);
                    break;
                }
            }
        }
    }
    
    return _result;
}

function __snap_from_yaml_array(_buffer, _buffer_size, _base_indent)
{
    var _array = [];
    
    var _line_start_tell = undefined;
    var _indent = _base_indent;
    while(buffer_tell(_buffer) < _buffer_size)
    {
        var _value = buffer_read(_buffer, buffer_u8);
        if (_value <= 32)
        {
            if ((_value == 0) || (_value == 10) || (_value == 13))
            {
                _line_start_tell = buffer_tell(_buffer)-1;
                _indent = 0;
            }
            else if (_value == 32)
            {
                ++_indent;
            }
        }
        else
        {
            if (_indent < _base_indent)
            {
                buffer_seek(_buffer, buffer_seek_start, _line_start_tell);
                break;
            }
            else if (_value == 45)
            {
                var _next_value = buffer_peek(_buffer, buffer_tell(_buffer), buffer_u8);
                if ((_next_value == 10) || (_next_value == 13) || (_next_value == 32))
                {
                    if (_next_value == 32) buffer_seek(_buffer, buffer_seek_relative, 1);
                    _array[@ array_length(_array)] = __snap_from_yaml_parser(_buffer, _buffer_size, _indent+2);
                    
                    _line_start_tell = buffer_tell(_buffer);
                    _indent = 0;
                }
            }
            else
            {
                show_message("!");
            }
        }
    }
    
    return _array;
}

function __snap_from_yaml_struct(_buffer, _buffer_size, _base_indent, _first_key)
{
    var _struct = {};
    
    var _line_start_tell = undefined;
    var _key = _first_key;
    var _indent = _base_indent;
    while(buffer_tell(_buffer) < _buffer_size)
    {
        var _value = buffer_read(_buffer, buffer_u8);
        if (_value <= 32)
        {
            if ((_value == 0) || (_value == 10) || (_value == 13))
            {
                _line_start_tell = buffer_tell(_buffer)-1;
                _indent = 0;
            }
            else if (_value == 32)
            {
                ++_indent;
            }
        }
        else
        {
            if (_indent < _base_indent)
            {
                buffer_seek(_buffer, buffer_seek_start, _line_start_tell);
                break;
            }
            else if (_value == 45)
            {
                var _next_value = buffer_peek(_buffer, buffer_tell(_buffer), buffer_u8);
                if ((_next_value == 10) || (_next_value == 13) || (_next_value == 32))
                {
                    if (_next_value == 32) buffer_seek(_buffer, buffer_seek_relative, 1);
                    _array[@ array_length(_array)] = __snap_from_yaml_parser(_buffer, _buffer_size, _indent+2);
                    
                    _line_start_tell = buffer_tell(_buffer);
                    _indent = 0;
                }
            }
            else
            {
                show_message("!");
            }
        }
    }
    
    return _struct;
}