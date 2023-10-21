// Feather disable all

/// @param value
/// @param [instanceofVariableName="__instanceof__"]
/// @param [unsetConstructor=false]

function SnapReconstructionPack(_value, _instanceofVariableName = "__instanceof__", _unsetConstructor = false)
{
    try
    {
        static_get(SnapReconstructionPack);
    }
    catch(_error)
    {
        show_error("SNAP:\nSnapReconstructionPack() not supported\nPlease update to a version of GameMaker with native function static_get()\n ", true); 
    }
    
    __SnapReconstructionPackInner(_value, _instanceofVariableName, _unsetConstructor);
}

function __SnapReconstructionPackInner(_value, _instanceofVariableName, _unsetConstructor)
{
    if (is_array(_value))
    {
        var _i = 0;
        repeat(array_length(_value))
        {
            __SnapReconstructionPackInner(_value[_i], _instanceofVariableName, _unsetConstructor);
            ++_i;
        }
    }
    else if (is_method(_value))
    {
        //Ignore
    }
    else if (is_struct(_value))
    {
        var _instanceof = instanceof(_value);
        if (_instanceof != "struct")
        {
            var _asset = asset_get_index(_instanceof);
            if (_asset < 0)
            {
                show_error("SNAP:\nConstructor \"" + string(_instanceof) + "\" not found", true); 
            }
            else if (string_copy(_instanceof, 1, 5) == "anon_")
            {
                show_error("SNAP:\nConstructor \"" + string(_instanceof) + "\" not a globally scoped function, or has an invalid name", true); 
            }
            else
            {
                _value[$ _instanceofVariableName] = _instanceof;
            }
            
            if (_unsetConstructor) static_set(_value, {});
        }
        
        var _namesArray = variable_struct_get_names(_value);
        var _i = 0;
        repeat(array_length(_namesArray))
        {
            __SnapReconstructionPackInner(_value[$ _namesArray[_i]], _instanceofVariableName, _unsetConstructor);
            ++_i;
        }
    }
}