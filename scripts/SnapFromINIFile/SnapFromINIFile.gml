/// @return Struct/array that represents the data in the INI file
///
/// N.B. That this script is only intended to read the .ini files that GM generates
///      using the native ini_close() function. This is not a full implementation
///      of the INI specification
///
/// @param filename    The INI file to parse
/// @param [tryReal]   Try to convert strings to real values if possible. Defaults to <true>
/// 
/// @jujuadams 2022-10-30

function SnapFromINIFile(_filename, _tryReal = true)
{
    if (!file_exists(_filename))
    {
        show_error("SNAP:\nSnapFromINIFile():\nFile \"" + string(_filename) + "\" could not be found\n ", false);
        return {};
    }
    
    var _buffer = buffer_load(_filename);
    var _result = SnapBufferReadINI(_buffer, 0, buffer_get_size(_buffer), _tryReal);
    buffer_delete(_buffer);
    return _result;
}