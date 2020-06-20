/// @return Nested struct/array data encoded from the buffer, using a proprietary format
/// 
/// @param buffer           Binary data to be decoded, created by snap_to_binary()
/// @param [offset]         Start position for binary decoding in the buffer. Defaults to 0, the start of the buffer
/// @param [destroyBuffer]  Set to <true> to destroy the input buffer. Defaults to <false>
/// 
/// @jujuadams 2020-06-20

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

function snap_from_binary()
{
    var _buffer         = argument[0];
    var _offset         = ((argument_count > 1) && (argument[1] != undefined))? argument[1] : 0;
    var _destroy_buffer = ((argument_count > 2) && (argument[2] != undefined))? argument[2] : false;
    
    var _old_tell = buffer_tell(_buffer);
    buffer_seek(_buffer, buffer_seek_start, _offset);
    var _result = (new __snap_from_binary_parser(_buffer)).root;
    buffer_seek(_buffer, buffer_seek_start, _old_tell);
    
    if (_destroy_buffer) buffer_delete(_buffer);
    
    return _result;
}

function __snap_from_binary_parser(_buffer) constructor
{
    buffer          = _buffer;
    root            = undefined;
    root_is_struct  = false;
    root_array_size = 0;
    in_key          = false;
    key             = undefined;
    
    while(true)
    {
        if (in_key)
        {
            value = buffer_read(buffer, buffer_u8);
            if (value == 0x00) //Terminator
            {
                exit;
            }
            else if (value == 0x03) //String
            {
                key = buffer_read(buffer, buffer_string);
            }
            else
            {
                show_error("Datatype for keys must be string (0x03), found " + string(value) + "\n ", false);
                key = undefined;
            }
            
            in_key = false;
        }
        else
        {
            value = buffer_read(buffer, buffer_u8);
            
            if (root == undefined)
            {
                if (value == 0x01) //Struct
                {
                    root = {};
                    root_is_struct = true;
                }
                else if (value == 0x02) //Array
                {
                    root = [];
                }
                else
                {
                    show_error("Unexpected datatype " + string(value) + ", was looking for a struct (0x01) or array (0x02) (position = " + string(buffer_tell(buffer) - 1) + ")\n ", false);
                }
            }
            else
            {
                switch(value)
                {
                    case 0x00: //Terminator
                        exit;
                    break;
                    
                    case 0x01: //Struct
                    case 0x02: //Array
                        buffer_seek(buffer, buffer_seek_relative, -1);
                        value = (new __snap_from_binary_parser(_buffer)).root;
                    break;
                    
                    case 0x03: //String
                        value = buffer_read(buffer, buffer_string);
                    break;
                    
                    case 0x04: //f64
                        value = buffer_read(buffer, buffer_f64);
                    break;
                    
                    case 0x05: //<false>
                        value = false;
                    break;
                    
                    case 0x06: //<true>
                        value = true;
                    break;
                    
                    case 0x07: //<undefined>
                        value = undefined;
                    break;
                    
                    case 0x08: //s32
                        value = buffer_read(buffer, buffer_s32);
                    break;
                    
                    case 0x09: //u64
                        value = int64(buffer_read(buffer, buffer_u64));
                    break;
                    
                    default:
                        show_error("Unsupported datatype " + string(value) + " (position = " + string(buffer_tell(buffer) - 1) + ")\n ", false);
                        value = undefined;
                    break;
                }
                
                if (root_is_struct)
                {
                    variable_struct_set(root, key, value);
                }
                else
                {
                    root[@ root_array_size++] = value;
                }
            }
            
            in_key = root_is_struct;
        }
    }
}