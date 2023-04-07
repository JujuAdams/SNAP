/// @return Nested struct/array data that represents the contents of the "Config JSON" string
/// 
/// @param buffer  Buffer to read data from
/// @param offset  Offset in the buffer to read data from
/// 
/// @jujuadams 2023-04-07

function SnapBufferReadConfigJSON(_buffer, _inOffset = undefined)
{
    if (_inOffset != undefined)
    {
        var _oldOffset = buffer_tell(_buffer);
        buffer_seek(_buffer, buffer_seek_start, _inOffset);
    }
    
    var _bufferSize = buffer_get_size(_buffer);
    
    var _result = undefined;
    while(buffer_tell(_buffer) < _bufferSize)
    {
        var _byte = buffer_read(_buffer, buffer_u8);
        
        if ((_byte == ord("/")) && (buffer_peek(_buffer, buffer_tell(_buffer), buffer_u8) == ord("/")))
        {
            __SnapBufferReadConfigJSONComment(_buffer, _bufferSize);
        }
        else if ((_byte == ord("/")) && (buffer_peek(_buffer, buffer_tell(_buffer), buffer_u8) == ord("*")))
        {
            __SnapBufferReadConfigJSONMultilineComment(_buffer, _bufferSize);
        }
        else if (_byte == ord("["))
        {
            _result = __SnapBufferReadConfigJSONArray(_buffer, _bufferSize);
        }
        else if (_byte == ord("{"))
        {
            _result = __SnapBufferReadConfigJSONStruct(_buffer, _bufferSize);
        }
        else if (_byte > 0x20)
        {
            show_error("SNAP:\nFound unexpected character " + chr(_byte) + " (decimal=" + string(_byte) + ")\nWas expecting either { or [\n ", true);
        }
    }
    
    if (_inOffset != undefined)
    {
        buffer_seek(_buffer, buffer_seek_start, _oldOffset);
    }
    
    return _result;
}

function __SnapBufferReadConfigJSONArray(_buffer, _bufferSize)
{
    var _result = [];
    
    while(buffer_tell(_buffer) < _bufferSize)
    {
        var _byte = buffer_read(_buffer, buffer_u8);
        
        if ((_byte == ord("/")) && (buffer_peek(_buffer, buffer_tell(_buffer), buffer_u8) == ord("/")))
        {
            __SnapBufferReadConfigJSONComment(_buffer, _bufferSize);
        }
        else if ((_byte == ord("/")) && (buffer_peek(_buffer, buffer_tell(_buffer), buffer_u8) == ord("*")))
        {
            __SnapBufferReadConfigJSONMultilineComment(_buffer, _bufferSize);
        }
        else if (_byte == ord("]"))
        {
            return _result;
        }
        else if ((_byte == ord(":")) || (_byte == ord(",")))
        {
            show_error("SNAP:\nFound unexpected character " + chr(_byte) + " (decimal=" + string(_byte) + ")\nWas expecting a value\n ", true);
        }
        else if (_byte > 0x20)
        {
            var _value = __SnapBufferReadConfigJSONValue(_buffer, _bufferSize, _byte);
            array_push(_result, _value);
            
            //Find a comma, newline, or closing bracket
            while(buffer_tell(_buffer) < _bufferSize)
            {
                var _byte = buffer_read(_buffer, buffer_u8);
                if (_byte == ord("]"))
                {
                    return _result;
                }
                else if ((_byte == ord(",")) || (_byte == ord("\n")) || (_byte == ord("\r")))
                {
                    break;
                }
                else if (_byte > 0x20)
                {
                    show_error("SNAP:\nFound unexpected character " + chr(_byte) + " (decimal=" + string(_byte) + ")\nWas expecting comma, newline, or closing bracket\n ", true);
                }
            }
        }
    }
    
    show_error("SNAP:\nFound unterminated array\n ", true);
}

