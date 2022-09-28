
/// @return Nested struct/array data that represents the contents of the JSON string
/// 
/// @param string  The JSON string to be decoded
/// 
/// @jujuadams 2020-09-28

function snap_from_json(_string)
{
    var _buffer = buffer_create(string_byte_length(_string)+1, buffer_fixed, 1);
    buffer_write(_buffer, buffer_string, _string);
    buffer_seek(_buffer, buffer_seek_start, 0);
    
    var _cache_buffer = buffer_create(1024, buffer_grow, 1);
    
    var _read_start        = undefined;
    var _in_string         = false;
    var _string_uses_cache = false;
    var _in_value          = false;
    var _expecting_comma   = false;
    var _expecting_colon   = false;
    
    var _in_struct_key   = false;
    var _struct_key      = undefined;
    var _in_struct_value = false;
    var _in_array        = false;
    
    var _in_comment            = false;
    var _in_multiline_comment  = false;
    var _new_comment           = false;
    var _new_multiline_comment = false;
    
    var _stack     = [];
    var _root      = undefined;
    var _stack_top = undefined;
    
    var _buffer_size = buffer_get_size(_buffer);
    while(buffer_tell(_buffer) < _buffer_size)
    {
        var _byte = buffer_read(_buffer, buffer_u8);
        if (_byte == 0x00) break;
        
        if (_in_comment)
        {
            if ((_byte == ord("\n")) || (_byte == ord("\r")))
            {
                _in_comment = false;
            }
        }
        else if (_in_multiline_comment)
        {
            if ((_byte == ord("*")) && (buffer_read(_buffer, buffer_u8) == ord("/")))
            {
                _in_multiline_comment = false;
            }
        }
        else if (_in_string)
        {
            if (_byte == ord("\""))
            {
                if (_string_uses_cache)
                {
                    _string_uses_cache = false;
                    
                    buffer_write(_cache_buffer, buffer_u8, 0x00);
                    buffer_seek(_cache_buffer, buffer_seek_start, 0);
                    var _value = buffer_read(_cache_buffer, buffer_string);
                }
                else
                {
                    buffer_poke(_buffer, buffer_tell(_buffer)-1, buffer_u8, 0x00);
                    buffer_seek(_buffer, buffer_seek_start, _read_start);
                    var _value = buffer_read(_buffer, buffer_string);
                }
                    
                //Reset string handling values
                _in_string         = false;
                _string_uses_cache = false;
                
                if (_in_struct_key)
                {
                    _expecting_colon = true;
                    _struct_key      = _value;
                }
                else if (_in_struct_value)
                {
                    _expecting_comma = true;
                    _stack_top[$ _struct_key] = _value;
                    _struct_key = undefined;
                }
                else if (_in_array)
                {
                    _expecting_comma = true;
                    array_push(_stack_top, _value);
                }
            }
            else if (_byte == ord("\\"))
            {
                if (!_string_uses_cache)
                {
                    _string_uses_cache = true;
                    buffer_seek(_cache_buffer, buffer_seek_start, 0);
                }
                
                var _size = buffer_tell(_buffer) - _read_start-1;
                buffer_copy(_buffer, _read_start, _size, _cache_buffer, buffer_tell(_cache_buffer));
                buffer_seek(_cache_buffer, buffer_seek_relative, _size);
                
                var _next_byte = buffer_read(_buffer, buffer_u8);
                switch(_next_byte)
                {
                    case ord("n"): buffer_write(_cache_buffer, buffer_u8, ord("\n")); break;
                    case ord("r"): buffer_write(_cache_buffer, buffer_u8, ord("\r")); break;
                    case ord("t"): buffer_write(_cache_buffer, buffer_u8, ord("\t")); break;
                    
                    case ord("u"):
                        var _old_value = buffer_peek(_buffer, buffer_tell(_buffer)+4, buffer_u8);
                        buffer_poke(_buffer, buffer_tell(_buffer)+4, buffer_u8, 0x00);
                        var _hex = buffer_read(_buffer, buffer_string);
                        buffer_seek(_buffer, buffer_seek_relative, -1);
                        buffer_poke(_buffer, buffer_tell(_buffer), buffer_u8, _old_value);
                        
                        var _value = int64(ptr(_hex));
                        if (_value <= 0x7F) //0xxxxxxx
                        {
                            buffer_write(_cache_buffer, buffer_u8, _value);
                        }
                        else if (_value <= 0x07FF) //110xxxxx 10xxxxxx
                        {
                            buffer_write(_cache_buffer, buffer_u8, 0xC0 | ((_value >> 6) & 0x1F));
                            buffer_write(_cache_buffer, buffer_u8, 0x80 | ( _value       & 0x3F));
                        }
                        else if (_value <= 0xFFFF) //1110xxxx 10xxxxxx 10xxxxxx
                        {
                            buffer_write(_cache_buffer, buffer_u8, 0xC0 | ( _value        & 0x0F));
                            buffer_write(_cache_buffer, buffer_u8, 0x80 | ((_value >>  4) & 0x3F));
                            buffer_write(_cache_buffer, buffer_u8, 0x80 | ((_value >> 10) & 0x3F));
                        }
                        else if (_value <= 0x10000) //11110xxx 10xxxxxx 10xxxxxx 10xxxxxx
                        {
                            buffer_write(_cache_buffer, buffer_u8, 0xC0 | ( _value        & 0x07));
                            buffer_write(_cache_buffer, buffer_u8, 0x80 | ((_value >>  3) & 0x3F));
                            buffer_write(_cache_buffer, buffer_u8, 0x80 | ((_value >>  9) & 0x3F));
                            buffer_write(_cache_buffer, buffer_u8, 0x80 | ((_value >> 15) & 0x3F));
                        }
                    break;
                    
                    default:
                        if ((_next_byte & $E0) == $C0) //110xxxxx 10xxxxxx
                        {
                            buffer_copy(_buffer, buffer_tell(_buffer)+1, 1, _cache_buffer, buffer_tell(_cache_buffer));
                            buffer_seek(_buffer, buffer_seek_relative, 1);
                            buffer_seek(_cache_buffer, buffer_seek_relative, 1);
                        }
                        else if ((_next_byte & $F0) == $E0) //1110xxxx 10xxxxxx 10xxxxxx
                        {
                            buffer_copy(_buffer, buffer_tell(_buffer)+1, 2, _cache_buffer, buffer_tell(_cache_buffer));
                            buffer_seek(_buffer, buffer_seek_relative, 2);
                            buffer_seek(_cache_buffer, buffer_seek_relative, 2);
                        }
                        else if ((_next_byte & $F8) == $F0) //11110xxx 10xxxxxx 10xxxxxx 10xxxxxx
                        {
                            buffer_copy(_buffer, buffer_tell(_buffer)+1, 3, _cache_buffer, buffer_tell(_cache_buffer));
                            buffer_seek(_buffer, buffer_seek_relative, 3);
                            buffer_seek(_cache_buffer, buffer_seek_relative, 3);
                        }
                        else
                        {
                            buffer_write(_cache_buffer, buffer_u8, _next_byte);
                        }
                    break;
                }
                
                _read_start = buffer_tell(_buffer);
            }
        }
        else if (_in_value)
        {
            if (_byte == ord("/"))
            {
                var _next_byte = buffer_peek(_buffer, buffer_tell(_buffer), buffer_u8);
                if (_next_byte == ord("/"))
                {
                    _new_comment = true;
                }
                else if (_next_byte == ord("*"))
                {
                    _new_multiline_comment = true;
                }
            }
            
            if ((_byte <= 0x20) || (_byte == ord(",")) || (_byte == ord("]")) || (_byte == ord("}")) || _new_comment || _in_multiline_comment)
            {
                var _old_value = buffer_peek(_buffer, buffer_tell(_buffer)-1, buffer_u8);
                buffer_poke(_buffer, buffer_tell(_buffer)-1, buffer_u8, 0x00);
                buffer_seek(_buffer, buffer_seek_start, _read_start);
                var _value = buffer_read(_buffer, buffer_string);
                buffer_poke(_buffer, buffer_tell(_buffer)-1, buffer_u8, _old_value);
                
                switch(_value)
                {
                    case "true":  _value = true;      break;
                    case "false": _value = false;     break;
                    case "null":  _value = undefined; break;
                    
                    default:
                        try
                        {
                            _value = real(_value);
                        }
                        catch(_error)
                        {
                            show_debug_message(_error);
                            show_error("Could not convert \"" + string(_value) + "\" to numerical value\n ", true);
                        }
                    break;
                }
                
                //Reset value handling values
                _in_value = false;
                
                if (_in_struct_value)
                {
                    _stack_top[$ _struct_key] = _value;
                    _struct_key = undefined;
                }
                else if (_in_array)
                {
                    array_push(_stack_top, _value);
                }
                
                if (_new_comment)
                {
                    _new_comment = false;
                    _in_comment  = true;
                    buffer_seek(_buffer, buffer_seek_relative, 1);
                }
                else if (_new_multiline_comment)
                {
                    _new_multiline_comment = false;
                    _in_multiline_comment  = true;
                    buffer_seek(_buffer, buffer_seek_relative, 1);
                }
                else
                {
                    _expecting_comma = true;
                    buffer_seek(_buffer, buffer_seek_relative, -1);
                } 
            }
        }
        else
        {
            //Searching for the start to a string or value
            switch(_byte)
            {
                case ord(","):
                    if (_expecting_comma)
                    {
                        _expecting_comma = false;
                        
                        if (_in_struct_value)
                        {
                            _in_struct_key   = true;
                            _in_struct_value = false;
                        }
                    }
                    else
                    {
                        show_error("Found unexpected comma\n ", true);
                    }
                break;
                
                case ord(":"):
                    if (_expecting_colon)
                    {
                        _expecting_colon = false;
                        _in_struct_key   = false;
                        _in_struct_value = true;
                    }
                    else
                    {
                        show_error("Found unexpected colon\n ", true);
                    }
                break;
                
                case ord("\""):
                    if (_expecting_comma)
                    {
                        show_error("Found \", was expecting comma\n ", true);
                    }
                    else if (_expecting_colon)
                    {
                        show_error("Found \", was expecting colon\n ", true);
                    }
                    else
                    {
                        _read_start = buffer_tell(_buffer);
                        _in_string = true;
                    }
                break;
                
                case ord("["):
                    if (_expecting_comma)
                    {
                        show_error("Found [, was expecting comma\n ", true);
                    }
                    else if (_expecting_colon)
                    {
                        show_error("Found [, was expecting colon\n ", true);
                    }
                    else
                    {
                        var _new_stack_top = [];
                        
                        if (_in_struct_key)
                        {
                            show_error("Cannot use an array as a struct key\n ", true);
                        }
                        else if (_in_struct_value)
                        {
                            _stack_top[$ _struct_key] = _new_stack_top;
                        }
                        else if (_in_array)
                        {
                            array_push(_stack_top, _new_stack_top);
                        }
                        
                        if (_root == undefined) _root = _new_stack_top;
                        array_push(_stack, _new_stack_top);
                        _stack_top = _new_stack_top;
                        
                        _expecting_comma = false;
                        _in_struct_key   = false;
                        _in_struct_value = false;
                        _in_array        = true;
                    }
                break;
                
                case ord("]"):
                    if (_in_array)
                    {
                        _expecting_comma = true;
                        
                        array_pop(_stack);
                        _stack_top = (array_length(_stack) <= 0)? undefined : _stack[array_length(_stack)-1];
                        
                        if (is_struct(_stack_top))
                        {
                            _in_struct_key   = true;
                            _in_struct_value = false;
                            _in_array        = false;
                        }
                        else if (is_array(_stack_top))
                        {
                            _in_struct_key   = false;
                            _in_struct_value = false;
                            _in_array        = true;
                        }
                    }
                    else
                    {
                        show_error("Found unexpected ]\n ", true);
                    }
                break;
                
                case ord("{"):
                    if (_expecting_comma)
                    {
                        show_error("Found {, was expecting comma\n ", true);
                    }
                    else if (_expecting_colon)
                    {
                        show_error("Found {, was expecting colon\n ", true);
                    }
                    else if (_in_struct_key)
                    {
                        show_error("Cannot use a struct as a struct key\n ", true);
                    }
                    else
                    {
                        var _new_stack_top = {};
                        
                        if (_in_struct_value)
                        {
                            _expecting_comma = true;
                            _stack_top[$ _struct_key] = _new_stack_top;
                        }
                        else if (_in_array)
                        {
                            array_push(_stack_top, _new_stack_top);
                        }
                        
                        if (_root == undefined) _root = _new_stack_top;
                        array_push(_stack, _new_stack_top);
                        _stack_top = _new_stack_top;
                        
                        _expecting_comma = false;
                        _in_struct_key   = true;
                        _in_struct_value = false;
                        _in_array        = false;
                    }
                break;
                
                case ord("}"):
                    if (_expecting_colon)
                    {
                        show_error("Found }, was expecting colon\n ", true);
                    }
                    else if (_in_struct_key || _in_struct_value)
                    {
                        _expecting_comma = true;
                        
                        array_pop(_stack);
                        _stack_top = (array_length(_stack) <= 0)? undefined : _stack[array_length(_stack)-1];
                        
                        if (is_struct(_stack_top))
                        {
                            _in_struct_key   = true;
                            _in_struct_value = false;
                            _in_array        = false;
                        }
                        else if (is_array(_stack_top))
                        {
                            _in_struct_key   = false;
                            _in_struct_value = false;
                            _in_array        = true;
                        }
                    }
                    else
                    {
                        show_error("Found unexpected }\n ", true);
                    }
                break;
                
                default:
                    if (_byte == ord("/"))
                    {
                        var _next_byte = buffer_peek(_buffer, buffer_tell(_buffer), buffer_u8);
                        if (_next_byte == ord("/"))
                        {
                            _in_comment = true;
                            buffer_seek(_buffer, buffer_seek_relative, 1);
                        }
                        else if (_next_byte == ord("*"))
                        {
                            _in_multiline_comment = true;
                            buffer_seek(_buffer, buffer_seek_relative, 1);
                        }
                    }
                    else if (_byte > 0x20)
                    {
                        if (_expecting_comma)
                        {
                            show_error("Was expecting comma\n ", true);
                        }
                        else if (_expecting_colon)
                        {
                            show_error("Wwas expecting colon\n ", true);
                        }
                        else if (_in_struct_key)
                        {
                            show_error("Struct keys must be strings\n ", true);
                        }
                        
                        _read_start = buffer_tell(_buffer)-1;
                        _in_value = true;
                    }
                break;
            }
        }
    }
    
    buffer_delete(_buffer);
    buffer_delete(_cache_buffer);
    
    if (array_length(_stack) > 0) show_error("One or more JSON objects/arrays not terminataed\n ", true);
    
    return _root;
}