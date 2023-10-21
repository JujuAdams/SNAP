// Feather disable all
/// Recursively navigates over a nested struct/array and restores instanceof() values for structs
/// based on the value of a special variable in each struct. These special variables are set by the
/// companion function SnapReconstructionPack().
/// 
/// If <unsetConstructor> is set to <false>, the special variable used to store the instanceof()
/// value for each struct will be maintained rather than deleted.
/// 
///   N.B. You cannot use anonymous and/or non-global constructors with SnapReconstructionPack()
///        as these cannot be reliably resolved.
/// 
/// @param value
/// @param [instanceofVariableName="__instanceof__"]
/// @param [cleanUp=true]

function SnapReconstructionUnpack(_value, _instanceofVariableName = "__instanceof__", _cleanUp = true)
{
    try
    {
        static_get(SnapReconstructionUnpack);
    }
    catch(_error)
    {
        show_error("SNAP:\nSnapReconstructionUnpack() not supported\nPlease update to a version of GameMaker with native function static_get()\n ", true); 
    }
    
    __SnapReconstructionUnpackInner(_value, _instanceofVariableName, _cleanUp);
}

function __SnapReconstructionUnpackInner(_value, _instanceofVariableName, _cleanUp)
{
    if (is_array(_value))
    {
        var _i = 0;
        repeat(array_length(_value))
        {
            __SnapReconstructionUnpackInner(_value[_i], _instanceofVariableName, _cleanUp);
            ++_i;
        }
    }
    else if (is_method(_value))
    {
        //Ignore
    }
    else if (is_struct(_value))
    {
        var _instanceof = _value[$ _instanceofVariableName];
        if (_instanceof != undefined)
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
                static_set(_value, static_get(_asset));
            }
        }
        
        if (_cleanUp) variable_struct_remove(_value, _instanceofVariableName);
        
        var _namesArray = variable_struct_get_names(_value);
        var _i = 0;
        repeat(array_length(_namesArray))
        {
            __SnapReconstructionUnpackInner(_value[$ _namesArray[_i]], _instanceofVariableName, _cleanUp);
            ++_i;
        }
    }
}