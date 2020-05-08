/// @return Buffer that contains binary encoded struct/array nested data
/// 
/// @param struct/array   The data to be encoded. Can contain structs, arrays, strings, and numbers.   N.B. Will not encode ds_list, ds_map etc.
/// 
/// @jujuadams 2020-05-02

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
    
    
    
    static write_value = function(_value)
    {
        if (is_struct(_value))
        {
            buffer_write(buffer, buffer_u8, 0x01); //Struct
            
            foreach(_value, function(_value, _index, _name)
            {
                if (is_struct(_name) || is_array(_name))
                {
                    show_error("Key type \"" + typeof(_name) + "\" not supported\n ", false);
                    _name = string(ptr(_name));
                }
                
                buffer_write(buffer, buffer_u8, 0x03); //String
                buffer_write(buffer, buffer_string, string(_name));
                
                write_value(_value);
            });
            
            buffer_write(buffer, buffer_u8, 0x00); //Terminator
        }
        else if (is_array(_value))
        {
            buffer_write(buffer, buffer_u8, 0x02); ///Array
            
            foreach(_value, function(_value, _index)
            {
                write_value(_value);
            });
            
            buffer_write(buffer, buffer_u8, 0x00); //Terminator
        }
        else if (is_string(_value))
        {
            buffer_write(buffer, buffer_u8, 0x03); //String
            buffer_write(buffer, buffer_string, _value);
        }
        else if (is_real(_value))
        {
            if (_value == 0)
            {
                buffer_write(buffer, buffer_u8, 0x05); //<false>
            }
            else if (_value == 1)
            {
                buffer_write(buffer, buffer_u8, 0x06); //<true>
            }
            else
            {
                buffer_write(buffer, buffer_u8, 0x04); //f64
                buffer_write(buffer, buffer_f64, _value);
            }
        }
        else if (is_bool(_value))
        {
            buffer_write(buffer, buffer_u8, _value? 0x06 : 0x05); //<true> or <false>
        }
        else if (is_undefined(_value))
        {
            buffer_write(buffer, buffer_u8, 0x07); //<undefined>
        }
        else if (is_int32(_value))
        {
            buffer_write(buffer, buffer_u8, 0x08); //s32
            buffer_write(buffer, buffer_s32, _value);
        }
        else if (is_int64(_value))
        {
            buffer_write(buffer, buffer_u8, 0x09); //u64
            buffer_write(buffer, buffer_u64, _value);
        }
        else
        {
            show_message("Datatype \"" + typeof(_value) + "\" not supported");
        }
    }
    
    
    
    if (is_struct(root) || is_array(root))
    {
        write_value(root);
    }
    else
    {
        show_error("Value not struct or array. Returning empty string\n ", false);
    }
    
    buffer_resize(buffer, buffer_tell(buffer));
}