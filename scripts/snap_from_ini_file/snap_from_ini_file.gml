/// @return Struct/array that represents the data in the INI file
///
/// N.B. That this script is only intended to read the .ini files that GM generates
///      using the native ini_close() function. This is not a full implementation
///      of the INI specification
///
/// @param filename    The INI file to parse
/// @param [tryReal]   Try to convert strings to real values if possible. Defaults to <true>
///
/// @jujuadams 2020-06-16

function snap_from_ini_file()
{
    var _filename = argument[0];
    var _try_real = (argument_count > 1)? argument[1] : undefined;
    
    if (!file_exists(_filename))
    {
        show_error("snap_from_ini_file():\nFile \"" + string(_filename) + "\" could not be found\n ", false);
        return {};
    }
    
    var _buffer = buffer_load(_filename);
    var _string = buffer_read(_buffer, buffer_string);
    buffer_delete(_buffer);
    
    return snap_from_ini_string(_string, _try_real);
}