/// Stringifies an input value in the same vein as GameMaker's native string() function
/// The string that this function is not intended to be parseable back into data - please use SnapToJSON() for that
/// If the value is a nested struct/array then circular references will be handled gracefully
/// Circular references are indicated by the use of "<origin>" in the returned string
/// Otherwise, the output formatting copies GameMaker's native formatting, for better or worse
/// 
/// @param value   Value to stringify
/// 
/// @jujuadams 2022-10-30

function SnapStringify(_value)
{
    var _foundMap        = ds_map_create();
    var _stringifyBuffer = buffer_create(1024, buffer_grow, 1);
    
    buffer_seek(_stringifyBuffer, buffer_seek_start, 0);
    __SnapStringifyValue(_value, "<origin>", _foundMap, _stringifyBuffer);
    buffer_write(_stringifyBuffer, buffer_u8, 0x00);
    
    buffer_seek(_stringifyBuffer, buffer_seek_start, 0);
    var _string = buffer_read(_stringifyBuffer, buffer_string);
    
    ds_map_destroy(_foundMap);
    buffer_delete(_stringifyBuffer);
    
    return _string;
}

function __SnapStringifyValue(_value, _longName, _foundMap, _stringifyBuffer)
{
    if (is_struct(_value))
    {
        var _circularRef = _foundMap[? _value];
        if (_circularRef != undefined)
        {
            buffer_write(_stringifyBuffer, buffer_text, _circularRef);
        }
        else
        {
            _foundMap[? _value] = _longName;
            
            buffer_write(_stringifyBuffer, buffer_u16, 0x207B); // "{ "
            
            var _names = variable_struct_get_names(_value);
            var _length = array_length(_names);
            var _i = 0;
            repeat(_length)
            {
                var _name = _names[_i];
                
                buffer_write(_stringifyBuffer, buffer_text, _name);
                buffer_write(_stringifyBuffer, buffer_u8,   0x20); //space
                buffer_write(_stringifyBuffer, buffer_u8,   0x3A); // :
                buffer_write(_stringifyBuffer, buffer_u8,   0x20); //space
                __SnapStringifyValue(_value[$ _name], _longName + "." + _name, _foundMap, _stringifyBuffer);
                if (_i < _length-1) buffer_write(_stringifyBuffer, buffer_u16, 0x202C); // ", "
                
                ++_i;
            }
            
            buffer_write(_stringifyBuffer, buffer_u16, 0x7D20); // "{ "
        }
    }
    else if (is_array(_value))
    {
        var _circular_ref = _foundMap[? _value];
        if (_circular_ref != undefined)
        {
            buffer_write(_stringifyBuffer, buffer_text, _circular_ref);
        }
        else
        {
            _foundMap[? _value] = _longName;
            
            buffer_write(_stringifyBuffer, buffer_u16, 0x205B); // "[ "
            
            var _length = array_length(_value);
            var _i = 0;
            repeat(_length)
            {
                __SnapStringifyValue(_value[_i], _longName + "[" + string(_i) + "]", _foundMap, _stringifyBuffer);
                if (_i < _length-1) buffer_write(_stringifyBuffer, buffer_u8, 0x2C); // ,
                
                ++_i;
            }
            
            buffer_write(_stringifyBuffer, buffer_u16, 0x5D20); // " ]"
        }
    }
    else if (is_string(_value))
    {
        buffer_write(_stringifyBuffer, buffer_u8,   0x22); // "
        buffer_write(_stringifyBuffer, buffer_text, _value);
        buffer_write(_stringifyBuffer, buffer_u8,   0x22); // "
    }
    else
    {
        buffer_write(_stringifyBuffer, buffer_text, string(_value));
    }
}