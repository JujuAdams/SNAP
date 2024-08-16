// Feather disable all

/// @param variableName
/// @param value

function SnapEnvGMLSetVariable(_variable, _value)
{
    static _globalVariableStruct = __SnapEnvGML().__globalVariableStruct;
    
    _globalVariableStruct[$ _variable] = method(
    {
        __value: _value,
    },
    function()
    {
        return __value;
    });
}