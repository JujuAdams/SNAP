/// @return Nested struct/array data encoded from the buffer, using a proprietary format
/// 
/// @param buffer  Binary data to be decoded, created by SnapBufferWriteBinary()
/// @param offset  Start position for binary decoding in the buffer. Defaults to 0, the start of the buffer
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
    0x0B  -  instance ID
*/

function SnapBufferReadBinary(_buffer, _offset)
{
    var _oldOffset = buffer_tell(_buffer);
    buffer_seek(_buffer, buffer_seek_start, _offset);
    var _value = __SnapFromBinaryValue(_buffer);
    buffer_seek(_buffer, buffer_seek_start, _oldOffset);
    return _value;
}

function __SnapFromBinaryValue(_buffer)
{
    var _datatype = buffer_read(_buffer, buffer_u8);
    switch(_datatype)
    {
        case 0x01: // struct
            var _count = buffer_read(_buffer, buffer_u64);
            var _struct = {};
            
            repeat(_count)
            {
                var _name = buffer_read(_buffer, buffer_string);
                _struct[$ _name] = __SnapFromBinaryValue(_buffer);
            }
            
            return _struct;
        break;
        
        case 0x02: // array
            var _count = buffer_read(_buffer, buffer_u64);
            var _array = array_create(_count, undefined);
            
            var _i = 0;
            repeat(_count)
            {
                _array[@ _i] = __SnapFromBinaryValue(_buffer);
                ++_i;
            }
            
            return _array;
        break;
        
        case 0x03: // string
            return buffer_read(_buffer, buffer_string);
        break;
        
        case 0x04: // f64
            return buffer_read(_buffer, buffer_f64);
        break;
        
        case 0x05: // false
            return false;
        break;
        
        case 0x06: // true
            return true;
        break;
        
        case 0x07: // undefined
            return undefined;
        break;
        
        case 0x08: // s32
            return buffer_read(_buffer, buffer_s32);
        break;
        
        case 0x09: // u64
            return int64(buffer_read(_buffer, buffer_u64));
        break;
        
        case 0x0A: // pointer
            return ptr(buffer_read(_buffer, buffer_u64));
        break;
        
        case 0x0B: // instance ID reference
            return real(buffer_read(_buffer, buffer_u64)); //We can't make an instance ID reference so return a real number instead
        break;
        
        default:
            show_error("SNAP:\nUnsupported datatype " + string(buffer_peek(_buffer, buffer_u8, buffer_tell(_buffer)-1)) + " (position = " + string(buffer_tell(_buffer) - 1) + ")\n ", false);
        break;
    }
}