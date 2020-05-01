/// @return Nested struct/array data decoded from the buffer
/// 
/// @param buffer           Binary data to be decoded, created by sna_to_binary()
/// @param [destroyBuffer]  Set to <true> to destroy the input buffer. Defaults to <false>
/// 
/// @jujuadams 2020-05-02

function binary_to_sna()
{
    var _buffer         = argument[0];
    var _destroy_buffer = ((argument_count > 1) && (argument[1] != undefined))? argument[1] : false;
    
    var _result = (new __binary_to_sna_parser(_buffer, buffer_get_size(_buffer))).root;
    
    if (_destroy_buffer) buffer_delete(_buffer);
    
    return _result;
}

function __binary_to_sna_parser(_buffer, _buffer_size) constructor
{
    buffer          = _buffer;
    buffer_size     = _buffer_size;
    
    root            = undefined;
    root_is_struct  = false;
    root_array_size = 0;
    in_key          = false;
    key             = undefined;
    
    while(buffer_tell(buffer) < buffer_size)
    {
        if (in_key)
        {
            value = buffer_read(buffer, buffer_u8);
            if (value == 0x00)
            {
                exit;
            }
            else if (value == 0x03)
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
                if (value == 0x01)
                {
                    root = {};
                    root_is_struct = true;
                }
                else if (value == 0x02)
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
                    case 0x00: //terminator
                        exit;
                    break;
                    
                    case 0x01: //struct
                    case 0x02: //array
                        buffer_seek(buffer, buffer_seek_relative, -1);
                        value = (new __binary_to_sna_parser(_buffer, _buffer_size)).root;
                    break;
                    
                    case 0x03: //string
                        value = buffer_read(buffer, buffer_string);
                    break;
                    
                    case 0x04: //real
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