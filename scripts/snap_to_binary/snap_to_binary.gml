/// @return Buffer that contains binary encoded struct/array nested data, using a proprietary format
/// 
/// @param struct/array   The data to be encoded. Can contain structs, arrays, strings, and numbers.   N.B. Will not encode ds_list, ds_map etc.
/// 
/// @jujuadams 2020-09-13

//In the general case, functions/methods cannot be deserialised so we default to preventing their serialisation to begin with
//If you'd like to throw an error whenever this function tries to serialise a function/method, set SNAP_BINARY_SERIALISE_FUNCTION_NAMES to -1
//If you'd like to simply ignore functions/methods when serialising structs/arrays, set SNAP_BINARY_SERIALISE_FUNCTION_NAMES to 0
//If you'd like to use some clever tricks to deserialise functions/methods in a manner specific to your game, set SNAP_BINARY_SERIALISE_FUNCTION_NAMES to 1
#macro SNAP_BINARY_SERIALISE_FUNCTION_NAMES  -1

/*
    0x00  -  terminator
    0x01  -  struct
    0x02  -  array
    0x03  -  string
    0x04  -  f64
    0x05  -  <false>
    0x06  -  <true>
    0x07  -  <undefined>
    0x08  -  s32
    0x09  -  u64
*/

function snap_to_binary(_ds)
{
    return (new __snap_to_binary_parser(_ds)).buffer;
}

function __snap_to_binary_parser(_ds) constructor
{
    root = _ds;
    buffer = buffer_create(1024, buffer_grow, 1);
    
    static parse_struct = function(_struct)
    {
        buffer_write(buffer, buffer_u8, 0x01); //Struct
        
        var _names = variable_struct_get_names(_struct);
        var _count = array_length(_names);
        var _i = 0;
        repeat(_count)
        {
            var _name = _names[_i];
            value = variable_struct_get(_struct, _name);
            
            if (!is_method(value) || (SNAP_BINARY_SERIALISE_FUNCTION_NAMES != 0))
            {
                if (is_struct(_name) || is_array(_name))
                {
                    show_error("Key type \"" + typeof(_name) + "\" not supported\n ", false);
                    _name = string(ptr(_name));
                }
                
                buffer_write(buffer, buffer_u8, 0x03); //String
                buffer_write(buffer, buffer_string, string(_name));
                
                write_value();
            }
            
            ++_i;
        }
        
        buffer_write(buffer, buffer_u8, 0x00); //Terminator
    }
    
    
    
    static parse_array = function(_array)
    {
    
        var _count = array_length(_array);
        var _i = 0;
        
        buffer_write(buffer, buffer_u8, 0x02); ///Array
        
        repeat(_count)
        {
            value = _array[_i];
            write_value();
            ++_i;
        }
        
        buffer_write(buffer, buffer_u8, 0x00); //Terminator
    }
    
    
    
    static write_value = function()
    {
        if (is_struct(value))
        {
            parse_struct(value);
        }
        else if (is_array(value))
        {
            parse_array(value);
        }
        else if (is_string(value))
        {
            buffer_write(buffer, buffer_u8, 0x03); //String
            buffer_write(buffer, buffer_string, value);
        }
        else if (is_real(value))
        {
            if (value == 0)
            {
                buffer_write(buffer, buffer_u8, 0x05); //<false>
            }
            else if (value == 1)
            {
                buffer_write(buffer, buffer_u8, 0x06); //<true>
            }
            else
            {
                buffer_write(buffer, buffer_u8, 0x04); //f64
                buffer_write(buffer, buffer_f64, value);
            }
        }
        else if (is_bool(value))
        {
            buffer_write(buffer, buffer_u8, value? 0x06 : 0x05); //<true> or <false>
        }
        else if (is_undefined(value))
        {
            buffer_write(buffer, buffer_u8, 0x07); //<undefined>
        }
        else if (is_int32(value))
        {
            buffer_write(buffer, buffer_u8, 0x08); //s32
            buffer_write(buffer, buffer_s32, value);
        }
        else if (is_int64(value))
        {
            buffer_write(buffer, buffer_u8, 0x09); //u64
            buffer_write(buffer, buffer_u64, value);
        }
        else if (is_method(value))
        {
            if (SNAP_BINARY_SERIALISE_FUNCTION_NAMES <= 0)
            {
                if (SNAP_BINARY_SERIALISE_FUNCTION_NAMES < 0) show_error("Functions/methods cannot be serialised\n(Please edit macro SNAP_BINARY_SERIALISE_FUNCTION_NAMES to change this behaviour)\n ", true);
                buffer_write(buffer, buffer_u8, 0x07); //<undefined>
            }
            else
            {
                buffer_write(buffer, buffer_u8, 0x03); //String
                buffer_write(buffer, buffer_string, value);
            }
        }
        else
        {
            show_message("Datatype \"" + typeof(value) + "\" not supported");
        }
    }
    
    
    
    if (is_struct(root))
    {
        parse_struct(root);
    }
    else if (is_array(root))
    {
        parse_array(root);
    }
    else
    {
        show_error("Value not struct or array. Returning empty string\n ", false);
    }
    
    buffer_resize(buffer, buffer_tell(buffer));
}