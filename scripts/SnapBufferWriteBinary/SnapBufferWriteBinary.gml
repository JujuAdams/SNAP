// Feather disable all
/// @return Buffer that contains binary encoded struct/array nested data, using a proprietary format
/// 
/// @param buffer                      Buffer to write data to
/// @param struct/array                The data to be encoded. Can contain structs, arrays, strings, and numbers.   N.B. Will not encode ds_list, ds_map etc.
/// @param [alphabetizeStructs=false]  Whether to alphabetize struct variable names. Incurs a performance penalty is set to <true>
/// 
/// @jujuadams 2023-10-27

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

function SnapBufferWriteBinary(_buffer, _value, _alphabetizeStructs = false)
{
    //Determine if we need to use the legacy codebase by checking against struct_foreach()
    static _useLegacy = undefined;
    if (_useLegacy == undefined)
    {
        try
        {
            struct_foreach({}, function() {});
            _useLegacy = false;
        }
        catch(_error)
        {
            _useLegacy = true;
        }
    }
    
    if (_useLegacy)
    {
        return __SnapBufferWriteBinaryLegacy(_buffer, _value, _alphabetizeStructs);
    }
    else
    {
        with(method_get_self(__SnapBufferWriteBinaryStructIteratorMethod()))
        {
            __buffer = _buffer;
            __alphabetizeStructs = _alphabetizeStructs;
        }
        
        return __SnapBufferWriteBinary(_buffer, _value, _alphabetizeStructs);
    }
}

//We have to use this weird workaround because you can't static_get() a function you haven't run before
function __SnapBufferWriteBinaryStructIteratorMethod()
{
    static _method = method(
        {
            __buffer: undefined,
            __alphabetizeStructs: false,
        },
        function(_name, _value)
        {
            if (!is_string(_name)) show_error("SNAP:\nKeys must be strings\n ", true);
            
            buffer_write(__buffer, buffer_string, _name);
            __SnapBufferWriteBinary(__buffer, _value, __alphabetizeStructs);
        }
    );
    
    return _method;
}

function __SnapBufferWriteBinary(_buffer, _value, _alphabetizeStructs)
{
    static _structIteratorMethod = __SnapBufferWriteBinaryStructIteratorMethod();
    
    if (is_method(_value)) //Implicitly also a struct so we have to check this first
    {
        buffer_write(_buffer, buffer_u8, 0x03); //Convert all methods to strings
        buffer_write(_buffer, buffer_string, string(_value));
    }
    else if (is_struct(_value))
    {
        var _struct = _value;
        var _count = variable_struct_names_count(_struct);
        
        buffer_write(_buffer, buffer_u8, 0x01); //Struct
        buffer_write(_buffer, buffer_u64, _count);
        
        if (_count > 0)
        {
            if (_alphabetizeStructs)
            {
                var _names = variable_struct_get_names(_struct);
                array_sort(_names, true);
                var _i = 0;
                repeat(_count)
                {
                    var _name = _names[_i];
                    if (!is_string(_name)) show_error("SNAP:\nKeys must be strings\n ", true);
                    
                    buffer_write(_buffer, buffer_string, _name);
                    __SnapBufferWriteBinary(_buffer, _struct[$ _name], _alphabetizeStructs);
                
                    ++_i;
                }
            }
            else
            {
                struct_foreach(_struct, _structIteratorMethod);
            }
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
            __SnapBufferWriteBinary(_buffer, _array[_i], _alphabetizeStructs);
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
        buffer_write(_buffer, buffer_u8, 0x04); //f64
        buffer_write(_buffer, buffer_f64, _value);
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





//Legacy version for LTS use
function __SnapBufferWriteBinaryLegacy(_buffer, _value, _alphabetizeStructs)
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
        if (_alphabetizeStructs && is_array(_names)) array_sort(_names, true);
        
        var _count = array_length(_names);
        buffer_write(_buffer, buffer_u8, 0x01); //Struct
        buffer_write(_buffer, buffer_u64, _count);
        
        var _i = 0;
        repeat(_count)
        {
            var _name = _names[_i];
            if (!is_string(_name)) show_error("SNAP:\nKeys must be strings\n ", true);
            
            buffer_write(_buffer, buffer_string, string(_name));
            __SnapBufferWriteBinaryLegacy(_buffer, _struct[$ _name], _alphabetizeStructs);
            
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
            __SnapBufferWriteBinaryLegacy(_buffer, _array[_i], _alphabetizeStructs);
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
        buffer_write(_buffer, buffer_u8, 0x04); //f64
        buffer_write(_buffer, buffer_f64, _value);
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