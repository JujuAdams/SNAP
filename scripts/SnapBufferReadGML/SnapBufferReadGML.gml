/// @return Nested struct/array data that represents the contents of the JSON string. The root node will always be a struct
/// 
/// @param buffer  The GML string to be decoded
/// @param offset
/// @param size
/// 
/// @jujuadams 2022-10-30

function SnapBufferReadGML(_buffer, _offset, _size)
{
    var _oldOffset = buffer_tell(_buffer);
    buffer_seek(_buffer, buffer_seek_start, _offset);
    var _parser = new __SnapBufferReadGMLParser(_buffer, _size);
    buffer_seek(_buffer, buffer_seek_start, _oldOffset);
    return _parser.root;
}

function __SnapBufferReadGMLParser(_buffer, _buffer_size) constructor
{
    root = {};
    
    buffer = _buffer;
    buffer_size = _buffer_size;
    depth = 0;
    line = 1;
    
    static read_root = function()
    {
        var _state = 0;
        var _key   = undefined;
        
        while(buffer_tell(buffer) < buffer_size)
        {
            token = undefined;
            token_is_real   = false;
            token_is_string = false;
            token_is_symbol = false;
            
            read_token();
            
            if (is_string(token))
            {
                if (!token_is_string && !token_is_symbol)
                {
                    try
                    {
                        token = real(token);
                        token_is_real = true;
                    }
                    catch(_)
                    {
                        token_is_real = false;
                    }
                }
                
                if (_state == 0)
                {
                    if (!token_is_real && !token_is_string && !token_is_symbol)
                    {
                        _key = token;
                        _state = 1;
                    }
                    else if (token_is_symbol && (token == ";"))
                    {
                        //Expected ; terminator
                    }
                    else
                    {
                        show_error("SNAP:\n\nLine " + string(line) + ", unexpected token " + string(token) + "\nis_string = " + string(token_is_string) + "\nis_real = " + string(token_is_real) + "\nis_symbol = " + string(token_is_symbol) + "\n ", true);
                        
                    }
                }
                else if (_state == 1)
                {
                    if (token_is_symbol && (token == "="))
                    {
                        _state = 2;
                    }
                    else
                    {
                        show_error("SNAP:\n\nLine " + string(line) + ", unexpected token " + string(token) + "\nis_string = " + string(token_is_string) + "\nis_real = " + string(token_is_real) + "\nis_symbol = " + string(token_is_symbol) + "\n ", true);
                    }
                }
                else if (_state == 2)
                {
                    if (token_is_symbol)
                    {
                        if (token == "{")
                        {
                            root[$ _key] = read_struct();
                            _state = 0;
                        }
                        else if (token == "[")
                        {
                            root[$ _key] = read_array();
                            _state = 0;
                        }
                        else
                        {
                            show_error("SNAP:\n\nLine " + string(line) + ", unexpected token " + string(token) + "\nis_string = " + string(token_is_string) + "\nis_real = " + string(token_is_real) + "\nis_symbol = " + string(token_is_symbol) + "\n ", true);
                        }
                    }
                    else
                    {
                        if (token_is_string)
                        {
                            token = string_replace_all(token, "\\\"", "\"");
                            token = string_replace_all(token, "\\\r", "\r");
                            token = string_replace_all(token, "\\\n", "\n");
                            token = string_replace_all(token, "\\\t", "\t");
                            token = string_replace_all(token, "\\\\", "\\");
                        }
                        else if (!token_is_real)
                        {
                            if (token == "false")
                            {
                                token = false;
                            }
                            else if (token == "true")
                            {
                                token = true;
                            }
                            else if (token == "undefined")
                            {
                                token = undefined;
                            }
                            else
                            {
                                show_error("SNAP:\n\nLine " + string(line) + ", unexpected token " + string(token) + "\nis_string = " + string(token_is_string) + "\nis_real = " + string(token_is_real) + "\nis_symbol = " + string(token_is_symbol) + "\n ", true);
                            }
                        }
                        
                        root[$ _key] = token;
                        _state = 0;
                    }
                }
            }
        }
    }
    
    static read_array = function()
    {
        var _array = [];
        var _state = 0;
        
        while(buffer_tell(buffer) < buffer_size)
        {
            token = undefined;
            token_is_real   = false;
            token_is_string = false;
            token_is_symbol = false;
            
            read_token();
            
            if (is_string(token))
            {
                if (!token_is_string && !token_is_symbol)
                {
                    try
                    {
                        token = real(token);
                        token_is_real = true;
                    }
                    catch(_)
                    {
                        token_is_real = false;
                    }
                }
                
                if (_state == 0)
                {
                    if (token_is_symbol)
                    {
                        if (token == "{")
                        {
                            array_push(_array, read_struct());
                            _state = 1;
                        }
                        else if (token == "[")
                        {
                            array_push(_array, read_array());
                            _state = 1;
                        }
                        else if (token == "]")
                        {
                            break;
                        }
                        else
                        {
                            show_error("SNAP:\n\nLine " + string(line) + ", unexpected token " + string(token) + "\nis_string = " + string(token_is_string) + "\nis_real = " + string(token_is_real) + "\nis_symbol = " + string(token_is_symbol) + "\n ", true);
                        }
                    }
                    else
                    {
                        if (token_is_string)
                        {
                            token = string_replace_all(token, "\\\"", "\"");
                            token = string_replace_all(token, "\\\r", "\r");
                            token = string_replace_all(token, "\\\n", "\n");
                            token = string_replace_all(token, "\\\t", "\t");
                            token = string_replace_all(token, "\\\\", "\\");
                        }
                        else if (!token_is_real)
                        {
                            if (token == "false")
                            {
                                token = false;
                            }
                            else if (token == "true")
                            {
                                token = true;
                            }
                            else if (token == "undefined")
                            {
                                token = undefined;
                            }
                            else
                            {
                                show_error("SNAP:\n\nLine " + string(line) + ", unexpected token " + string(token) + "\nis_string = " + string(token_is_string) + "\nis_real = " + string(token_is_real) + "\nis_symbol = " + string(token_is_symbol) + "\n ", true);
                            }
                        }
                        
                        array_push(_array, token);
                        _state = 1;
                    }
                }
                else if (_state == 1)
                {
                    if (token_is_symbol && (token == "]"))
                    {
                        break;
                    }
                    else if (token_is_symbol && (token == ","))
                    {
                        _state = 0;
                    }
                    else
                    {
                        show_error("SNAP:\n\nLine " + string(line) + ", unexpected token " + string(token) + "\nis_string = " + string(token_is_string) + "\nis_real = " + string(token_is_real) + "\nis_symbol = " + string(token_is_symbol) + "\n ", true);
                    }
                }
            }
        }
        
        return _array;
    }
    
    static read_struct = function()
    {
        var _struct = {};
        var _state  = 0;
        var _key    = undefined;
        
        while(buffer_tell(buffer) < buffer_size)
        {
            token = undefined;
            token_is_real   = false;
            token_is_string = false;
            token_is_symbol = false;
            
            read_token();
            
            if (is_string(token))
            {
                if (!token_is_string && !token_is_symbol)
                {
                    try
                    {
                        token = real(token);
                        token_is_real = true;
                    }
                    catch(_)
                    {
                        token_is_real = false;
                    }
                }
                
                if (_state == 0)
                {
                    if (!token_is_real && !token_is_string && !token_is_symbol)
                    {
                        _key = token;
                        _state = 1;
                    }
                    else if (token_is_symbol && (token == ","))
                    {
                        //Expected ; terminator
                    }
                    else if (token_is_symbol && (token == "}"))
                    {
                        break;
                    }
                    else
                    {
                        show_error("SNAP:\n\nLine " + string(line) + ", unexpected token " + string(token) + "\nis_string = " + string(token_is_string) + "\nis_real = " + string(token_is_real) + "\nis_symbol = " + string(token_is_symbol) + "\n ", true);
                    }
                }
                else if (_state == 1)
                {
                    if (token_is_symbol && (token == ":"))
                    {
                        _state = 2;
                    }
                    else
                    {
                        show_error("SNAP:\n\nLine " + string(line) + ", unexpected token " + string(token) + "\nis_string = " + string(token_is_string) + "\nis_real = " + string(token_is_real) + "\nis_symbol = " + string(token_is_symbol) + "\n ", true);
                    }
                }
                else if (_state == 2)
                {
                    if (token_is_symbol)
                    {
                        if (token == "{")
                        {
                            _struct[$ _key] = read_struct();
                            _state = 0;
                        }
                        else if (token == "[")
                        {
                            _struct[$ _key] = read_array();
                            _state = 0;
                        }
                        else if (token_is_symbol && (token == "}"))
                        {
                            break;
                        }
                        else
                        {
                            show_error("SNAP:\n\nLine " + string(line) + ", unexpected token " + string(token) + "\nis_string = " + string(token_is_string) + "\nis_real = " + string(token_is_real) + "\nis_symbol = " + string(token_is_symbol) + "\n ", true);
                        }
                    }
                    else
                    {
                        if (token_is_string)
                        {
                            token = string_replace_all(token, "\\\"", "\"");
                            token = string_replace_all(token, "\\\r", "\r");
                            token = string_replace_all(token, "\\\n", "\n");
                            token = string_replace_all(token, "\\\t", "\t");
                            token = string_replace_all(token, "\\\\", "\\");
                        }
                        else if (!token_is_real)
                        {
                            if (token == "false")
                            {
                                token = false;
                            }
                            else if (token == "true")
                            {
                                token = true;
                            }
                            else if (token == "undefined")
                            {
                                token = undefined;
                            }
                            else
                            {
                                show_error("SNAP:\n\nLine " + string(line) + ", unexpected token " + string(token) + "\nis_string = " + string(token_is_string) + "\nis_real = " + string(token_is_real) + "\nis_symbol = " + string(token_is_symbol) + "\n ", true);
                            }
                        }
                        
                        _struct[$ _key] = token;
                        _state = 0;
                    }
                }
            }
        }
        
        return _struct;
    }
    
    static read_token = function()
    {
        var _token_start      = undefined;
        var _in_string        = false;
        var _in_line_comment  = false;
        var _in_block_comment = false;
        
        while(buffer_tell(buffer) < buffer_size)
        {
            var _value = buffer_read(buffer, buffer_u8);
            
            if (_value == 10) line++;
            
            if (_in_string)
            {
                if ((_value == 34) && (buffer_peek(buffer, buffer_tell(buffer) - 2, buffer_u8) != 92))
                {
                    buffer_poke(buffer, buffer_tell(buffer) - 1, buffer_u8, 0x0);
                    buffer_seek(buffer, buffer_seek_start, _token_start + 1); //Skip the leading double quote
                    token = buffer_read(buffer, buffer_string);
                    buffer_poke(buffer, buffer_tell(buffer) - 1, buffer_u8, _value);
                    
                    token_is_string = true;
                    token_is_symbol = false;
                    break;
                }
            }
            else if (_in_line_comment)
            {
                if (_value == 10) _in_line_comment = false;
            }
            else if (_in_block_comment)
            {
                if ((_value == 47) && (buffer_peek(buffer, buffer_tell(buffer) - 2, buffer_u8) == 42))
                {
                    _in_block_comment = false;
                }
            }
            else
            {
                if (_token_start == undefined)
                {
                    if (_value > 32)
                    {
                        if ((_value == 47) && (buffer_peek(buffer, buffer_tell(buffer), buffer_u8) == 47))
                        {
                            //Line comment
                            _in_line_comment = true;
                        }
                        else if ((_value == 47) && (buffer_peek(buffer, buffer_tell(buffer), buffer_u8) == 42))
                        {
                            //Block comment
                            _in_block_comment = true;
                        }
                        else
                        {
                            _token_start = buffer_tell(buffer) - 1;
                            if (_value == 34) _in_string = true;
                            
                            if ((_value ==  44)  // ,
                            ||  (_value ==  58)  // :
                            ||  (_value ==  59)  // ;
                            ||  (_value ==  61)  // =
                            ||  (_value ==  91)  // [
                            ||  (_value ==  93)  // ]
                            ||  (_value == 123)  // {
                            ||  (_value == 125)) // }
                            {
                                token = chr(_value);
                                token_is_string = false;
                                token_is_symbol = true;
                                break;
                            }
                        }
                    }
                }
                else if ((_value <=  32)  // whitespace
                     ||  (_value ==  44)  // ,
                     ||  (_value ==  58)  // :
                     ||  (_value ==  59)  // ;
                     ||  (_value ==  61)  // =
                     ||  (_value ==  91)  // [
                     ||  (_value ==  93)  // ]
                     ||  (_value == 123)  // {
                     ||  (_value == 125)) // }
                {
                    buffer_poke(buffer, buffer_tell(buffer) - 1, buffer_u8, 0x0);
                    buffer_seek(buffer, buffer_seek_start, _token_start);
                    token = buffer_read(buffer, buffer_string);
                    buffer_seek(buffer, buffer_seek_relative, -1);
                    buffer_poke(buffer, buffer_tell(buffer), buffer_u8, _value);
                    
                    token_is_string = false;
                    token_is_symbol = false;
                    break;
                }
            }
        }
    }
    
    read_root();
}