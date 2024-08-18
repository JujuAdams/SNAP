// Feather disable all

/// Adds a token to all future calls to SnapFromGML() and SnapBufferReadGML(). When evaluated, the
/// token will return the value set by this function. This is useful to carry across constants into
/// the GML parser e.g. the width and height of a tile in your game.
/// 
/// @param tokenName
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