function __SnapBufferReadConfigJSONStruct(_buffer, _bufferSize)
{
    var _result = [];
    
    while(buffer_tell(_buffer) < _bufferSize)
    {
        var _byte = buffer_read(_buffer, buffer_u8);
        
        if ((_byte == ord("/")) && (buffer_peek(_buffer, buffer_tell(_buffer), buffer_u8) == ord("/")))
        {
            __SnapBufferReadConfigJSONComment(_buffer, _bufferSize);
        }
        else if ((_byte == ord("/")) && (buffer_peek(_buffer, buffer_tell(_buffer), buffer_u8) == ord("*")))
        {
            __SnapBufferReadConfigJSONMultilineComment(_buffer, _bufferSize);
        }
        else if (_byte == ord("}"))
        {
            //Handle empty structs
            if (array_length(_result) <= 0) array_push(_result, {});
            
            return _result;
        }
        else if ((_byte == ord(":")) || (_byte == ord(",")))
        {
            show_error("SNAP:\nFound unexpected character " + chr(_byte) + " (decimal=" + string(_byte) + ")\nWas expecting a key\n ", true);
        }
        else if (_byte > 0x20)
        {
            var _key = __SnapBufferReadConfigJSONValue(_buffer, _bufferSize, _byte);
            
            if (!is_string(_key))
            {
                if (is_array(_key))
                {
                    var _keyArray = _key;
                    var _keyArrayLength = array_length(_keyArray);
                    
                    if (_keyArrayLength <= 0)
                    {
                        show_error("SNAP:\nStruct key arrays must have at least one element\n ", true);
                    }
                    else if (_keyArrayLength <= 1)
                    {
                        if (!is_string(_keyArray[0])) show_error("SNAP:\nStruct keys must be strings (key was " + string(_keyArray[0]) + ", typeof=" + typeof(_keyArray[0]) + ")\n ", true);
                    }
                }
                else
                {
                    show_error("SNAP:\nStruct keys must be strings (key was " + string(_key) + ", typeof=" + typeof(_key) + ")\n ", true);
                }
            }
            
            //Find a colon
            while(buffer_tell(_buffer) < _bufferSize)
            {
                var _byte = buffer_read(_buffer, buffer_u8);
                
                if ((_byte == ord("/")) && (buffer_peek(_buffer, buffer_tell(_buffer), buffer_u8) == ord("*")))
                {
                    __SnapBufferReadConfigJSONMultilineComment(_buffer, _bufferSize);
                }
                else if (_byte == ord(":"))
                {
                    break;
                }
                else if (_byte > 0x20)
                {
                    show_error("SNAP:\nFound unexpected character " + chr(_byte) + " (decimal=" + string(_byte) + ")\nWas expecting a colon\n ", true);
                }
            }
            
            //Find the start of a value
            var _byte = 0x00;
            while(buffer_tell(_buffer) < _bufferSize)
            {
                var _byte = buffer_read(_buffer, buffer_u8);
                
                if ((_byte == ord("/")) && (buffer_peek(_buffer, buffer_tell(_buffer), buffer_u8) == ord("*")))
                {
                    __SnapBufferReadConfigJSONMultilineComment(_buffer, _bufferSize);
                }
                else if (_byte > 0x20)
                {
                    break;
                }
            }
            if (_byte <= 0x20) show_error("SNAP:\nCould not find start of value for key \"" + _key + "\"\n ", true);
            
            //Read a value and store it in the struct
            var _value = __SnapBufferReadConfigJSONValue(_buffer, _bufferSize, _byte);
            
            if (is_string(_key))
            {
                array_push(_result, {
                    k: _key,
                    v: _value,
                });
            }
            else //Is an array
            {
                //Use the original return value to set the first key
                array_push(_result, {
                    k: _keyArray[0],
                    v: _value,
                });
                
                //Use duplicate return values for subsequent keys
                var _i = 1;
                repeat(_keyArrayLength-1)
                {
                    var _key = _keyArray[_i];
                    if (!is_string(_key)) show_error("SNAP:\nStruct keys must be strings (key was " + string(_key) + ", typeof=" + typeof(_key) + ")\n ", true);
                    
                    array_push(_result, {
                        k: _keyArray[_i],
                        v: __SnapBufferReadConfigJSONDeepCopyInner(_value, self, self),
                    });
                    
                    ++_i;
                }
            }
            
            //Find a comma, newline, or closing bracket
            while(buffer_tell(_buffer) < _bufferSize)
            {
                var _byte = buffer_read(_buffer, buffer_u8);
                
                if ((_byte == ord("/")) && (buffer_peek(_buffer, buffer_tell(_buffer), buffer_u8) == ord("*")))
                {
                    __SnapBufferReadConfigJSONMultilineComment(_buffer, _bufferSize);
                }
                else if (_byte == ord("}"))
                {
                    return _result;
                }
                else if ((_byte == ord(",")) || (_byte == ord("\n")) || (_byte == ord("\r")))
                {
                    break;
                }
                else if (_byte > 0x20)
                {
                    show_error("SNAP:\nFound unexpected character " + chr(_byte) + " (decimal=" + string(_byte) + ")\nWas expecting comma, newline, or closing bracket\n ", true);
                }
            }
        }
    }
    
    show_error("SNAP:\nFound unterminated struct\n ", true);
}

