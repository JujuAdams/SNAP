/// @return The result of the save operation, see documentation for buffer_save()
///
/// @param string    String to save
/// @param filename  File to save to
/// @param [addBOM]  Whether to add a UTF8 byte order mark to the start of the file. Defaults to <false>
///
/// @jujuadams 2022-10-30

function SnapStringToFile(_string, _filename, _addBOM = false)
{
    var _buffer = buffer_create(string_byte_length(_string) + (_addBOM? 3 : 0), buffer_fixed, 1);
    
    if (_addBOM)
    {
        buffer_write(_buffer, buffer_u32, 0xBFBBEF);
        buffer_seek(_buffer, buffer_seek_relative, -1);
    }
    
    buffer_write(_buffer, buffer_text, _string);
    
    var _result = buffer_save(_buffer, _filename);
    buffer_delete(_buffer);
    
    return _result;
}