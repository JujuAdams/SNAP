// Feather disable all
function SnapNumberToString(_value, _accurateFloats)
{
    if (_accurateFloats && is_real(_value) && (floor(_value) != _value))
    {
        //Store floating point numbers with as much accuracy as we can get
        _value = string_format(_value, 0, 10);
        
        //Strip off trailing zeroes, and if necessary, the decimal point too
        var _length = string_length(_value);
        var _i = _length;
        repeat(_length)
        {
            if (string_char_at(_value, _i) != "0") break;
            --_i;
        }
        
        if (string_char_at(_value, _i) == ".") _i--;
        _value = string_delete(_value, _i + 1, _length - _i);
        
        return _value;
    }
    else
    {
        return string(_value);
    }
}
