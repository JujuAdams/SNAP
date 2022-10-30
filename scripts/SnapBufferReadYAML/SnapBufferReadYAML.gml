/// @return Nested struct/array data that represents the contents of the YAML string
/// 
/// N.B. This is not a full implementation of the YAML spec and doesn't try to be. This YAML parser doesn't support:
///      1. Single quote delimited strings (you must use double quotes)
///      2. Block scalars using | and > prefixes
///      3. Anchors, documents, directives, nodes... all the weird extra stuff
/// 
/// @param buffer              Buffer to read data from
/// @param offset              Offset in the buffer to read data from
/// @param [replaceKeywords]   Whether to replace keywords (true, false, null) with boolean/undefined equivalents. Defaults to <true>
/// @param [trackFieldOrder]   Whether to track the order of struct fields as they appear in the YAML string (stored in __snapFieldOrder field on each GML struct). Default to <false>
/// 
/// @jujuadams 2022-10-30

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

function SnapBufferReadYAML(_buffer, _offset, _replaceKeywords = true, _tracekFieldOrder = false)
{
    if (_offset != undefined)
    {
        var _oldOffset = buffer_tell(_buffer);
        buffer_seek(_buffer, buffer_seek_start, _offset);
    }
    
    var _tokensArray = (new __SnapFromYAMLBufferTokenizer(_buffer)).result;
    
    if (_offset != undefined)
    {
        buffer_seek(_buffer, buffer_seek_start, _oldOffset);
    }
    
    return (new __SnapFromYAMLBufferBuilder(_tokensArray, _replaceKeywords, _tracekFieldOrder)).result;
}

