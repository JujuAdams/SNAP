/// @return Buffer that encodes the provided 2D array
/// 
/// @param buffer            Buffer to write to
/// @param array2D           The 2D array to encode
/// @param [width]           Width of the 2D array at its widest point. If not specified this is automatically detected
/// @param [accurateFloats]  (bool) Whether to output floats at a higher accuracy than GM normally defaults to. Defaults to <false>. Setting this to <true> confers a performance penalty
/// 
/// @jujuadams 2022-10-30

function SnapBufferWriteNSV(_buffer, _root_array, _width = undefined, _accurateFloats = false)
{
    var _height = array_length(_root_array);
    
    //Determine the maximum width of the 2D array
    if (_width == undefined)
    {
        _width = 0;
        var _y = 0;
        repeat(_height)
        {
            _width = max(_width, array_length(_root_array[_y]));
            ++_y;
        }
    }
    
    buffer_write(_buffer, buffer_u64, _width);
    buffer_write(_buffer, buffer_u64, _height);
    
    var _y = 0;
    repeat(_height)
    {
        var _row_array = _root_array[_y];
        var _x = 0;
        repeat(array_length(_row_array))
        {
            var _value = _row_array[_x];
            
            if (is_real(_value))
            {
                buffer_write(_buffer, buffer_string, SnapNumberToString(_value, _accurateFloats));
            }
            else if (is_string(_value))
            {
                buffer_write(_buffer, buffer_string, _value);
            }
            else if (is_method(_value))
            {
                buffer_write(_buffer, buffer_string, string(_value));
            }
            else if (is_struct(_value) || is_array(_value))
            {
                show_error("Array contains a nested struct or array. This is incompatible with NSV\n ", true);
            }
            else
            {
                // YoYoGames in their finite wisdom added a new datatype in GMS2022.5 that doesn't stringify nicely
                //     string(instance.id) = "ref 100001"
                // This means we end up writing a string with a space in it to CSV. This is leads to difficulties when deserializing data
                // We can check <typeof(id) == "ref"> but string comparison is slow and gross
                // 
                // Instance IDs have the following detectable characteristics:
                // typeof(value)       = "ref"
                // is_array(value)     = false  *
                // is_bool(value)      = false
                // is_infinity(value)  = false
                // is_int32(value)     = false
                // is_int64(value)     = false
                // is_method(value)    = false  *
                // is_nan(value)       = false
                // is_numeric(value)   = true
                // is_ptr(value)       = false
                // is_real(value)      = false
                // is_string(value)    = false  *
                // is_struct(value)    = false  *
                // is_undefined(value) = false
                // is_vec3(value)      = false  *  (covered by is_array())
                // is_vec4(value)      = false  *  (covered by is_array())
                // 
                // Up above we've already tested the datatypes marked with asterisks
                // We can fish out instance references by checking <is_numeric() == true> and then excluding other numeric datatypes
                // ...but that's a lot of function calls so a <typeof(id) == "ref"> check is probably faster
                
                if (is_numeric(_value) && (typeof(_value) == "ref"))
                {
                    buffer_write(_buffer, buffer_string, string(real(_value))); //Save the numeric component of the instance ID
                }
                else
                {
                    buffer_write(_buffer, buffer_string, string(_value));
                }
            }
            
            ++_x;
        }
        
        repeat(_width - _x) buffer_write(_buffer, buffer_u8, 0x00); //Pad out the row with nulls
        
        ++_y;
    }
    
    return _buffer;
}
