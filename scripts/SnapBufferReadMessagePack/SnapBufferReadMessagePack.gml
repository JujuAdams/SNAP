/// @return Nested struct/array data decoded from the buffer, using the messagepack standard
///
/// More information on messagepack can be found here: https://msgpack.org/index.html
/// 
/// @param buffer  Binary data to be decoded
/// @param offset  Start position for binary decoding in the buffer
/// 
/// @jujuadams 2022-10-30

function SnapBufferReadMessagePack(_buffer, _offset)
{
    var _oldOffset = buffer_tell(_buffer);
    buffer_seek(_buffer, buffer_seek_start, _offset);
    var _value = __SnapFromMessagepackValue(_buffer);
    buffer_seek(_buffer, buffer_seek_start, _oldOffset);
    return _value;
}

function __SnapFromMessagepackValue(_buffer)
{
    var _byte = buffer_read(_buffer, buffer_u8);
    if (_byte <= 0x7f) //positive fixint 0x00 -> 0x7f
    {
        //First 7 bits are the integer
        return int64(_byte & 0x7F);
    }
    else if (_byte <= 0x8F) //fixmap 0x80 -> 0x8f
    {
        //Size is determined by the first 4 bits
        return __SnapFromMessagepackStruct(_buffer, _byte & 0x0F);
    }
    else if (_byte <= 0x9F) //fixarray 0x90 -> 0x9f
    {
        //Size is determined by the first 4 bits
        return __SnapFromMessagepackArray(_buffer, _byte & 0x0F);
    }
    else if (_byte <= 0xBF) //fixstr 0xa0 -> 0xbf
    {
        //Size is determined by the first 5 bits
        return __SnapFromMessagepackString(_buffer, _byte & 0x1F);
    }
    else if ((_byte >= 0xE0) && (_byte <= 0xFF)) //negative fixint 0xe0 -> 0xff
    {
        //Least significant 5 bites are the integer
        return ((_byte & 0x1F) - 0x20);
    }
    else switch(_byte)
    {
        case 0xc0: /*191*/ return undefined; break; //nil
        case 0xc1: /*192*/ show_debug_message("SnapBufferReadMessagePack(): Warning! Datatype 0xC1 found, but this value should never be used"); break; //Baby shoes for sale, never worn
        case 0xc2: /*193*/ return bool(false); break; //false
        case 0xc3: /*194*/ return bool(true ); break; //true
        
        case 0xc4: /*195*/ return __SnapFromMessagepackBin(_buffer, buffer_read(                      _buffer, buffer_u8 )); break; //bin  8
        case 0xc5: /*196*/ return __SnapFromMessagepackBin(_buffer, __SnapFromMessagepackLittleEndian(_buffer, buffer_u16)); break; //bin 16
        case 0xc6: /*197*/ return __SnapFromMessagepackBin(_buffer, __SnapFromMessagepackLittleEndian(_buffer, buffer_u32)); break; //bin 32
        
        case 0xc7: /*198*/ return __SnapFromMessagepackExt(_buffer, buffer_read(                      _buffer, buffer_u8 )); break; //ext  8
        case 0xc8: /*199*/ return __SnapFromMessagepackExt(_buffer, __SnapFromMessagepackLittleEndian(_buffer, buffer_u16)); break; //ext 16
        case 0xc9: /*201*/ return __SnapFromMessagepackExt(_buffer, __SnapFromMessagepackLittleEndian(_buffer, buffer_u32)); break; //ext 32
        
        case 0xca: /*202*/ return __SnapFromMessagepackLittleEndian(_buffer, buffer_f32); break; //float 32
        case 0xcb: /*203*/ return __SnapFromMessagepackLittleEndian(_buffer, buffer_f64); break; //float 64
        
        case 0xcc: /*204*/ return buffer_read(                      _buffer, buffer_u8 ); break; // uint  8
        case 0xcd: /*205*/ return __SnapFromMessagepackLittleEndian(_buffer, buffer_u16); break; // uint 16
        case 0xce: /*206*/ return __SnapFromMessagepackLittleEndian(_buffer, buffer_u32); break; // uint 32
        case 0xcf: /*207*/ return __SnapFromMessagepackLittleEndian(_buffer, buffer_u64); break; // uint 64
        
        case 0xd0: /*208*/ return buffer_read(                      _buffer, buffer_s8 ); break; //  int  8
        case 0xd1: /*209*/ return __SnapFromMessagepackLittleEndian(_buffer, buffer_s16); break; //  int 16
        case 0xd2: /*210*/ return __SnapFromMessagepackLittleEndian(_buffer, buffer_s32); break; //  int 32
        case 0xd3: /*211*/ return __SnapFromMessagepackLittleEndian(_buffer, buffer_u64); break; //  int 64 !!! No signed 64-bit integer read in GameMaker
        
        case 0xd4: /*212*/ return __SnapFromMessagepackExt(_buffer,  1); break; //fixext  1
        case 0xd5: /*213*/ return __SnapFromMessagepackExt(_buffer,  2); break; //fixext  2
        case 0xd6: /*214*/ return __SnapFromMessagepackExt(_buffer,  4); break; //fixext  4
        case 0xd7: /*215*/ return __SnapFromMessagepackExt(_buffer,  8); break; //fixext  8
        case 0xd8: /*216*/ return __SnapFromMessagepackExt(_buffer, 16); break; //fixext 16
        
        case 0xd9: /*217*/ return __SnapFromMessagepackString(_buffer, buffer_read(                      _buffer, buffer_u8 )); break; //str  8
        case 0xda: /*218*/ return __SnapFromMessagepackString(_buffer, __SnapFromMessagepackLittleEndian(_buffer, buffer_u16)); break; //str 16
        case 0xdb: /*219*/ return __SnapFromMessagepackString(_buffer, __SnapFromMessagepackLittleEndian(_buffer, buffer_u32)); break; //str 32
        
        case 0xdc: /*220*/ return __SnapFromMessagepackArray(_buffer, __SnapFromMessagepackLittleEndian(_buffer, buffer_u16)); break; //array 16
        case 0xdd: /*221*/ return __SnapFromMessagepackArray(_buffer, __SnapFromMessagepackLittleEndian(_buffer, buffer_u32)); break; //array 32
        
        case 0xde: /*222*/ return __SnapFromMessagepackStruct(_buffer, __SnapFromMessagepackLittleEndian(_buffer, buffer_u16)); break; //map 16
        case 0xdf: /*223*/ return __SnapFromMessagepackStruct(_buffer, __SnapFromMessagepackLittleEndian(_buffer, buffer_u32)); break; //map 32
        
        default:
            show_debug_message("SnapBufferReadMessagePack(): Warning! Unsupported datatype " + string(_byte) + " found");
        break;
    }
}

