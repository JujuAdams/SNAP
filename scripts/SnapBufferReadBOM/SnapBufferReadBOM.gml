// Feather disable all
/// Attempts to read a UTF-8 byte order mark from a buffer, and returns <true> if a BOM is found
/// 
/// @param buffer  Buffer to try to read the byte order mark from
/// 
/// @jujuadams 2022-10-30

function SnapBufferReadBOM(_buffer)
{
    var _tell = buffer_tell(_buffer);
	if ((buffer_get_size(_buffer) >= 3)
    &&  (buffer_peek(_buffer, _tell,   buffer_u8) == 0xEF)
    &&  (buffer_peek(_buffer, _tell+1, buffer_u8) == 0xBB)
    &&  (buffer_peek(_buffer, _tell+2, buffer_u8) == 0xBF))
    {
		buffer_seek(_buffer, buffer_seek_relative, 3);
        return true;
	}
    
    return false;
}