function __SnapBufferReadConfigJSONValue(_buffer, _bufferSize, _firstByte)
{
    if (_firstByte == ord("["))
    {
        return __SnapBufferReadConfigJSONArray(_buffer, _bufferSize);
    }
    else if (_firstByte == ord("{"))
    {
        return __SnapBufferReadConfigJSONStruct(_buffer, _bufferSize);
    }
    else if (_firstByte == ord("\""))
    {
        return __SnapBufferReadConfigJSONDelimitedString(_buffer, _bufferSize);
    }
    else
    {
        return __SnapBufferReadConfigJSONString(_buffer, _bufferSize);
    }
}

function __SnapBufferReadConfigJSONDelimitedString(_buffer, _bufferSize)
{
    static _cacheBuffer = buffer_create(1024, buffer_grow, 1);
    buffer_seek(_cacheBuffer, buffer_seek_start, 0);
    
    var _start = buffer_tell(_buffer);
    var _stringUsesCache = false;
    
    while(buffer_tell(_buffer) < _bufferSize)
    {
        var _byte = buffer_read(_buffer, buffer_u8);
        
        if (_byte == ord("\""))
        {
            if (_stringUsesCache)
            {
                var _size = buffer_tell(_buffer) - _start-1;
                if (_size > 0)
                {
                    buffer_copy(_buffer, _start, _size, _cacheBuffer, buffer_tell(_cacheBuffer));
                    buffer_seek(_cacheBuffer, buffer_seek_relative, _size);
                }
                
                buffer_write(_cacheBuffer, buffer_u8, 0x00);
                buffer_seek(_cacheBuffer, buffer_seek_start, 0);
                var _result = buffer_read(_cacheBuffer, buffer_string);
            }
            else
            {
                var _end = buffer_tell(_buffer)-1;
                var _oldByte = buffer_peek(_buffer, _end, buffer_u8);
                buffer_poke(_buffer, _end, buffer_u8, 0x00);
                var _result = buffer_peek(_buffer, _start, buffer_string);
                buffer_poke(_buffer, _end, buffer_u8, _oldByte);
            }
            
            return _result;
        }
        else if (_byte == ord("\\"))
        {
            _stringUsesCache = true;
            
            var _size = buffer_tell(_buffer) - _start-1;
            if (_size > 0)
            {
                buffer_copy(_buffer, _start, _size, _cacheBuffer, buffer_tell(_cacheBuffer));
                buffer_seek(_cacheBuffer, buffer_seek_relative, _size);
            }
            
            var _byte = buffer_read(_buffer, buffer_u8);
            switch(_byte)
            {
                case ord("n"): buffer_write(_cacheBuffer, buffer_u8, ord("\n")); break;
                case ord("r"): buffer_write(_cacheBuffer, buffer_u8, ord("\r")); break;
                case ord("t"): buffer_write(_cacheBuffer, buffer_u8, ord("\t")); break;
                
                case ord("u"):
                    var _oldByte = buffer_peek(_buffer, buffer_tell(_buffer)+4, buffer_u8);
                    buffer_poke(_buffer, buffer_tell(_buffer)+4, buffer_u8, 0x00);
                    var _hex = buffer_read(_buffer, buffer_string);
                    buffer_seek(_buffer, buffer_seek_relative, -1);
                    buffer_poke(_buffer, buffer_tell(_buffer), buffer_u8, _oldByte);
                    
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
                    if ((_byte & $E0) == $C0) //110xxxxx 10xxxxxx
                    {
                        buffer_copy(_buffer, buffer_tell(_buffer)+1, 1, _cacheBuffer, buffer_tell(_cacheBuffer));
                        buffer_seek(_buffer, buffer_seek_relative, 1);
                        buffer_seek(_cacheBuffer, buffer_seek_relative, 1);
                    }
                    else if ((_byte & $F0) == $E0) //1110xxxx 10xxxxxx 10xxxxxx
                    {
                        buffer_copy(_buffer, buffer_tell(_buffer)+1, 2, _cacheBuffer, buffer_tell(_cacheBuffer));
                        buffer_seek(_buffer, buffer_seek_relative, 2);
                        buffer_seek(_cacheBuffer, buffer_seek_relative, 2);
                    }
                    else if ((_byte & $F8) == $F0) //11110xxx 10xxxxxx 10xxxxxx 10xxxxxx
                    {
                        buffer_copy(_buffer, buffer_tell(_buffer)+1, 3, _cacheBuffer, buffer_tell(_cacheBuffer));
                        buffer_seek(_buffer, buffer_seek_relative, 3);
                        buffer_seek(_cacheBuffer, buffer_seek_relative, 3);
                    }
                    else
                    {
                        buffer_write(_cacheBuffer, buffer_u8, _byte);
                    }
                break;
            }
            
            _start = buffer_tell(_buffer);
        }
    }
    
    show_error("SNAP:\nFound unterminated string\n ", true);
}

