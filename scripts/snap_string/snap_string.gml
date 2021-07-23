/// Stringifies an input value. If the value is a nested struct/array then circular references will be handled gracefully
/// Circular references are indicated by the use of "<origin>" in the returned string
/// Otherwise, the output formatting copies GameMaker's native formatting, for better or worse
/// 
/// @param value   Value to stringify

global.__snap_found_map = ds_map_create();
global.__snap_string_buffer = buffer_create(1024, buffer_grow, 1);

function snap_string(_value)
{
    if (is_struct(_value) || is_array(_value))
    {
        ds_map_clear(global.__snap_found_map);
        
        buffer_seek(global.__snap_string_buffer, buffer_seek_start, 0);
        __snap_string_inner(_value, "<origin>");
        buffer_write(global.__snap_string_buffer, buffer_u8, 0x00);
        
        buffer_seek(global.__snap_string_buffer, buffer_seek_start, 0);
        return buffer_read(global.__snap_string_buffer, buffer_string);
    }
    else
    {
        return _value;
    }
}

function __snap_string_inner(_value, _long_name)
{
    if (is_struct(_value))
    {
        var _circular_ref = global.__snap_found_map[? _value];
        if (_circular_ref != undefined)
        {
            buffer_write(global.__snap_string_buffer, buffer_text, _circular_ref);
        }
        else
        {
            global.__snap_found_map[? _value] = _long_name;
            
            buffer_write(global.__snap_string_buffer, buffer_u16, 0x207B); // "{ "
            
            var _names = variable_struct_get_names(_value);
            var _length = array_length(_names);
            var _i = 0;
            repeat(_length)
            {
                var _name = _names[_i];
                
                buffer_write(global.__snap_string_buffer, buffer_text, _name);
                buffer_write(global.__snap_string_buffer, buffer_u8,   0x20); //space
                buffer_write(global.__snap_string_buffer, buffer_u8,   0x3A); // :
                buffer_write(global.__snap_string_buffer, buffer_u8,   0x20); //space
                __snap_string_inner(_value[$ _name], _long_name + "." + _name);
                if (_i < _length-1) buffer_write(global.__snap_string_buffer, buffer_u16, 0x202C); // ", "
                
                ++_i;
            }
            
            buffer_write(global.__snap_string_buffer, buffer_u16, 0x7D20); // "{ "
        }
    }
    else if (is_array(_value))
    {
        var _circular_ref = global.__snap_found_map[? _value];
        if (_circular_ref != undefined)
        {
            buffer_write(global.__snap_string_buffer, buffer_text, _circular_ref);
        }
        else
        {
            global.__snap_found_map[? _value] = _long_name;
            
            buffer_write(global.__snap_string_buffer, buffer_u16, 0x205B); // "[ "
            
            var _length = array_length(_value);
            var _i = 0;
            repeat(_length)
            {
                __snap_string_inner(_value[_i], _long_name + "[" + string(_i) + "]");
                if (_i < _length-1) buffer_write(global.__snap_string_buffer, buffer_u8, 0x2C); // ,
                
                ++_i;
            }
            
            buffer_write(global.__snap_string_buffer, buffer_u16, 0x5D20); // " ]"
        }
    }
    else if (is_string(_value))
    {
        buffer_write(global.__snap_string_buffer, buffer_u8,   0x22); // "
        buffer_write(global.__snap_string_buffer, buffer_text, _value);
        buffer_write(global.__snap_string_buffer, buffer_u8,   0x22); // "
    }
    else
    {
        buffer_write(global.__snap_string_buffer, buffer_text, string(_value));
    }
}