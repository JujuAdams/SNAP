// Feather disable all
/// Config struct should be in this format:
/// 
/// {
///     columnTitle: {
///         ignore: <true> or <false>,
///         numeric: <true> or <false>,
///     },
///     ...
/// }
/// 
/// @param inputArray       2D array to convert. Array should be row-major
/// @param [configStruct]   See above
/// 
/// @jujuadams 2022-10-30

function Snap2DArrayToStructArray(_inputArray, _configStruct = {})
{
    var _outputArray = array_create(array_length(_inputArray)-1);
    var _headerArray = _inputArray[0];
    
    var _ignore  = false;
    var _numeric = false;
    
    var _i = 1;
    repeat(array_length(_inputArray)-1)
    {
        var _struct = {};
        _outputArray[@ _i-1] = _struct;
        
        var _subArray = _inputArray[_i];
        var _j = 0;
        repeat(array_length(_subArray))
        {
            var _value        = _subArray[_j];
            var _variableName = _headerArray[_j];
            
            var _config = _configStruct[$ _variableName];
            if (is_struct(_config))
            {
                _ignore  = _config[$ "ignore" ] ?? false;
                _numeric = _config[$ "numeric"] ?? false;
            }
            
            if (_numeric)
            {
                _numeric = false;
                try { _value = real(_value); } catch(_error) {}
            }
            
            if (_ignore)
            {
                _ignore = false;
            }
            else
            {
                _struct[$ _variableName] = _value;
            }
            
            ++_j;
        }
        
        ++_i;
    }
    
    return _outputArray;
}
