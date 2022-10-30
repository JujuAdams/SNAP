/// @return Buffer that contains binary encoded struct/array nested data, using a proprietary format
/// 
/// @param buffer        Buffer to write data to
/// @param struct/array  The data to be encoded. Can contain structs, arrays, strings, and numbers.   N.B. Will not encode ds_list, ds_map etc.
/// 
/// @jujuadams 2022-10-30

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
    0x0A  -  pointer
    0x0B  -  instance ID reference
*/

function SnapToBinary(_buffer, _value)
{
    if (is_method(_value)) //Implicitly also a struct so we have to check this first
    {
        buffer_write(_buffer, buffer_u8, 0x03); //Convert all methods to strings
        buffer_write(_buffer, buffer_string, string(_value));
    }
    else if (is_struct(_value))
    {
        var _struct = _value;
        var _names = variable_struct_get_names(_struct);
        var _count = array_length(_names);
        
        buffer_write(_buffer, buffer_u8, 0x01); //Struct
        buffer_write(_buffer, buffer_u64, _count);
        
        var _i = 0;
        repeat(_count)
        {
            var _name = _names[_i];
            if (!is_string(_name)) show_error("Keys must be strings\n ", true);
            
            buffer_write(_buffer, buffer_string, string(_name));
            SnapToBinary(_buffer, _struct[$ _name]);
            
            ++_i;
        }
    }
    else if (is_array(_value))
    {
        var _array = _value;
        var _count = array_length(_array);
        
        buffer_write(_buffer, buffer_u8, 0x02); ///Array
        buffer_write(_buffer, buffer_u64, _count);
        
        var _i = 0;
        repeat(_count)
        {
            SnapToBinary(_buffer, _array[_i]);
            ++_i;
        }
    }
    else if (is_string(_value))
    {
        buffer_write(_buffer, buffer_u8, 0x03); //String
        buffer_write(_buffer, buffer_string, _value);
    }
    else if (is_real(_value))
    {
        if (_value == 0)
        {
            buffer_write(_buffer, buffer_u8, 0x05); //<false>
        }
        else if (_value == 1)
        {
            buffer_write(_buffer, buffer_u8, 0x06); //<true>
        }
        else
        {
            buffer_write(_buffer, buffer_u8, 0x04); //f64
            buffer_write(_buffer, buffer_f64, _value);
        }
    }
    else if (is_bool(_value))
    {
        buffer_write(_buffer, buffer_u8, _value? 0x06 : 0x05); //<true> or <false>
    }
    else if (is_undefined(_value))
    {
        buffer_write(_buffer, buffer_u8, 0x07); //<undefined>
    }
    else if (is_int32(_value))
    {
        buffer_write(_buffer, buffer_u8, 0x08); //s32
        buffer_write(_buffer, buffer_s32, _value);
    }
    else if (is_int64(_value))
    {
        buffer_write(_buffer, buffer_u8, 0x09); //u64
        buffer_write(_buffer, buffer_u64, _value);
    }
    else if (is_ptr(_value))
    {
        buffer_write(_buffer, buffer_u8, 0x0A); //pointer
        buffer_write(_buffer, buffer_u64, int64(_value));
    }
    else if (typeof(_value) == "ref") // is_ref() doesn't exist as of 2022-10-23
    {
        buffer_write(_buffer, buffer_u8, 0x0B); //instance ID reference
        buffer_write(_buffer, buffer_u64, int64(real(_value))); //Serialize the numeric part of the reference
    }
    else
    {
        show_message("Datatype \"" + typeof(_value) + "\" not supported");
    }
    
    return _buffer;
}