// Feather disable all
/// @return Nested struct/array data that represents the contents of the QML string
/// 
/// @param buffer                Buffer to read data from
/// @param instanceofDict
/// @param [relaxedMode=false]
/// @param [offset]              Offset in the buffer to read data from
/// 
/// @jujuadams 2023-01-08

function SnapBufferReadQML(_buffer, _instanceofDict, _relaxed = false, _inOffset = undefined)
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
            __SnapBufferReadQMLComment(_buffer, _instanceofDict, _relaxed, _bufferSize);
        }
        else if ((_byte == ord("/")) && (buffer_peek(_buffer, buffer_tell(_buffer), buffer_u8) == ord("*")))
        {
            __SnapBufferReadQMLMultilineComment(_buffer, _instanceofDict, _relaxed, _bufferSize);
        }
        else if ((_byte == ord("[")) || (_byte == ord("]")) || (_byte == ord("\"")) || (_byte == ord("{")) || (_byte == ord("}")))
        {
            show_error("SNAP:\nFound unexpected character " + chr(_byte) + " (decimal=" + string(_byte) + ")\nWas expecting struct class name\n ", true);
        }
        else if (_byte > 0x20)
        {
            _result = __SnapBufferReadQMLValue(_buffer, _instanceofDict, _relaxed, _bufferSize, _byte);
            break;
        }
    }
    
    if (_inOffset != undefined)
    {
        buffer_seek(_buffer, buffer_seek_start, _oldOffset);
    }
    
    return _result;
}