function __SnapFromYAMLBufferTokenizer(_buffer) constructor
{
    buffer = _buffer;
    var _buffer_size = buffer_get_size(_buffer);
    
    var _tokens_array = [];
    result = _tokens_array;
    
    var _chunk_start   = 0;
    var _chunk_end     = 0;
    var _indent_search = true;
    var _json_depth    = 0;
    
    var _scalar_first_character = false;
    var _scalar_has_content     = false;
    var _in_string              = false;
    var _string_start           = undefined;
    var _in_comment             = false;
    
    static read_chunk = function(_start, _end, _tell)
    {
        if (_end <= _start) return undefined;
        
        var _value = buffer_peek(buffer, _end, buffer_u8);
        buffer_poke(buffer, _end, buffer_u8, 0);
        
        buffer_seek(buffer, buffer_seek_start, _start);
        var _string = buffer_read(buffer, buffer_string);
        
        buffer_poke(buffer, _end, buffer_u8, _value);
        buffer_seek(buffer, buffer_seek_start, _tell);
        
        return _string;
    }
    
    static read_chunk_and_add = function(_start, _end, _tell, _type)
    {
        var _chunk = read_chunk(_start, _end, _tell);
        if (_chunk != undefined) result[@ array_length(result)] = [_type, _chunk];
    }
    
    while(buffer_tell(_buffer) < _buffer_size)
    {
        var _value = buffer_read(_buffer, buffer_u8);
        
        if (_in_comment)
        {
            if ((_value == 0) || (_value == 10) || (_value == 13))
            {
                _tokens_array[@ array_length(_tokens_array)] = [__SNAP_YAML.NEWLINE];
                _chunk_start = buffer_tell(_buffer);
                _chunk_end   = buffer_tell(_buffer);
                
                _in_comment = false;
                _indent_search = true;
            }
        }
        else if (_indent_search)
        {
            if (_value == 0)
            {
                break;
            }
            else if ((_value == 10) || (_value == 13))
            {
                _tokens_array[@ array_length(_tokens_array)] = [__SNAP_YAML.NEWLINE];
                _chunk_start = buffer_tell(_buffer);
                _chunk_end   = buffer_tell(_buffer);
            }
            else if (_value > 32)
            {
                read_chunk_and_add(_chunk_start, buffer_tell(_buffer)-1, buffer_tell(_buffer), __SNAP_YAML.INDENT);
                
                buffer_seek(_buffer, buffer_seek_relative, -1);
                _chunk_start            = buffer_tell(_buffer);
                _chunk_end              = buffer_tell(_buffer);
                _indent_search          = false;
                _scalar_first_character = true;
                _scalar_has_content     = false;
            }
        }
        else
        {
            if (_scalar_first_character && (_value == 45)) //First character on the line is a hyphen
            {
                var _next_value = buffer_peek(_buffer, buffer_tell(_buffer), buffer_u8);
                if ((_next_value == 10) || (_next_value == 13))
                {
                    _tokens_array[@ array_length(_tokens_array)] = [__SNAP_YAML.ARRAY];
                    
                    _chunk_start   = buffer_tell(_buffer);
                    _chunk_end     = buffer_tell(_buffer);
                    _indent_search = false;
                }
                else if (_next_value == 32)
                {
                    _tokens_array[@ array_length(_tokens_array)] = [__SNAP_YAML.ARRAY];
                    
                    buffer_seek(_buffer, buffer_seek_relative, 1);
                    _chunk_start = buffer_tell(_buffer);
                    _chunk_end   = buffer_tell(_buffer);
                }
                else if (_next_value == 45) //Two hyphens in a row
                {
                    if ((buffer_tell(_buffer) <= _buffer_size - 4) && (buffer_peek(_buffer, buffer_tell(_buffer), buffer_u32) == ((35 << 24) | (32 << 16) | (45 << 8) | 45))) //Detect "--- # comment"
                    {
                        _in_comment = true;
                    }
                }
            }
            else if (_scalar_first_character && (_value == 35)) //First character on the line is a hash
            {
                var _next_value = buffer_peek(_buffer, buffer_tell(_buffer), buffer_u8);
                if (_next_value == 32) _in_comment = true; //Detect "# comment" which is different to "--- # comment" because the YAML spec is shit
            }
            else
            {
                _scalar_first_character = false;
                
                if (_in_string)
                {
                    if ((_value == 34) && (buffer_peek(_buffer, buffer_tell(_buffer)-2, buffer_u8) != 92)) //Quote "  and  backslash \
                    {
                        read_chunk_and_add(_chunk_start+1, buffer_tell(_buffer)-1, buffer_tell(_buffer), __SNAP_YAML.STRING);
                        
                        _chunk_start        = buffer_tell(_buffer);
                        _chunk_end          = buffer_tell(_buffer);
                        _in_string          = false;
                        _scalar_has_content = false;
                    }
                }
                else
                {
                    if (_value <= 32) //Whitespace
                    {
                        if (!_scalar_has_content) _chunk_start = buffer_tell(_buffer);
                    }
                    else //Not whitespace
                    {
                        _scalar_has_content = true;
                    }
                    
                    if (_value == 34) //Quote "
                    {
                        _in_string = true;
                        _string_start = buffer_tell(_buffer);
                    }
                    else if ((_value == 35) && (buffer_tell(_buffer) >= 1) && (buffer_peek(_buffer, buffer_tell(_buffer)-2, buffer_u8) <= 32))
                    {
                        read_chunk_and_add(_chunk_start, _chunk_end, buffer_tell(_buffer), __SNAP_YAML.SCALAR);
                        
                        _chunk_start = buffer_tell(_buffer);
                        _chunk_end   = buffer_tell(_buffer);
                        _in_comment  = true;
                    }
                    else if ((_value == 91) || (_value == 93) || (_value == 123) || (_value == 125)) // [ ] { }
                    {
                        read_chunk_and_add(_chunk_start, _chunk_end, buffer_tell(_buffer), __SNAP_YAML.SCALAR);
                        
                        if ((_value == 91) || (_value == 123)) // [ {
                        {
                            ++_json_depth;
                            _tokens_array[@ array_length(_tokens_array)] = [(_value == 91)? __SNAP_YAML.JSON_ARRAY_START : __SNAP_YAML.JSON_STRUCT_START];
                        }
                        else if ((_value == 93) || (_value == 125)) // ] }
                        {
                            --_json_depth;
                            _tokens_array[@ array_length(_tokens_array)] = [(_value == 93)? __SNAP_YAML.JSON_ARRAY_END : __SNAP_YAML.JSON_STRUCT_END];
                        }
                        
                        _chunk_start        = buffer_tell(_buffer);
                        _chunk_end          = buffer_tell(_buffer);
                        _scalar_has_content = false;
                    }
                    else if ((_json_depth > 0) && (_value == 44)) //Comma ,
                    {
                        read_chunk_and_add(_chunk_start, _chunk_end, buffer_tell(_buffer), __SNAP_YAML.SCALAR);
                        _tokens_array[@ array_length(_tokens_array)] = [__SNAP_YAML.JSON_COMMA];
                        
                        _chunk_start        = buffer_tell(_buffer);
                        _chunk_end          = buffer_tell(_buffer);
                        _scalar_has_content = false;
                    }
                    else if (_value == 58) //Colon :
                    {
                        if (_json_depth > 0)
                        {
                            read_chunk_and_add(_chunk_start, _chunk_end, buffer_tell(_buffer), __SNAP_YAML.SCALAR);
                            _tokens_array[@ array_length(_tokens_array)] = [__SNAP_YAML.JSON_COLON];
                            
                            _chunk_start        = buffer_tell(_buffer);
                            _chunk_end          = buffer_tell(_buffer);
                            _scalar_has_content = false;
                        }
                        else
                        {
                            read_chunk_and_add(_chunk_start, _chunk_end, buffer_tell(_buffer), __SNAP_YAML.SCALAR);
                            _tokens_array[@ array_length(_tokens_array)] = [__SNAP_YAML.STRUCT];
                            
                            var _next_value = buffer_peek(_buffer, buffer_tell(_buffer), buffer_u8);
                            if ((_next_value == 10) || (_next_value == 13)) //Next value is a newline
                            {
                                _chunk_start   = buffer_tell(_buffer);
                                _chunk_end     = buffer_tell(_buffer);
                                _indent_search = false;
                            }
                            else if (_next_value == 32) //Next value is a space
                            {
                                buffer_seek(_buffer, buffer_seek_relative, 1);
                                _chunk_start            = buffer_tell(_buffer);
                                _chunk_end              = buffer_tell(_buffer);
                                _scalar_first_character = true;
                            }
                        }
                    }
                    else if ((_value == 0) || (_value == 10) || (_value == 13)) //Null or newline
                    {
                        read_chunk_and_add(_chunk_start, _chunk_end, buffer_tell(_buffer), __SNAP_YAML.SCALAR);
                        _tokens_array[@ array_length(_tokens_array)] = [__SNAP_YAML.NEWLINE];
                        
                        _chunk_start   = buffer_tell(_buffer);
                        _chunk_end     = buffer_tell(_buffer);
                        _indent_search = true;
                    }
                    
                    if (_value > 32) _chunk_end = buffer_tell(_buffer);
                }
            }
        }
    }
}

function __SnapFromYAMLBufferBuilder(_tokens_array, _replace_keywords, _track_field_order) constructor
{
    tokens_array = _tokens_array;
    replace_keywords = _replace_keywords;
    track_field_order = _track_field_order;
    
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
                if (track_field_order)
                {
                    var _field_index = 0;
                    var _field_order_array = [];
                    _struct.__snapFieldOrder = _field_order_array;
                }
                
                --token_index;
                while(token_index < token_count)
                {
                    var _key = tokens_array[token_index][1];
                          
                    //Add the key to the __snapFieldOrder array              
                    if (track_field_order) _field_order_array[@ _field_index++] = _key;
                    
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
            if (track_field_order)
            {
                var _field_index = 0;
                var _field_order_array = [];
                _struct.__snapFieldOrder = _field_order_array;
            }
            
            read_to_next();
            while((token_index < token_count) && (tokens_array[token_index][0] != __SNAP_YAML.JSON_STRUCT_END))
            {
                var _key = read();
                
                //Add the key to the __snapFieldOrder array
                if (track_field_order) _field_order_array[@ _field_index++] = _key;
                
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