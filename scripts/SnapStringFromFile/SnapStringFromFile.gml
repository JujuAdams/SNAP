/// @return String that represents all the text inside the file
///
/// @param filename     File to parse
/// @param [removeBOM]  Whether to look for the UTF8 byte order mark and remove it. Defaults to <true>
///
/// @jujuadams 2022-10-30

function SnapStringFromFile(_filename, _removeBOM = true)
{
    var _buffer = buffer_load(_filename);
    
    if (_removeBOM && (buffer_get_size(_buffer) >= 4) && (buffer_peek(_buffer, 0, buffer_u32) & 0xFFFFFF == 0xBFBBEF))
    {
        buffer_seek(_buffer, buffer_seek_start, 3);
    }
    
    var _string = buffer_read(_buffer, buffer_text);
    buffer_delete(_buffer);
    
    return _string;
}