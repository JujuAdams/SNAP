// Feather disable all

/// @param token
/// @param function
/// @param [metadata=undefined]

function SnapEnvGMLSetTokenFunction(_token, _function, _metadata = undefined)
{
    static _globalVariableStruct = __SnapEnvGML().__globalVariableStruct;
    
    _globalVariableStruct[$ _token] = method(
    {
        __function: _function,
        __metadata: _metadata,
    },
    function()
    {
        return __function(__metadata);
    });
}