function __SnapBufferReadConfigJSONString(_buffer, _bufferSize)
{
    static _cacheBuffer = buffer_create(1024, buffer_grow, 1);
    buffer_seek(_cacheBuffer, buffer_seek_start, 0);
    
    var _result = undefined;
    
    var _start = buffer_tell(_buffer)-1;
    var _end   = _start+1;
    
    var _stringUsesCache = false;
    
    while(buffer_tell(_buffer) < _bufferSize)
    {
        var _byte = buffer_read(_buffer, buffer_u8);
        
        if ((_byte == ord(":"))
         || (_byte == ord(","))
         || (_byte == ord("}"))
         || (_byte == ord("]"))
         || (_byte == ord("\n"))
         || (_byte == ord("\r"))
         || ((_byte == ord("/")) && (buffer_peek(_buffer, buffer_tell(_buffer), buffer_u8) == ord("*"))))
        {
            if (_stringUsesCache)
            {
                var _size = _end - _start;
                if (_size > 0)
                {
                    buffer_copy(_buffer, _start, _size, _cacheBuffer, buffer_tell(_cacheBuffer));
                    buffer_seek(_cacheBuffer, buffer_seek_relative, _size);
                }
                
                buffer_write(_cacheBuffer, buffer_u8, 0x00);
                buffer_seek(_cacheBuffer, buffer_seek_start, 0);
                var _result = buffer_read(_cacheBuffer, buffer_string);
            }
            else
            {
                var _oldByte = buffer_peek(_buffer, _end, buffer_u8);
                buffer_poke(_buffer, _end, buffer_u8, 0x00);
                var _result = buffer_peek(_buffer, _start, buffer_string);
                buffer_poke(_buffer, _end, buffer_u8, _oldByte);
                
                if (_result == "true")
                {
                    _result = true;
                }
                else if (_result == "false")
                {
                    _result = false;
                }
                else if (_result == "null")
                {
                    _result = undefined;
                }
                else
                {
                    try
                    {
                        _result = real(_result);
                    }
                    catch(_error)
                    {
                        //Not a number apparently
                    }
                }
            }
            
            buffer_seek(_buffer, buffer_seek_relative, -1);
            
            if ((_byte == ord("/")) && (buffer_peek(_buffer, buffer_tell(_buffer), buffer_u8) == ord("*")))
            {
                __SnapBufferReadConfigJSONMultilineComment(_buffer, _bufferSize);
            }
            
            return _result;
        }
        else if (_byte == ord("\\"))
        {
            _stringUsesCache = true;
            
            var _size = buffer_tell(_buffer) - _start-1;
            if (_size > 0)
            {
                buffer_copy(_buffer, _start, _size, _cacheBuffer, buffer_tell(_cacheBuffer));
                buffer_seek(_cacheBuffer, buffer_seek_relative, _size);
            }
            
            var _byte = buffer_read(_buffer, buffer_u8);
            switch(_byte)
            {
                case ord("n"): buffer_write(_cacheBuffer, buffer_u8, ord("\n")); break;
                case ord("r"): buffer_write(_cacheBuffer, buffer_u8, ord("\r")); break;
                case ord("t"): buffer_write(_cacheBuffer, buffer_u8, ord("\t")); break;
                
                case ord("u"):
                    var _oldByte = buffer_peek(_buffer, buffer_tell(_buffer)+4, buffer_u8);
                    buffer_poke(_buffer, buffer_tell(_buffer)+4, buffer_u8, 0x00);
                    var _hex = buffer_read(_buffer, buffer_string);
                    buffer_seek(_buffer, buffer_seek_relative, -1);
                    buffer_poke(_buffer, buffer_tell(_buffer), buffer_u8, _oldByte);
                    
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
                    if ((_byte & $E0) == $C0) //110xxxxx 10xxxxxx
                    {
                        buffer_copy(_buffer, buffer_tell(_buffer)+1, 1, _cacheBuffer, buffer_tell(_cacheBuffer));
                        buffer_seek(_buffer, buffer_seek_relative, 1);
                        buffer_seek(_cacheBuffer, buffer_seek_relative, 1);
                    }
                    else if ((_byte & $F0) == $E0) //1110xxxx 10xxxxxx 10xxxxxx
                    {
                        buffer_copy(_buffer, buffer_tell(_buffer)+1, 2, _cacheBuffer, buffer_tell(_cacheBuffer));
                        buffer_seek(_buffer, buffer_seek_relative, 2);
                        buffer_seek(_cacheBuffer, buffer_seek_relative, 2);
                    }
                    else if ((_byte & $F8) == $F0) //11110xxx 10xxxxxx 10xxxxxx 10xxxxxx
                    {
                        buffer_copy(_buffer, buffer_tell(_buffer)+1, 3, _cacheBuffer, buffer_tell(_cacheBuffer));
                        buffer_seek(_buffer, buffer_seek_relative, 3);
                        buffer_seek(_cacheBuffer, buffer_seek_relative, 3);
                    }
                    else
                    {
                        buffer_write(_cacheBuffer, buffer_u8, _byte);
                    }
                break;
            }
            
            _start = buffer_tell(_buffer);
        }
        else if (_byte > 0x20)
        {
            _end = buffer_tell(_buffer);
        }
    }
    
    show_error("SNAP:\nFound unterminated value\n ", true);
}

