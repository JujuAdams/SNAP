/// @return Buffer that represents the struct/array nested data, using the MessagePack standard
///
/// More information on messagepack can be found here: https://msgpack.org/index.html
/// 
/// @param buffer
/// @param struct/array   The data to be encoded. Can contain structs, arrays, strings, and numbers.   N.B. Will not encode ds_list, ds_map etc.
/// 
/// @jujuadams 2022-10-30

function SnapBufferWriteMessagePack(_buffer, _value)
{
    if (is_method(_value)) //Implicitly also a struct so we have to check this first
    {
        __SnapToMessagepackString(_buffer, string(_value));
    }
    else if (is_struct(_value))
    {
        var _struct = _value;
        
        var _messagepackDatatype = _value[$ "messagepackDatatype"];
        if (_messagepackDatatype == "bin")
        {
            var _array = _struct.data;
            var _count = array_length(_array);
            
            if (_count <= 0xFF)
            {
                buffer_write(_buffer, buffer_u8, 0xC4);
                buffer_write(_buffer, buffer_u8, _count);
            }
            else if (_count <= 0xFFFF)
            {
                buffer_write(_buffer, buffer_u8, 0xC5);
                __SnapToMessagepackLittleEndian(_buffer, buffer_u16, _count);
            }
            else if (_count <= 0xFFFFFFFF)
            {
                buffer_write(_buffer, buffer_u8, 0xC6);
                __SnapToMessagepackLittleEndian(_buffer, buffer_u32, _count);
            }
            else
            {
                show_error("Trying to write a binary array longer than 4294967295 elements\n(How did you make an array this big?!)\n ", true);
            }
            
            var _i = 0;
            repeat(_count)
            {
                buffer_write(_buffer, buffer_u8, _array[_i]);
                ++_i;
            }
        }
        else if (_messagepackDatatype == "ext")
        {
            var _array = _struct.data;
            var _count = array_length(_array);
            
            if (_count == 1)
            {
                buffer_write(_buffer, buffer_u8, 0xD4);
            }
            else if (_count == 2)
            {
                buffer_write(_buffer, buffer_u8, 0xD5);
            }
            else if (_count == 4)
            {
                buffer_write(_buffer, buffer_u8, 0xD6);
            }
            else if (_count == 8)
            {
                buffer_write(_buffer, buffer_u8, 0xD7);
            }
            else if (_count == 16)
            {
                buffer_write(_buffer, buffer_u8, 0xD8);
            }
            else if (_count <= 0xFF)
            {
                buffer_write(_buffer, buffer_u8, 0xC7);
                buffer_write(_buffer, buffer_u8, _count);
            }
            else if (_count <= 0xFFFF)
            {
                buffer_write(_buffer, buffer_u8, 0xC8);
                __SnapToMessagepackLittleEndian(_buffer, buffer_u16, _count);
            }
            else if (_count <= 0xFFFFFFFF)
            {
                buffer_write(_buffer, buffer_u8, 0xC9);
                __SnapToMessagepackLittleEndian(_buffer, buffer_u32, _count);
            }
            else
            {
                show_error("Trying to write an extended binary array longer than 4294967295 elements\n(How did you make an array this big?!)\n ", true);
            }
            
            buffer_write(_buffer, buffer_s8, _struct.type);
            
            var _i = 0;
            repeat(_count)
            {
                buffer_write(_buffer, buffer_u8, _array[_i]);
                ++_i;
            }
        }
        else //Normal struct
        {
            var _names = variable_struct_get_names(_struct);
            
            var _count = array_length(_names);
            if (_count <= 0x0F)
            {
                //Size is determined by the first 4 bits
                buffer_write(_buffer, buffer_u8, 0x80 | _count);
            }
            else if (_count <= 0xFFFF)
            {
                buffer_write(_buffer, buffer_u8, 0xDE);
                __SnapToMessagepackLittleEndian(_buffer, buffer_u16, _count);
            }
            else if (_count <= 0xFFFFFFFF)
            {
                buffer_write(_buffer, buffer_u8, 0xDF);
                __SnapToMessagepackLittleEndian(_buffer, buffer_u32, _count);
            }
            else
            {
                show_error("Trying to write a struct longer than 4294967295 elements\n(How did you make a struct this big?!)\n ", true);
            }
            
            var _i = 0;
            repeat(_count)
            {
                var _name = _names[_i];
                SnapBufferWriteMessagePack(_buffer, _name);
                SnapBufferWriteMessagePack(_buffer, _struct[$ _name]);
                ++_i;
            }
        }
    }
    else if (is_array(_value))
    {
        var _array = _value;
        
        var _count = array_length(_array);
        if (_count <= 0x0F)
        {
            //Size is determined by the first 4 bits
            buffer_write(_buffer, buffer_u8, 0x90 | _count);
        }
        else if (_count <= 0xFFFF)
        {
            buffer_write(_buffer, buffer_u8, 0xDC);
            __SnapToMessagepackLittleEndian(_buffer, buffer_u16, _count);
        }
        else if (_count <= 0xFFFFFFFF)
        {
            buffer_write(_buffer, buffer_u8, 0xDD);
            __SnapToMessagepackLittleEndian(_buffer, buffer_u32, _count);
        }
        else
        {
            show_error("Trying to write an array longer than 4294967295 elements\n(How did you make an array this big?!)\n ", true);
        }
        
        var _i = 0;
        repeat(_count)
        {
            SnapBufferWriteMessagePack(_buffer, _array[_i]);
            ++_i;
        }
    }
    else if (is_string(_value))
    {
        __SnapToMessagepackString(_buffer, _value);
    }
    else if (is_bool(_value)) //Implicitly also "numeric" so we have to check this before is_numeric()
    {
        buffer_write(_buffer, buffer_u8, _value? 0xC3 : 0xC2);
    }
    else if (is_numeric(_value))
    {
        if (is_int32(_value) || is_int64(_value) || (floor(_value) == _value))
        {
            //Integer
            if (_value > 0)
            {
                //Positive, use an unsigned integer
                if (_value <= 0x7F)
                {
                    //First 7 bits are the integer
                    buffer_write(_buffer, buffer_u8, _value);
                }
                else if (_value <= 0xFF)
                {
                    buffer_write(_buffer, buffer_u8, 0xCC);
                    buffer_write(_buffer, buffer_u8, _value);
                }
                else if (_value <= 0xFFFF)
                {
                    buffer_write(_buffer, buffer_u8, 0xCD);
                    __SnapToMessagepackLittleEndian(_buffer, buffer_u16, _value);
                }
                else if (_value <= 0xFFFFFFFF)
                {
                    buffer_write(_buffer, buffer_u8, 0xCE);
                    __SnapToMessagepackLittleEndian(_buffer, buffer_u32, _value);
                }
                else
                {
                    buffer_write(_buffer, buffer_u8, 0xCF);
                    __SnapToMessagepackLittleEndian(_buffer, buffer_u64, _value);
                }
            }
            else if (_value == 0)
            {
                //Zero exactly
                buffer_write(_buffer, buffer_u8, 0x00);
            }
            else
            {
                //Negative, use a signed integer
                if (-_value <= 0x1F)
                {
                    //Least significant 5 bits are the integer
                    buffer_write(_buffer, buffer_u8, 0xE0 | (0x20 + _value));
                }
                else if (-_value <= 0xFF)
                {
                    buffer_write(_buffer, buffer_u8, 0xD0);
                    buffer_write(_buffer, buffer_s8, _value);
                }
                else if (-_value <= 0xFFFF)
                {
                    buffer_write(_buffer, buffer_u8, 0xD1);
                    __SnapToMessagepackLittleEndian(_buffer, buffer_s16, _value);
                }
                else if (-_value <= 0xFFFFFFFF)
                {
                    buffer_write(_buffer, buffer_u8, 0xD2);
                    __SnapToMessagepackLittleEndian(_buffer, buffer_s32, _value);
                }
                else
                {
                    //!!! No signed 64-bit integer read in GameMaker so this might be redundant
                    buffer_write(_buffer, buffer_u8, 0xD3);
                    __SnapToMessagepackLittleEndian(_buffer, buffer_u64, _value);
                }
            }
        }
        else if (is_real(_value))
        {
            //Floating Point
            buffer_write(_buffer, buffer_u8, 0xCB);
            __SnapToMessagepackLittleEndian(_buffer, buffer_f64, _value);
        }
        else
        {
            // Instance ID references are reported as numeric but aren't considered "real numbers" or integers
            buffer_write(_buffer, buffer_u8, 0xCF); //Unsigned 64-bit integer
            __SnapToMessagepackLittleEndian(_buffer, buffer_u64, int64(_value)); //Serialize the numeric part of the reference
        }
    }
    else if (is_undefined(_value))
    {
        buffer_write(_buffer, buffer_u8, 0xC0);
    }
    else
    {
        show_error("Unsupported datatype \"" + typeof(_value) + "\"\n ", false);
        buffer_write(_buffer, buffer_u8, 0xC0);
    }
    
    return _buffer;
}

