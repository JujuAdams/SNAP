/// @return Struct/array that represents the data in the INI file
///
/// N.B. That this script is only intended to read the .ini files that GM generates
///      using the native ini_close() function. This is not a full implementation
///      of the INI specification
///
/// @param string      The INI string to parse
/// @param [tryReal]   Try to convert strings to real values if possible. Defaults to <true>
/// 
/// @jujuadams 2022-10-30

function SnapFromINIString(_string, _tryReal = true)
{
    var _buffer = buffer_create(string_byte_length(_string), buffer_fixed, 1);
    buffer_write(_buffer, buffer_text, _string);
    var _data = SnapBufferReadINI(_buffer, 0, buffer_get_size(_buffer), _tryReal);
    buffer_delete(_buffer);
    return _data;
}