function __SnapBufferReadConfigJSONComment(_buffer, _bufferSize)
{
    while(buffer_tell(_buffer) < _bufferSize)
    {
        var _byte = buffer_read(_buffer, buffer_u8);
        if ((_byte == ord("\n")) || (_byte == ord("\r")))
        {
            buffer_seek(_buffer, buffer_seek_relative, -1);
            break;
        }
    }
}

function __SnapBufferReadConfigJSONMultilineComment(_buffer, _bufferSize)
{
    while(buffer_tell(_buffer) < _bufferSize)
    {
        var _byte = buffer_read(_buffer, buffer_u8);
        if (_byte == ord("*"))
        {
            _byte = buffer_read(_buffer, buffer_u8);
            if (_byte == ord("/")) break;
        }
    }
}

function __SnapBufferReadConfigJSONDeepCopyInner(_value, _oldStruct, _newStruct)
{
    var _copy = _value;
    
    if (is_method(_value))
    {
        var _self = method_get_self(_value);
        if (_self == _oldStruct)
        {
            //If this method is bound to the source struct, create a new method bound to the new struct
            _value = method(_newStruct, method_get_index(_value));
        }
        else if (_self != undefined)
        {
            //If the scope of the method isn't <undefined> (global) then spit out a warning
            show_debug_message("SnapDeepCopy(): Warning! Deep copy found a method reference that could not be appropriately handled");
        }
    }
    else if (is_struct(_value))
    {
        var _namesArray = variable_struct_get_names(_value);
        var _copy = {};
        var _i = 0;
        repeat(array_length(_namesArray))
        {
            var _name = _namesArray[_i];
            _copy[$ _name] = __SnapBufferReadConfigJSONDeepCopyInner(_value[$ _name], _value, _copy);
            ++_i;
        }
    }
    else if (is_array(_value))
    {
        var _count = array_length(_value);
        var _copy = array_create(_count);
        var _i = 0;
        repeat(_count)
        {
            _copy[@ _i] = __SnapBufferReadConfigJSONDeepCopyInner(_value[_i], _oldStruct, _newStruct);
            ++_i;
        }
    }
    
    return _copy;
}