function __SnapToMessagepackLittleEndian(_buffer, _datatype, _value)
{
    //messagepack is big-endian because the creator hates normalcy
    //This means we need to use a separate buffer for flipping values around
    static _flipBuffer = buffer_create(8, buffer_fixed, 1);
    switch(buffer_sizeof(_datatype))
    {
        case 1:
            buffer_write(_buffer, _datatype, _value);
        break;
        
        case 2:
            buffer_poke(_flipBuffer, 0, _datatype, _value);
            buffer_write(_buffer, buffer_u8, buffer_peek(_flipBuffer, 1, buffer_u8));
            buffer_write(_buffer, buffer_u8, buffer_peek(_flipBuffer, 0, buffer_u8));
        break;
        
        case 4:
            buffer_poke(_flipBuffer, 0, _datatype, _value);
            buffer_write(_buffer, buffer_u8, buffer_peek(_flipBuffer, 3, buffer_u8));
            buffer_write(_buffer, buffer_u8, buffer_peek(_flipBuffer, 2, buffer_u8));
            buffer_write(_buffer, buffer_u8, buffer_peek(_flipBuffer, 1, buffer_u8));
            buffer_write(_buffer, buffer_u8, buffer_peek(_flipBuffer, 0, buffer_u8));
        break;
        
        case 8:
            buffer_poke(_flipBuffer, 0, _datatype, _value);
            buffer_write(_buffer, buffer_u8, buffer_peek(_flipBuffer, 7, buffer_u8));
            buffer_write(_buffer, buffer_u8, buffer_peek(_flipBuffer, 6, buffer_u8));
            buffer_write(_buffer, buffer_u8, buffer_peek(_flipBuffer, 5, buffer_u8));
            buffer_write(_buffer, buffer_u8, buffer_peek(_flipBuffer, 4, buffer_u8));
            buffer_write(_buffer, buffer_u8, buffer_peek(_flipBuffer, 3, buffer_u8));
            buffer_write(_buffer, buffer_u8, buffer_peek(_flipBuffer, 2, buffer_u8));
            buffer_write(_buffer, buffer_u8, buffer_peek(_flipBuffer, 1, buffer_u8));
            buffer_write(_buffer, buffer_u8, buffer_peek(_flipBuffer, 0, buffer_u8));
        break;
    }
}

function __SnapToMessagepackString(_buffer, _string)
{
    var _size = string_byte_length(_string);
    if (_size <= 0x1F)
    {
        //Size is determined by the first 5 bits
        buffer_write(_buffer, buffer_u8, 0xA0 | _size);
    }
    else if (_size <= 0xFF)
    {
        buffer_write(_buffer, buffer_u8, 0xD9);
        buffer_write(_buffer, buffer_u8, _size);
    }
    else if (_size <= 0xFFFF)
    {
        buffer_write(_buffer, buffer_u8, 0xda);
        __SnapToMessagepackLittleEndian(_buffer, buffer_u16, _size);
    }
    else if (_size <= 0xFFFFFFFF)
    {
        buffer_write(_buffer, buffer_u8, 0xDB);
        __SnapToMessagepackLittleEndian(_buffer, buffer_u32, _size);
    }
    else
    {
        show_error("Trying to write a string longer than 4294967295 bytes\n(How did you make a string this big?!)\n ", true);
    }
    
    buffer_write(_buffer, buffer_text, _string);
}