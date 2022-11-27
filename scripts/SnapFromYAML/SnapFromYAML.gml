/// @return Nested struct/array data that represents the contents of the YAML string
/// 
/// @param string              The YAML string to be decoded
/// @param [replaceKeywords]   Whether to replace keywords (true, false, null) with boolean/undefined equivalents. Defaults to <true>
/// @param [trackFieldOrder]   Whether to track the order of struct fields as they appear in the YAML string (stored in __snapFieldOrder field on each GML struct). Default to <false>
/// @param [tabSize=2]         Size of tabs, measured in "number of spaces". This is used to calculate indentation
/// 
/// @jujuadams 2022-11-27

function SnapFromYAML(_string, _replaceKeywords = true, _tracekFieldOrder = false, _tabSize = 2)
{
    var _buffer = buffer_create(string_byte_length(_string), buffer_fixed, 1);
    buffer_write(_buffer, buffer_text, _string);
    var _data = SnapBufferReadYAML(_buffer, 0, _replaceKeywords, _tracekFieldOrder, _tabSize);
    buffer_delete(_buffer);
    return _data;
}