function __SnapBufferReadQMLArray(_buffer, _instanceofDict, _relaxed, _bufferSize)
{
    var _result = [];
    
    while(buffer_tell(_buffer) < _bufferSize)
    {
        var _byte = buffer_read(_buffer, buffer_u8);
        
        if ((_byte == ord("/")) && (buffer_peek(_buffer, buffer_tell(_buffer), buffer_u8) == ord("/")))
        {
            __SnapBufferReadQMLComment(_buffer, _instanceofDict, _relaxed, _bufferSize);
        }
        else if ((_byte == ord("/")) && (buffer_peek(_buffer, buffer_tell(_buffer), buffer_u8) == ord("*")))
        {
            __SnapBufferReadQMLMultilineComment(_buffer, _instanceofDict, _relaxed, _bufferSize);
        }
        else if (_byte == ord("]"))
        {
            return _result;
        }
        else if ((_byte == ord(":")) || (_byte == ord(";")))
        {
            show_error("SNAP:\nFound unexpected character " + chr(_byte) + " (decimal=" + string(_byte) + ")\nWas expecting a value\n ", true);
        }
        else if (_byte > 0x20)
        {
            var _value = __SnapBufferReadQMLValue(_buffer, _instanceofDict, _relaxed, _bufferSize, _byte);
            array_push(_result, _value);
            
            //Find a comma, newline, or closing bracket
            while(buffer_tell(_buffer) < _bufferSize)
            {
                var _byte = buffer_read(_buffer, buffer_u8);
                if (_byte == ord("]"))
                {
                    return _result;
                }
                else if ((_byte == ord(";")) || (_byte == ord("\n")) || (_byte == ord("\r")))
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

function __SnapBufferReadQMLStruct(_buffer, _instanceofDict, _relaxed, _bufferSize, _result)
{
    var _childrenArrayVariableName = "children";
    
    while(buffer_tell(_buffer) < _bufferSize)
    {
        var _byte = buffer_read(_buffer, buffer_u8);
        
        if ((_byte == ord("/")) && (buffer_peek(_buffer, buffer_tell(_buffer), buffer_u8) == ord("/")))
        {
            __SnapBufferReadQMLComment(_buffer, _instanceofDict, _relaxed, _bufferSize);
        }
        else if ((_byte == ord("/")) && (buffer_peek(_buffer, buffer_tell(_buffer), buffer_u8) == ord("*")))
        {
            __SnapBufferReadQMLMultilineComment(_buffer, _instanceofDict, _relaxed, _bufferSize);
        }
        else if (_byte == ord("}"))
        {
            return _result;
        }
        else if ((_byte == ord(":")) || (_byte == ord(";")))
        {
            show_error("SNAP:\nFound unexpected character " + chr(_byte) + " (decimal=" + string(_byte) + ")\nWas expecting a key\n ", true);
        }
        else if (_byte > 0x20)
        {
            var _key = __SnapBufferReadQMLValue(_buffer, _instanceofDict, _relaxed, _bufferSize, _byte);
            if (is_struct(_key))
            {
                //If the "key" is actually a struct then we should add whatever we find to the parent's <children> array
                if (variable_struct_exists(_result, _childrenArrayVariableName))
                {
                    if (!is_array(_result[$ _childrenArrayVariableName]))
                    {
                        show_error("SNAP:\n." + string(_childrenArrayVariableName) + " variable for struct exists already but is not an array\n ", true);
                    }
                }
                else
                {
                    _result[$ _childrenArrayVariableName] = [];
                }
                
                array_push(_result[$ _childrenArrayVariableName], _key);
            }
            else
            {
                if (!is_string(_key)) show_error("SNAP:\nStruct keys must be strings (key was " + string(_key) + ", typeof=" + typeof(_key) + ")\n ", true);
                
                //Find a colon
                while(buffer_tell(_buffer) < _bufferSize)
                {
                    var _byte = buffer_read(_buffer, buffer_u8);
                    
                    if ((_byte == ord("/")) && (buffer_peek(_buffer, buffer_tell(_buffer), buffer_u8) == ord("*")))
                    {
                        __SnapBufferReadQMLMultilineComment(_buffer, _instanceofDict, _relaxed, _bufferSize);
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
                        __SnapBufferReadQMLMultilineComment(_buffer, _instanceofDict, _relaxed, _bufferSize);
                    }
                    else if (_byte > 0x20)
                    {
                        break;
                    }
                }
                if (_byte <= 0x20) show_error("SNAP:\nCould not find start of value for key \"" + _key + "\"\n ", true);
                
                //Read a value and store it in the struct
                var _value = __SnapBufferReadQMLValue(_buffer, _instanceofDict, _relaxed, _bufferSize, _byte);
                _result[$ _key] = _value;
            }
            
            //Find a comma, newline, or closing bracket
            while(buffer_tell(_buffer) < _bufferSize)
            {
                var _byte = buffer_read(_buffer, buffer_u8);
                
                if ((_byte == ord("/")) && (buffer_peek(_buffer, buffer_tell(_buffer), buffer_u8) == ord("*")))
                {
                    __SnapBufferReadQMLMultilineComment(_buffer, _instanceofDict, _relaxed, _bufferSize);
                }
                else if (_byte == ord("}"))
                {
                    return _result;
                }
                else if ((_byte == ord(";")) || (_byte == ord("\n")) || (_byte == ord("\r")))
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

function __SnapBufferReadQMLValue(_buffer, _instanceofDict, _relaxed, _bufferSize, _firstByte)
{
    if (_firstByte == ord("["))
    {
        return __SnapBufferReadQMLArray(_buffer, _instanceofDict, _relaxed, _bufferSize);
    }
    else if (_firstByte == ord("{"))
    {
        show_error("SNAP:\nStructs must have a class name\n ", true);
    }
    else if (_firstByte == ord("\""))
    {
        return __SnapBufferReadQMLDelimitedString(_buffer, _instanceofDict, _relaxed, _bufferSize);
    }
    else
    {
        return __SnapBufferReadQMLString(_buffer, _instanceofDict, _relaxed, _bufferSize);
    }
}

function __SnapBufferReadQMLString(_buffer, _instanceofDict, _relaxed, _bufferSize)
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
         || (_byte == ord(";"))
         || (_byte == ord("{"))
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
            
            if (_byte == ord("{"))
            {
                buffer_seek(_buffer, buffer_seek_relative, 1);
                
                if (!is_string(_result))
                {
                    show_error("SNAP:\nStruct class names must be strings (typeof=" + typeof(_result) + ")\n ", true);
                }
                
                var _constructor = _instanceofDict[$ _result];
                if (_relaxed && (_constructor == undefined)) _constructor = asset_get_index(_result);
                
                if (is_numeric(_constructor))
                {
                    if (!script_exists(_constructor))
                    {
                        show_error("SNAP:\nStruct class name \"" + string(_result) + "\" has script index " + string(_constructor) + " but this script doesn't exist\n ", true);
                    }
                    
                    _result = __SnapBufferReadQMLStruct(_buffer, _instanceofDict, _relaxed, _bufferSize, new _constructor());
                }
                else if (is_method(_constructor))
                {
                    _result = __SnapBufferReadQMLStruct(_buffer, _instanceofDict, _relaxed, _bufferSize, new _constructor());
                }
                else if (is_undefined(_constructor))
                {
                    show_error("SNAP:\nFound undefined struct class name \"" + string(_result) + "\"\n ", true);
                }
                else
                {
                    show_error("SNAP:\nFound invalid struct class name \"" + string(_result) + "\"\n ", true);
                }
            }
            else if ((_byte == ord("/")) && (buffer_peek(_buffer, buffer_tell(_buffer), buffer_u8) == ord("*")))
            {
                __SnapBufferReadQMLMultilineComment(_buffer, _instanceofDict, _relaxed, _bufferSize);
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

function __SnapBufferReadQMLDelimitedString(_buffer, _instanceofDict, _relaxed, _bufferSize)
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

function __SnapBufferReadQMLComment(_buffer, _instanceofDict, _relaxed, _bufferSize)
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

function __SnapBufferReadQMLMultilineComment(_buffer, _instanceofDict, _relaxed, _bufferSize)
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
