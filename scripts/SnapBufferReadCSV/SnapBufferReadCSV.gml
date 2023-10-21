// Feather disable all
/// Decodes CSV data stored in a buffer and outputs a 2D array
///
/// @return 2D array that represents the contents of the CSV string
/// 
/// @param buffer              Buffer to read data from
/// @param offset              Offset in the buffer to read data from
/// @param [size]              Number of bytes to read from the buffer. If not specified, the whole buffer is read
/// @param [cellDelimiter]     Character to use to indicate where cells start and end. First 127 ASCII chars only. Defaults to a comma
/// @param [stringDelimiter]   Character to use to indicate where strings start and end. First 127 ASCII chars only. Defaults to a double quote
/// 
/// @jujuadams 2023-01-02

function SnapBufferReadCSV(_buffer, _inOffset, _inSize = undefined, _cellDelimiter = ",", _stringDelimiter = "\"")
{
    if (_inOffset != undefined)
    {
        var _oldOffset = buffer_tell(_buffer);
        buffer_seek(_buffer, buffer_seek_start, _inOffset);
    }
	
    var _size = _inSize ?? buffer_get_size(_buffer) - buffer_tell(_buffer);
    
    var _restorePos  = _size + buffer_tell(_buffer);
    var _restoreByte = undefined;
    if (_restorePos < buffer_get_size(_buffer))
    {
        _restoreByte = buffer_peek(_buffer, _restorePos, buffer_u8);
        buffer_poke(_buffer, _restorePos, buffer_u8, 0x00);
    }
    else
    {
        buffer_resize(_buffer, buffer_get_size(_buffer)+1);
    }
    
    var _cellDelimiterOrd      = ord(_cellDelimiter);
    var _stringDelimiterDouble = _stringDelimiter + _stringDelimiter;
    var _stringDelimiterOrd    = ord(_stringDelimiter);
    
    var _rootArray = [];
    var _rowArray  = undefined;
    
    var _newline    = false;
    var _read       = false;
    var _wordStart  = 0;
    var _inString   = false;
    var _stringCell = false;
    
    repeat(_size+1)
    {
        var _value = buffer_read(_buffer, buffer_u8);
        
        if (_value == _stringDelimiterOrd)
        {
            _inString = !_inString;
            if (_inString) _stringCell = true;
        }
        else
        {
            if (_value == 0x00)
            {
                if (_inString) _stringCell = true;
                _inString = false;
                
                var _prev_value = buffer_peek(_buffer, buffer_tell(_buffer)-2, buffer_u8);
                if ((_prev_value != _cellDelimiterOrd) && (_prev_value != 0x0A) && (_prev_value != 0x0D))
                {
                    _read = true;
                }
                else
                {
                    break;
                }
            }
            
            if (!_inString)
            {
                if ((_value == 0x0A) || (_value == 0x0D))
                {
                    var _prev_value = buffer_peek(_buffer, buffer_tell(_buffer)-2, buffer_u8);
                    if ((_prev_value != 0x0A) && (_prev_value != 0x0D))
                    {
                        _newline = true;
                        if (_prev_value != _cellDelimiterOrd)
                        {
                            _read = true;
                        }
                        else
                        {
                            ++_wordStart;
                        }
                    }
                    else
                    {
                        ++_wordStart;
                    }
                }
            
                if (_read || (_value == _cellDelimiterOrd))
                {
                    _read = false;
                    
                    var _tell = buffer_tell(_buffer);
                    var _old_value = buffer_peek(_buffer, _tell-1, buffer_u8);
                    buffer_poke(_buffer, _tell-1, buffer_u8, 0x00);
                    buffer_seek(_buffer, buffer_seek_start, _wordStart);
                    var _string = buffer_read(_buffer, buffer_string);
                    buffer_poke(_buffer, _tell-1, buffer_u8, _old_value);
                    
                    if (_stringCell)
                    {
                        if ((string_byte_at(_string, 1) == _stringDelimiterOrd)
                        &&  (string_byte_at(_string, string_byte_length(_string)) == _stringDelimiterOrd))
                        {
                            _string = string_copy(_string, 2, string_length(_string)-2); //Trim off leading/trailing quote marks
                        }
                    }
                    
                    _string = string_replace_all(_string, _stringDelimiterDouble, _stringDelimiter); //Replace double quotes with single quotes
                    
                    if (_rowArray == undefined)
                    {
                        _rowArray = [];
                        _rootArray[@ array_length(_rootArray)] = _rowArray;
                    }
                    
                    _rowArray[@ array_length(_rowArray)] = _string;
                    
                    _stringCell = false;
                    _wordStart = _tell;
                    
                    if (_value == 0x00) break;
                }
            
                if (_newline)
                {
                    _newline = false;
                    _rowArray = undefined;
                }
            }
        }
    }
    
    if (_restoreByte == undefined)
    {
        buffer_resize(_buffer, buffer_get_size(_buffer)-1);
    }
    else
    {
        buffer_poke(_buffer, _restorePos, buffer_u8, _restoreByte);
    }
    
    if (_inOffset != undefined)
    {
        buffer_seek(_buffer, buffer_seek_start, _oldOffset);
    }
    
    return _rootArray;
}
