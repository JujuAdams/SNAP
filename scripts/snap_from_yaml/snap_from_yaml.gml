/// @return Nested struct/array data that represents the contents of the YAML string
/// 
/// @param string  The YAML string to be decoded
/// 
/// @jujuadams 2020-09-16

enum __SNAP_YAML
{
    INDENT,
    NEWLINE,
    ARRAY,
    STRUCT,
    SCALAR,
}

function snap_from_yaml(_string)
{
    var _buffer_size = string_byte_length(_string)+1;
    var _buffer = buffer_create(_buffer_size, buffer_fixed, 1);
    buffer_write(_buffer, buffer_text, _string);
    buffer_seek(_buffer, buffer_seek_start, 0);
    
    var _tokens_array = [];
    
    #region Break the string down into tokens
    
    var _chunk_start = 0;
    var _indent_search = true;
    var _scalar_first_character = false;
    
    while(buffer_tell(_buffer) < _buffer_size)
    {
        var _value = buffer_read(_buffer, buffer_u8);
        
        if (_indent_search)
        {
            if (_value == 0)
            {
                break;
            }
            else if ((_value == 10) || (_value == 13))
            {
                _tokens_array[@ array_length(_tokens_array)] = [__SNAP_YAML.NEWLINE];
                _chunk_start = buffer_tell(_buffer);
            }
            else if (_value > 32)
            {
                if (buffer_tell(_buffer) - 1 > _chunk_start)
                {
                    buffer_poke(_buffer, buffer_tell(_buffer)-1, buffer_u8, 0);
                    buffer_seek(_buffer, buffer_seek_start, _chunk_start);
                    var _chunk = buffer_read(_buffer, buffer_string);
                    buffer_poke(_buffer, buffer_tell(_buffer)-1, buffer_u8, _value);
                    
                    _tokens_array[@ array_length(_tokens_array)] = [__SNAP_YAML.INDENT, _chunk];
                }
                
                buffer_seek(_buffer, buffer_seek_relative, -1);
                _chunk_start = buffer_tell(_buffer);
                _indent_search = false;
                _scalar_first_character = true;
            }
        }
        else
        {
            if (_scalar_first_character && (_value == 45))
            {
                _tokens_array[@ array_length(_tokens_array)] = [__SNAP_YAML.ARRAY];
                
                var _next_value = buffer_peek(_buffer, buffer_tell(_buffer), buffer_u8);
                if ((_next_value == 10) || (_next_value == 13))
                {
                    _chunk_start = buffer_tell(_buffer);
                    _indent_search = false;
                }
                else if (_next_value == 32)
                {
                    buffer_seek(_buffer, buffer_seek_relative, 1);
                    _chunk_start = buffer_tell(_buffer);
                }
            }
            else
            {
                _scalar_first_character = false;
                
                if (_value == 58)
                {
                    if (buffer_tell(_buffer) - 1 > _chunk_start)
                    {
                        buffer_poke(_buffer, buffer_tell(_buffer)-1, buffer_u8, 0);
                        buffer_seek(_buffer, buffer_seek_start, _chunk_start);
                        var _chunk = buffer_read(_buffer, buffer_string);
                        buffer_poke(_buffer, buffer_tell(_buffer)-1, buffer_u8, _value);
                    
                        _tokens_array[@ array_length(_tokens_array)] = [__SNAP_YAML.SCALAR, _chunk];
                    }
                    
                    _tokens_array[@ array_length(_tokens_array)] = [__SNAP_YAML.STRUCT];
                    
                    var _next_value = buffer_peek(_buffer, buffer_tell(_buffer), buffer_u8);
                    if ((_next_value == 10) || (_next_value == 13))
                    {
                        _chunk_start = buffer_tell(_buffer);
                        _indent_search = false;
                    }
                    else if (_next_value == 32)
                    {
                        buffer_seek(_buffer, buffer_seek_relative, 1);
                        _chunk_start = buffer_tell(_buffer);
                        _scalar_first_character = true;
                    }
                }
                else if ((_value == 0) || (_value == 10) || (_value == 13))
                {
                    if (buffer_tell(_buffer) - 1 > _chunk_start)
                    {
                        buffer_poke(_buffer, buffer_tell(_buffer)-1, buffer_u8, 0);
                        buffer_seek(_buffer, buffer_seek_start, _chunk_start);
                        var _chunk = buffer_read(_buffer, buffer_string);
                        buffer_poke(_buffer, buffer_tell(_buffer)-1, buffer_u8, _value);
                    
                        _tokens_array[@ array_length(_tokens_array)] = [__SNAP_YAML.SCALAR, _chunk];
                    }
                    
                    _tokens_array[@ array_length(_tokens_array)] = [__SNAP_YAML.NEWLINE];
                    
                    _chunk_start = buffer_tell(_buffer);
                    _indent_search = true;
                }
            }
        }
    }
    
    #endregion
    
    buffer_delete(_buffer);
    
    return (new __snap_from_yaml_builder(_tokens_array)).result;
}

function __snap_from_yaml_builder(_tokens_array) constructor
{
    tokens_array = _tokens_array;
    token_count  = array_length(tokens_array);
    token_index  = 0;
    
    indent = 0;
    line = 0;
    
    static read_to_next = function()
    {
        while(token_index < token_count)
        {
            var _type = tokens_array[token_index][0];
            if (_type == __SNAP_YAML.NEWLINE)
            {
                ++line;
                indent = 0;
            }
            else if (_type == __SNAP_YAML.INDENT)
            {
                var _indent_string = tokens_array[token_index][1];
                indent = string_count(" ", _indent_string); //TODO - Cache this value earlier during parsing
            }
            else
            {
                break;
            }
            
            ++token_index;
        }
    }
    
    static read = function()
    {
        var _token = tokens_array[token_index];
        token_index++;
        
        var _type = _token[0];
        if (_type == __SNAP_YAML.SCALAR)
        {
            if (tokens_array[token_index][0] == __SNAP_YAML.STRUCT)
            {
                var _indent_limit = indent;
                var _struct = {};
                
                --token_index;
                while(token_index < token_count)
                {
                    var _key = tokens_array[token_index][1];
                    token_index += 2; //Skip over the struct symbol
                    
                    var _last_line = line;
                    read_to_next();
                    if ((indent <= _indent_limit) && (line != _last_line))
                    {
                        variable_struct_set(_struct, _key, undefined);
                    }
                    else
                    {
                        variable_struct_set(_struct, _key, read());
                    }
                    
                    read_to_next();
                    if (indent < _indent_limit) break;
                }
                
                return _struct;
            }
            else
            {
                return _token[1];
            }
        }
        else if (_type == __SNAP_YAML.ARRAY)
        {
            var _indent_limit = indent;
            var _array = [];
            
            --token_index;
            while(token_index < token_count)
            {
                if (tokens_array[token_index][0] != __SNAP_YAML.ARRAY) break;
                ++token_index; //Skip over the array symbol
                
                var _last_line = line;
                read_to_next();
                if ((indent <= _indent_limit) && (line != _last_line))
                {
                    _array[@ array_length(_array)] = undefined;
                }
                else
                {
                    indent += 2;
                    _array[@ array_length(_array)] = read();
                }
                
                read_to_next();
                if (indent < _indent_limit) break;
            }
            
            return _array;
        }
        else
        {
            throw "Unexpected error";
        }
        
        return undefined;
    }
    
    read_to_next();
    result = read();
}