/// @return CSV string that encodes the provided 2D array
/// 
/// @param array2D             The 2D array to encode
/// @param [cellDelimiter]     Character to use to indicate where cells start and end. First 127 ASCII chars only. Defaults to a comma
/// @param [stringDelimiter]   Character to use to indicate where strings start and end. First 127 ASCII chars only. Defaults to a double quote
/// 
/// @jujuadams 2020-06-28

function snap_to_csv()
{
    var _root_array       = argument[0];
    var _cell_delimiter   = ((argument_count > 1) && (argument[1] != undefined))? argument[1] : ",";
    var _string_delimiter = ((argument_count > 2) && (argument[2] != undefined))? argument[2] : "\"";
    
    var _cell_delimiter_ord      = ord(_cell_delimiter);
    var _string_delimiter_double = _string_delimiter + _string_delimiter;
    var _string_delimiter_ord    = ord(_string_delimiter);
    
    var _buffer = buffer_create(1024, buffer_grow, 1);
    
    var _y = 0;
    repeat(array_length(_root_array))
    {
        var _row_array = _root_array[_y];
        var _x = 0;
        repeat(array_length(_row_array))
        {
            var _value = _row_array[_x];
            
            if (is_string(_value))
            {
                var _old_size = string_byte_length(_value);
                _value = string_replace_all(_value, _string_delimiter, _string_delimiter_double);
                
                if ((_old_size != string_byte_length(_value)) || (string_pos(_cell_delimiter, _value) > 0))
                {
                    buffer_write(_buffer, buffer_u8, _string_delimiter_ord);
                    buffer_write(_buffer, buffer_text, _value);
                    buffer_write(_buffer, buffer_u8, _string_delimiter_ord);
                }
                else
                {
                    buffer_write(_buffer, buffer_text, _value);
                }
            }
            else if (is_struct(_value) || is_array(_value))
            {
                show_error("snap_to_csv:\nArray contains a nested struct or array. This is incompatible with CSV\n ", false);
            }
            else
            {
                buffer_write(_buffer, buffer_text, string(_value));
            }
            
            buffer_write(_buffer, buffer_u8, _cell_delimiter_ord);
            ++_x;
        }
        
        buffer_write(_buffer, buffer_u8, 13);
        ++_y;
    }
    
    buffer_seek(_buffer, buffer_seek_start, 0);
    var _string = buffer_read(_buffer, buffer_string);
    buffer_delete(_buffer);
    
    return _string;
}