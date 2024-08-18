// Feather disable all

/// @param token
/// @param value

function SnapEnvGMLSetToken(_token, _value)
{
    static _globalVariableStruct = __SnapEnvGML().__globalVariableStruct;
    
    _globalVariableStruct[$ _token] = method(
    {
        __value: _value,
    },
    function()
    {
        return __value;
    });
}