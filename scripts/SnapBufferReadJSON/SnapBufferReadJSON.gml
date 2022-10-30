/// @return Nested struct/array data that represents the contents of the JSON string
/// 
/// @param buffer  Buffer to read data from
/// @param offset  Offset in the buffer to read data from
/// 
/// @jujuadams 2022-10-30

function SnapBufferReadJSON(_buffer, _inOffset = undefined)
{
    if (_inOffset != undefined)
    {
        var _oldOffset = buffer_tell(_buffer);
        buffer_seek(_buffer, buffer_seek_start, _inOffset);
    }
    
    var _cacheBuffer = undefined;
    
    var _readStart       = undefined;
    var _inString        = false;
    var _stringUsesCache = false;
    var _inValue         = false;
    var _expectingComma  = false;
    var _expectingColon  = false;
    
    var _inStructKey   = false;
    var _structKey     = undefined;
    var _inStructValue = false;
    var _inArray       = false;
    
    var _inComment           = false;
    var _inMultilineComment  = false;
    var _newComment          = false;
    var _newMultilineComment = false;
    
    var _stack    = [];
    var _root     = undefined;
    var _stackTop = undefined;
    
    var _bufferSize = buffer_get_size(_buffer);
    while(buffer_tell(_buffer) < _bufferSize)
    {
        var _byte = buffer_read(_buffer, buffer_u8);
        if (_byte == 0x00) break;
        
        if (_inComment)
        {
            if ((_byte == ord("\n")) || (_byte == ord("\r")))
            {
                _inComment = false;
            }
        }
        else if (_inMultilineComment)
        {
            if ((_byte == ord("*")) && (buffer_read(_buffer, buffer_u8) == ord("/")))
            {
                _inMultilineComment = false;
            }
        }
        else if (_inString)
        {
            if (_byte == ord("\""))
            {
                if (_stringUsesCache)
                {
                    _stringUsesCache = false;
                    
                    buffer_write(_cacheBuffer, buffer_u8, 0x00);
                    buffer_seek(_cacheBuffer, buffer_seek_start, 0);
                    var _value = buffer_read(_cacheBuffer, buffer_string);
                }
                else
                {
                    buffer_poke(_buffer, buffer_tell(_buffer)-1, buffer_u8, 0x00);
                    buffer_seek(_buffer, buffer_seek_start, _readStart);
                    var _value = buffer_read(_buffer, buffer_string);
                }
                    
                //Reset string handling values
                _inString         = false;
                _stringUsesCache = false;
                
                if (_inStructKey)
                {
                    _expectingColon = true;
                    _structKey      = _value;
                }
                else if (_inStructValue)
                {
                    _expectingComma = true;
                    _stackTop[$ _structKey] = _value;
                    _structKey = undefined;
                }
                else if (_inArray)
                {
                    _expectingComma = true;
                    array_push(_stackTop, _value);
                }
            }
            else if (_byte == ord("\\"))
            {
                if (!_stringUsesCache)
                {
                    _stringUsesCache = true;
                    if (_cacheBuffer == undefined)
                    {
                        _cacheBuffer = buffer_create(1024, buffer_grow, 1);
                    }
                    else
                    {
                        buffer_seek(_cacheBuffer, buffer_seek_start, 0);
                    }
                }
                
                var _size = buffer_tell(_buffer) - _readStart-1;
                buffer_copy(_buffer, _readStart, _size, _cacheBuffer, buffer_tell(_cacheBuffer));
                buffer_seek(_cacheBuffer, buffer_seek_relative, _size);
                
                var _next_byte = buffer_read(_buffer, buffer_u8);
                switch(_next_byte)
                {
                    case ord("n"): buffer_write(_cacheBuffer, buffer_u8, ord("\n")); break;
                    case ord("r"): buffer_write(_cacheBuffer, buffer_u8, ord("\r")); break;
                    case ord("t"): buffer_write(_cacheBuffer, buffer_u8, ord("\t")); break;
                    
                    case ord("u"):
                        var _old_value = buffer_peek(_buffer, buffer_tell(_buffer)+4, buffer_u8);
                        buffer_poke(_buffer, buffer_tell(_buffer)+4, buffer_u8, 0x00);
                        var _hex = buffer_read(_buffer, buffer_string);
                        buffer_seek(_buffer, buffer_seek_relative, -1);
                        buffer_poke(_buffer, buffer_tell(_buffer), buffer_u8, _old_value);
                        
                        var _value = int64(ptr(_hex));
                        if (_value <= 0x7F) //0xxxxxxx
                        {
                            buffer_write(_cacheBuffer, buffer_u8, _value);
                        }
                        else if (_value <= 0x07FF) //110xxxxx 10xxxxxx
                        {
                            buffer_write(_cacheBuffer, buffer_u8, 0xC0 | ((_value >> 6) & 0x1F));
                            buffer_write(_cacheBuffer, buffer_u8, 0x80 | ( _value       & 0x3F));
                        }
                        else if (_value <= 0xFFFF) //1110xxxx 10xxxxxx 10xxxxxx
                        {
                            buffer_write(_cacheBuffer, buffer_u8, 0xC0 | ( _value        & 0x0F));
                            buffer_write(_cacheBuffer, buffer_u8, 0x80 | ((_value >>  4) & 0x3F));
                            buffer_write(_cacheBuffer, buffer_u8, 0x80 | ((_value >> 10) & 0x3F));
                        }
                        else if (_value <= 0x10000) //11110xxx 10xxxxxx 10xxxxxx 10xxxxxx
                        {
                            buffer_write(_cacheBuffer, buffer_u8, 0xC0 | ( _value        & 0x07));
                            buffer_write(_cacheBuffer, buffer_u8, 0x80 | ((_value >>  3) & 0x3F));
                            buffer_write(_cacheBuffer, buffer_u8, 0x80 | ((_value >>  9) & 0x3F));
                            buffer_write(_cacheBuffer, buffer_u8, 0x80 | ((_value >> 15) & 0x3F));
                        }
                    break;
                    
                    default:
                        if ((_next_byte & $E0) == $C0) //110xxxxx 10xxxxxx
                        {
                            buffer_copy(_buffer, buffer_tell(_buffer)+1, 1, _cacheBuffer, buffer_tell(_cacheBuffer));
                            buffer_seek(_buffer, buffer_seek_relative, 1);
                            buffer_seek(_cacheBuffer, buffer_seek_relative, 1);
                        }
                        else if ((_next_byte & $F0) == $E0) //1110xxxx 10xxxxxx 10xxxxxx
                        {
                            buffer_copy(_buffer, buffer_tell(_buffer)+1, 2, _cacheBuffer, buffer_tell(_cacheBuffer));
                            buffer_seek(_buffer, buffer_seek_relative, 2);
                            buffer_seek(_cacheBuffer, buffer_seek_relative, 2);
                        }
                        else if ((_next_byte & $F8) == $F0) //11110xxx 10xxxxxx 10xxxxxx 10xxxxxx
                        {
                            buffer_copy(_buffer, buffer_tell(_buffer)+1, 3, _cacheBuffer, buffer_tell(_cacheBuffer));
                            buffer_seek(_buffer, buffer_seek_relative, 3);
                            buffer_seek(_cacheBuffer, buffer_seek_relative, 3);
                        }
                        else
                        {
                            buffer_write(_cacheBuffer, buffer_u8, _next_byte);
                        }
                    break;
                }
                
                _readStart = buffer_tell(_buffer);
            }
        }
        else if (_inValue)
        {
            if (_byte == ord("/"))
            {
                var _next_byte = buffer_peek(_buffer, buffer_tell(_buffer), buffer_u8);
                if (_next_byte == ord("/"))
                {
                    _newComment = true;
                }
                else if (_next_byte == ord("*"))
                {
                    _newMultilineComment = true;
                }
            }
            
            if ((_byte <= 0x20) || (_byte == ord(",")) || (_byte == ord("]")) || (_byte == ord("}")) || _newComment || _inMultilineComment)
            {
                var _old_value = buffer_peek(_buffer, buffer_tell(_buffer)-1, buffer_u8);
                buffer_poke(_buffer, buffer_tell(_buffer)-1, buffer_u8, 0x00);
                buffer_seek(_buffer, buffer_seek_start, _readStart);
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
                _inValue = false;
                
                if (_inStructValue)
                {
                    _stackTop[$ _structKey] = _value;
                    _structKey = undefined;
                }
                else if (_inArray)
                {
                    array_push(_stackTop, _value);
                }
                
                if (_newComment)
                {
                    _newComment = false;
                    _inComment  = true;
                    buffer_seek(_buffer, buffer_seek_relative, 1);
                }
                else if (_newMultilineComment)
                {
                    _newMultilineComment = false;
                    _inMultilineComment  = true;
                    buffer_seek(_buffer, buffer_seek_relative, 1);
                }
                else
                {
                    _expectingComma = true;
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
                    if (_expectingComma)
                    {
                        _expectingComma = false;
                        
                        if (_inStructValue)
                        {
                            _inStructKey   = true;
                            _inStructValue = false;
                        }
                    }
                    else
                    {
                        show_error("Found unexpected comma\n ", true);
                    }
                break;
                
                case ord(":"):
                    if (_expectingColon)
                    {
                        _expectingColon = false;
                        _inStructKey   = false;
                        _inStructValue = true;
                    }
                    else
                    {
                        show_error("Found unexpected colon\n ", true);
                    }
                break;
                
                case ord("\""):
                    if (_expectingComma)
                    {
                        show_error("Found \", was expecting comma\n ", true);
                    }
                    else if (_expectingColon)
                    {
                        show_error("Found \", was expecting colon\n ", true);
                    }
                    else
                    {
                        _readStart = buffer_tell(_buffer);
                        _inString = true;
                    }
                break;
                
                case ord("["):
                    if (_expectingComma)
                    {
                        show_error("Found [, was expecting comma\n ", true);
                    }
                    else if (_expectingColon)
                    {
                        show_error("Found [, was expecting colon\n ", true);
                    }
                    else
                    {
                        var _new_stack_top = [];
                        
                        if (_inStructKey)
                        {
                            show_error("Cannot use an array as a struct key\n ", true);
                        }
                        else if (_inStructValue)
                        {
                            _stackTop[$ _structKey] = _new_stack_top;
                        }
                        else if (_inArray)
                        {
                            array_push(_stackTop, _new_stack_top);
                        }
                        
                        if (_root == undefined) _root = _new_stack_top;
                        array_push(_stack, _new_stack_top);
                        _stackTop = _new_stack_top;
                        
                        _expectingComma = false;
                        _inStructKey   = false;
                        _inStructValue = false;
                        _inArray        = true;
                    }
                break;
                
                case ord("]"):
                    if (_inArray)
                    {
                        _expectingComma = true;
                        
                        array_pop(_stack);
                        _stackTop = (array_length(_stack) <= 0)? undefined : _stack[array_length(_stack)-1];
                        
                        if (is_struct(_stackTop))
                        {
                            _inStructKey   = true;
                            _inStructValue = false;
                            _inArray        = false;
                        }
                        else if (is_array(_stackTop))
                        {
                            _inStructKey   = false;
                            _inStructValue = false;
                            _inArray        = true;
                        }
                    }
                    else
                    {
                        show_error("Found unexpected ]\n ", true);
                    }
                break;
                
                case ord("{"):
                    if (_expectingComma)
                    {
                        show_error("Found {, was expecting comma\n ", true);
                    }
                    else if (_expectingColon)
                    {
                        show_error("Found {, was expecting colon\n ", true);
                    }
                    else if (_inStructKey)
                    {
                        show_error("Cannot use a struct as a struct key\n ", true);
                    }
                    else
                    {
                        var _new_stack_top = {};
                        
                        if (_inStructValue)
                        {
                            _expectingComma = true;
                            _stackTop[$ _structKey] = _new_stack_top;
                        }
                        else if (_inArray)
                        {
                            array_push(_stackTop, _new_stack_top);
                        }
                        
                        if (_root == undefined) _root = _new_stack_top;
                        array_push(_stack, _new_stack_top);
                        _stackTop = _new_stack_top;
                        
                        _expectingComma = false;
                        _inStructKey   = true;
                        _inStructValue = false;
                        _inArray        = false;
                    }
                break;
                
                case ord("}"):
                    if (_expectingColon)
                    {
                        show_error("Found }, was expecting colon\n ", true);
                    }
                    else if (_inStructKey || _inStructValue)
                    {
                        _expectingComma = true;
                        
                        array_pop(_stack);
                        _stackTop = (array_length(_stack) <= 0)? undefined : _stack[array_length(_stack)-1];
                        
                        if (is_struct(_stackTop))
                        {
                            _inStructKey   = true;
                            _inStructValue = false;
                            _inArray        = false;
                        }
                        else if (is_array(_stackTop))
                        {
                            _inStructKey   = false;
                            _inStructValue = false;
                            _inArray        = true;
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
                            _inComment = true;
                            buffer_seek(_buffer, buffer_seek_relative, 1);
                        }
                        else if (_next_byte == ord("*"))
                        {
                            _inMultilineComment = true;
                            buffer_seek(_buffer, buffer_seek_relative, 1);
                        }
                    }
                    else if (_byte > 0x20)
                    {
                        if (_expectingComma)
                        {
                            show_error("Was expecting comma\n ", true);
                        }
                        else if (_expectingColon)
                        {
                            show_error("Wwas expecting colon\n ", true);
                        }
                        else if (_inStructKey)
                        {
                            show_error("Struct keys must be strings\n ", true);
                        }
                        
                        _readStart = buffer_tell(_buffer)-1;
                        _inValue = true;
                    }
                break;
            }
        }
    }
    
    if (_cacheBuffer != undefined) buffer_delete(_cacheBuffer);
    
    if (array_length(_stack) > 0) show_error("One or more JSON objects/arrays not terminataed\n ", true);
    
    if (_inOffset != undefined)
    {
        buffer_seek(_buffer, buffer_seek_start, _oldOffset);
    }
    
    return _root;
}