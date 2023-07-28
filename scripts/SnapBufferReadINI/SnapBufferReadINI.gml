// Feather disable all
/// @return Struct/array that represents the data in the INI file
///
/// N.B. That this script is only intended to read the .ini files that GM generates
///      using the native ini_close() function. This is not a full implementation
///      of the INI specification
///
/// @param buffer      The INI string to parse
/// @param offset
/// @param size
/// @param [tryReal]   Try to convert strings to real values if possible. Defaults to <true>
/// 
/// @jujuadams 2022-10-30

function SnapBufferReadINI(_buffer, _offset, _size, _tryReal = true)
{
    var _oldOffset = buffer_tell(_buffer);
    buffer_seek(_buffer, buffer_seek_start, _offset);
    
    var _skip_whitespace = true;
    var _in_comment      = false;
    
    var _in_key    = false;
    var _key_start = -1;
    var _key       = "";
    
    var _in_value            = false;
    var _in_string           = false;
    var _seen_backslash      = false;
    var _value_start         = 0;
    var _last_non_whitespace = -1;
    
    var _in_section     = false;
    var _section        = undefined;
    var _section_start  = 0;
    var _section_struct = undefined;
    
    var _root = {};
    
    repeat(_size)
    {
        var _value = buffer_read(_buffer, buffer_u8);
        
        if (_in_comment) //Ignore everything apart from a newline if we've seen a comment
        {
            if ((_value == 10) || (_value == 13)) //Newline
            {
                _in_comment      = false;
                _skip_whitespace = true;
            }
        }
        else if ((_value == ord(";")) && !_in_value) //We handle comments at the end of a key:value pair in the <_in_value> section
        {
            _in_comment = true;
        }
        else
        {
            if (_skip_whitespace && (_value > 32)) _skip_whitespace = false;
            
            if (!_skip_whitespace)
            {
                if (_in_value)
                {
                    if ((_value ==  0) //Null
                    ||  (_value == 10) //Newline
                    ||  (_value == 13) //Newline
                    ||  (_value == ord(";")) //Comment semicolon
                    ||  (_in_string && (_value == ord("\"")) && (buffer_peek(_buffer, buffer_tell(_buffer)-2, buffer_u8) != ord("\\")))) //Unescaped double quote
                    {
                        if (_value == ord(";")) _in_comment = true;
                        
                        var _old_tell = buffer_tell(_buffer);
                        if (_in_string) _value_start++;
                        buffer_poke(_buffer, _last_non_whitespace + 1, buffer_u8, 0x0);
                        buffer_seek(_buffer, buffer_seek_start, _value_start);
                        
                        _value = buffer_read(_buffer, buffer_string);
                        buffer_seek(_buffer, buffer_seek_start, _old_tell);
                        
                        if (_seen_backslash)
                        {
                            _value = string_replace_all(_value, "\\\\", chr(1)); //Turn all \\ into a system character
                            _value = string_replace_all(_value, "\\", ""); //Turn all single \ into nothing
                            _value = string_replace_all(_value, chr(1), "\\"); //Restore \\ from the system character
                        }
                        
                        if (!_in_string && _tryReal)
                        {
                            try { _value = real(_value); } catch(_) {}
                        }
                        
                        variable_struct_set(_section_struct, _key, _value);
                        
                        _in_value        = false;
                        _in_key          = true;
                        _key_start       = -1;
                        _skip_whitespace = true;
                        _in_string       = false;
                    }
                    else
                    {
                        if (_value_start < 0)
                        {
                            _value_start = buffer_tell(_buffer) - 1;
                            if (_value == ord("\"")) _in_string = true;
                        }
                        
                        if (_in_string || (_value > 32)) _last_non_whitespace = buffer_tell(_buffer) - 1;
                        if (!_in_string && (_value == 32) && (buffer_peek(_buffer, buffer_tell(_buffer) - 2, buffer_u8) == ord("\\"))) _last_non_whitespace = buffer_tell(_buffer) - 1;
                        if (_value == ord("\\")) _seen_backslash = true;
                    }
                }
                else if (_value == ord("[")) //Open a section
                {
                    _in_value      = false;
                    _in_key        = false;
                    _in_section    = true;
                    _section_start = buffer_tell(_buffer);
                }
                else if (_in_section)
                {
                    if (_value == ord("]"))
                    {
                        buffer_poke(_buffer, buffer_tell(_buffer)-1, buffer_u8, 0x0);
                        buffer_seek(_buffer, buffer_seek_start, _section_start);
                        _section = buffer_read(_buffer, buffer_string);
                        
                        var _section_struct = variable_struct_get(_root, _section);
                        if (_section_struct == undefined)
                        {
                            _section_struct = {};
                            variable_struct_set(_root, _section, _section_struct);
                        }
                        
                        _in_section      = false;
                        _in_key          = true;
                        _key_start       = -1;
                        _skip_whitespace = true;
                    }
                }
                else if (_in_key)
                {
                    if (_key_start < 0) _key_start = buffer_tell(_buffer)-1;
                    
                    if (_value == ord("="))
                    {
                        var _old_tell = buffer_tell(_buffer);
                        buffer_poke(_buffer, _last_non_whitespace + 1, buffer_u8, 0x0);
                        buffer_seek(_buffer, buffer_seek_start, _key_start);
                        _key = buffer_read(_buffer, buffer_string);
                        buffer_seek(_buffer, buffer_seek_start, _old_tell);
                        
                        _in_key          = false;
                        _skip_whitespace = true;
                        _in_value        = true;
                        _value_start     = -1;
                    }
                    else
                    {
                        if (_value > 32) _last_non_whitespace = buffer_tell(_buffer) - 1;
                    }
                }
            }
        }
    }
    
    buffer_seek(_buffer, buffer_seek_start, _oldOffset);
    
    return _root
}
