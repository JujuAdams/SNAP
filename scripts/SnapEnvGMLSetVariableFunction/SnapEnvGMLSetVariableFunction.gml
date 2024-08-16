// Feather disable all

/// @param variableName
/// @param function
/// @param [metadata=undefined]

function SnapEnvGMLSetVariableFunction(_variable, _function, _metadata = undefined)
{
    static _globalVariableStruct = __SnapEnvGML().__globalVariableStruct;
    
    _globalVariableStruct[$ _variable] = method(
    {
        __function: _function,
        __metadata: _metadata,
    },
    function()
    {
        return __function(__metadata);
    });
}