function __SnapFromMessagepackStruct(_buffer, _size)
{
    var _struct = {};
    
    repeat(_size)
    {
        var _key = __SnapFromMessagepackValue(_buffer);
        _struct[$ _key] = __SnapFromMessagepackValue(_buffer);
    }
    
    return _struct;
}

function __SnapFromMessagepackArray(_buffer, _size)
{
    var _array = array_create(_size, undefined);
    
    var _i = 0;
    repeat(_size)
    {
        _array[@ _i] = __SnapFromMessagepackValue(_buffer);
        ++_i;
    }
    
    return _array;
}

function __SnapFromMessagepackString(_buffer, _size)
{
    //Return an empty string if we don't expect any data whatsoever
    if (_size == 0) return "";
    
    var _nullPosition = buffer_tell(_buffer) + _size;
    if (_nullPosition >= buffer_get_size(_buffer))
    {
        //If the string runs into the end of the buffer, just read out the string
        return buffer_read(_buffer, buffer_text);
    }
    
    //Read the byte just after the end of the string and replace it with 0x00
    var _peek = buffer_peek(_buffer, _nullPosition, buffer_u8);
    buffer_poke(_buffer, _nullPosition, buffer_u8, 0x00);
    
    //Get GM to read from the start of the string to the null byte
    var _string = buffer_read(_buffer, buffer_string);
    
    //Take a step back and replace the original byte with what we found before
    buffer_seek(_buffer, buffer_seek_relative, -1);
    buffer_poke(_buffer, _nullPosition, buffer_u8, _peek);
    
    return _string;
}

function __SnapFromMessagepackBin(_buffer, _size)
{
    var _array = array_create(_size);
    
    var _i = 0;
    repeat(_size)
    {
        _array[@ _i] = buffer_read(_buffer, buffer_u8);
        ++_i;
    }
    
    return {
        messagepackDatatype: "bin",
        data: _array
    };
}

function __SnapFromMessagepackExt(_buffer, _size)
{
    var _type = buffer_read(_buffer, buffer_s8);
    var _array = array_create(_size);
    
    var _i = 0;
    repeat(_size)
    {
        _array[@ _i] = buffer_read(_buffer, buffer_u8);
        ++_i;
    }
    
    return {
        messagepackDatatype: "ext",
        type: _type,
        data: _array
    };
}

function __SnapFromMessagepackLittleEndian(_buffer, _datatype)
{
    //messagepack is big-endian because the creator hates normalcy
    //This means we need to use a separate buffer for flipping values around
    static _flipBuffer = buffer_create(8, buffer_fixed, 1);
    switch(buffer_sizeof(_datatype))
    {
        case 1:
            return buffer_read(_buffer, _datatype);
        break;
        
        case 2:
            buffer_poke(_flipBuffer, 1, buffer_u8, buffer_read(_buffer, buffer_u8));
            buffer_poke(_flipBuffer, 0, buffer_u8, buffer_read(_buffer, buffer_u8));
        break;
        
        case 4:
            buffer_poke(_flipBuffer, 3, buffer_u8, buffer_read(_buffer, buffer_u8));
            buffer_poke(_flipBuffer, 2, buffer_u8, buffer_read(_buffer, buffer_u8));
            buffer_poke(_flipBuffer, 1, buffer_u8, buffer_read(_buffer, buffer_u8));
            buffer_poke(_flipBuffer, 0, buffer_u8, buffer_read(_buffer, buffer_u8));
        break;
        
        case 8:
            buffer_poke(_flipBuffer, 7, buffer_u8, buffer_read(_buffer, buffer_u8));
            buffer_poke(_flipBuffer, 6, buffer_u8, buffer_read(_buffer, buffer_u8));
            buffer_poke(_flipBuffer, 5, buffer_u8, buffer_read(_buffer, buffer_u8));
            buffer_poke(_flipBuffer, 4, buffer_u8, buffer_read(_buffer, buffer_u8));
            buffer_poke(_flipBuffer, 3, buffer_u8, buffer_read(_buffer, buffer_u8));
            buffer_poke(_flipBuffer, 2, buffer_u8, buffer_read(_buffer, buffer_u8));
            buffer_poke(_flipBuffer, 1, buffer_u8, buffer_read(_buffer, buffer_u8));
            buffer_poke(_flipBuffer, 0, buffer_u8, buffer_read(_buffer, buffer_u8));
        break;
    }
    
    return buffer_peek(_flipBuffer, 0, _datatype);
}