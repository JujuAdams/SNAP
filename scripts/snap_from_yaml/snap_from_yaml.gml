/// @return Nested struct/array data that represents the contents of the YAML string
/// 
/// N.B. This is not a full implementation of the YAML and doesn't try to be
///      Apart from the advanced features (anchors, documents, directives and so on), this YAML parser doesn't support:
///      1. Comments using "--- #" or just " #"
///      2. In-line JSON syntax e.g. [1, 2, 3] or {"a" : "b", "c" : "d"}
///      3. Single quote delimited strings (you must use double quotes)
///      4. Block scalars using | and > prefixes
/// 
/// @param string              The YAML string to be decoded
/// @param [replaceKeywords]   Whether to replace keywords (true, false, null) with boolean/undefined equivalents
/// 
/// @jujuadams 2020-09-20

enum __SNAP_YAML
{
    INDENT,
    NEWLINE,
    ARRAY,
    STRUCT,
    SCALAR,
    STRING,
    JSON_ARRAY_START,
    JSON_ARRAY_END,
    JSON_STRUCT_START,
    JSON_STRUCT_END,
    JSON_COMMA,
    JSON_COLON,
}

function snap_from_yaml()
{
    var _string = argument[0];
    var _replace_keywords = ((argument_count > 1) && (argument[1] != undefined))? argument[1] : false;
    
    var _buffer_size = string_byte_length(_string)+1;
    var _buffer = buffer_create(_buffer_size, buffer_fixed, 1);
    buffer_write(_buffer, buffer_text, _string);
    buffer_seek(_buffer, buffer_seek_start, 0);
    
    var _tokens_array = [];
    
    #region Break the string down into tokens
    
    var _chunk_start            = 0;
    var _indent_search          = true;
    
    var _scalar_first_character = false;
    var _scalar_has_content     = false;
    var _in_string              = false;
    var _string_start           = undefined;
    
    var _json_depth = 0;
    
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
                _scalar_has_content = false;
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
                
                if (_in_string)
                {
                    if ((_value == 34) && (buffer_peek(_buffer, buffer_tell(_buffer)-2, buffer_u8) != 92)) //Quote "  and  backslash \
                    {
                        buffer_poke(_buffer, buffer_tell(_buffer)-1, buffer_u8, 0);
                        buffer_seek(_buffer, buffer_seek_start, _string_start);
                        var _chunk = buffer_read(_buffer, buffer_string);
                        buffer_poke(_buffer, buffer_tell(_buffer)-1, buffer_u8, _value);
                            
                        _tokens_array[@ array_length(_tokens_array)] = [__SNAP_YAML.STRING, _chunk];
                        
                        _chunk_start = buffer_tell(_buffer);
                        _in_string = false;
                        _scalar_has_content = false;
                    }
                }
                else
                {
                    if (_value <= 32)
                    {
                        if (!_scalar_has_content) _chunk_start = buffer_tell(_buffer);
                    }
                    else
                    {
                        _scalar_has_content = true;
                    }
                    
                    if (_value == 34) //Quote "
                    {
                        _in_string = true;
                        _string_start = buffer_tell(_buffer);
                    }
                    else if ((_value == 91) || (_value == 93) || (_value == 123) || (_value == 125)) //[]{}
                    {
                        if (buffer_tell(_buffer) - 1 > _chunk_start)
                        {
                            buffer_poke(_buffer, buffer_tell(_buffer)-1, buffer_u8, 0);
                            buffer_seek(_buffer, buffer_seek_start, _chunk_start);
                            var _chunk = buffer_read(_buffer, buffer_string);
                            buffer_poke(_buffer, buffer_tell(_buffer)-1, buffer_u8, _value);
                            
                            _tokens_array[@ array_length(_tokens_array)] = [__SNAP_YAML.SCALAR, _chunk];
                        }
                        
                        if ((_value == 91) || (_value == 123))
                        {
                            ++_json_depth;
                            _tokens_array[@ array_length(_tokens_array)] = [(_value == 91)? __SNAP_YAML.JSON_ARRAY_START : __SNAP_YAML.JSON_STRUCT_START];
                        }
                        else if ((_value == 93) || (_value == 125))
                        {
                            --_json_depth;
                            _tokens_array[@ array_length(_tokens_array)] = [(_value == 93)? __SNAP_YAML.JSON_ARRAY_END : __SNAP_YAML.JSON_STRUCT_END];
                        }
                        
                        _chunk_start = buffer_tell(_buffer);
                        _scalar_has_content = false;
                    }
                    else if ((_json_depth > 0) && (_value == 44)) //Comma ,
                    {
                        if (buffer_tell(_buffer) - 1 > _chunk_start)
                        {
                            buffer_poke(_buffer, buffer_tell(_buffer)-1, buffer_u8, 0);
                            buffer_seek(_buffer, buffer_seek_start, _chunk_start);
                            var _chunk = buffer_read(_buffer, buffer_string);
                            buffer_poke(_buffer, buffer_tell(_buffer)-1, buffer_u8, _value);
                            
                            _tokens_array[@ array_length(_tokens_array)] = [__SNAP_YAML.SCALAR, _chunk];
                        }
                        
                        _tokens_array[@ array_length(_tokens_array)] = [__SNAP_YAML.JSON_COMMA];
                        
                        _chunk_start = buffer_tell(_buffer);
                        _scalar_has_content = false;
                    }
                    else if (_value == 58) //Colon :
                    {
                        if (_json_depth > 0)
                        {
                            if (buffer_tell(_buffer) - 1 > _chunk_start)
                            {
                                buffer_poke(_buffer, buffer_tell(_buffer)-1, buffer_u8, 0);
                                buffer_seek(_buffer, buffer_seek_start, _chunk_start);
                                var _chunk = buffer_read(_buffer, buffer_string);
                                buffer_poke(_buffer, buffer_tell(_buffer)-1, buffer_u8, _value);
                            
                                _tokens_array[@ array_length(_tokens_array)] = [__SNAP_YAML.SCALAR, _chunk];
                            }
                            
                            _tokens_array[@ array_length(_tokens_array)] = [__SNAP_YAML.JSON_COLON];
                            
                            _chunk_start = buffer_tell(_buffer);
                            _scalar_has_content = false;
                        }
                        else
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
                    }
                    else if ((_value == 0) || (_value == 10) || (_value == 13))
                    {
                        if (_scalar_has_content && (buffer_tell(_buffer) - 1 > _chunk_start))
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
    }
    
    #endregion
    
    show_debug_message(_tokens_array);
    
    buffer_delete(_buffer);
    
    return (new __snap_from_yaml_builder(_tokens_array, _replace_keywords)).result;
}

function __snap_from_yaml_builder(_tokens_array, _replace_keywords) constructor
{
    tokens_array = _tokens_array;
    replace_keywords = _replace_keywords;
    
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
        if ((_type == __SNAP_YAML.SCALAR) || (_type == __SNAP_YAML.STRING))
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
                var _result = _token[1];
                if (_type == __SNAP_YAML.STRING)
                {
                    //Unescape characters
                    //TODO - Do this when building tokens
                    _result = string_replace_all(_result, "\\\"", "\"");
                    _result = string_replace_all(_result, "\\\t", "\t");
                    _result = string_replace_all(_result, "\\\r", "\r");
                    _result = string_replace_all(_result, "\\\n", "\n");
                    _result = string_replace_all(_result, "\\\\", "\\");
                }
                else
                {
                    try
                    {
                        _result = real(_result);
                        //It's a number
                    }
                    catch(_error)
                    {
                        //It's a string
                        if (replace_keywords)
                        {
                            switch(string_lower(_result))
                            {
                                case "true":  _result = true;      break;
                                case "false": _result = false;     break;
                                case "null":  _result = undefined; break;
                            }
                        }
                    }
                }
                
                return _result;
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
        else if (_type == __SNAP_YAML.JSON_ARRAY_START)
        {
            var _array = [];
            
            read_to_next();
            while((token_index < token_count) && (tokens_array[token_index][0] != __SNAP_YAML.JSON_ARRAY_END))
            {
                _array[@ array_length(_array)] = read();
                
                read_to_next();
                if (tokens_array[token_index][0] == __SNAP_YAML.JSON_COMMA)
                {
                    token_index++;
                    read_to_next();
                }
            }
            
            token_index++;
            
            return _array;
        }
        else if (_type == __SNAP_YAML.JSON_STRUCT_START)
        {
            var _struct = {};
            
            read_to_next();
            while((token_index < token_count) && (tokens_array[token_index][0] != __SNAP_YAML.JSON_STRUCT_END))
            {
                var _key = read();
                
                read_to_next();
                if (tokens_array[token_index][0] == __SNAP_YAML.JSON_COLON)
                {
                    token_index++;
                    read_to_next();
                }
                
                variable_struct_set(_struct, _key, read());
                
                read_to_next();
                if (tokens_array[token_index][0] == __SNAP_YAML.JSON_COMMA)
                {
                    token_index++;
                    read_to_next();
                }
            }
            
            token_index++;
            
            return _struct;
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