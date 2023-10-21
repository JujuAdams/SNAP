// Feather disable all
/// Recursively navigates over a nested struct/array and writes the instanceof() value for structs
/// into a special value in the struct itself. This value can then be serialized with the rest of
/// the struct's non-static variables using a SNAP function or json_stringify() etc.  When
/// deserializing data, either using a SNAP function or json_parse(), you should reconstruct the
/// constructor for structs by calling SnapReconstructionUnpack().
/// 
/// If <unsetConstructor> is set to <true>, the constructor for structs is also cleared which is
/// handy to work around current (2023.8, 2023-10-21) bugs in json_stringify(). You will need to
/// restore the instanceof() value using SnapReconstructionUnpack() if you intend to keep using
/// static variables/methods in these structs.
/// 
///   N.B. There are significant limitations to what constructors can be serialized. This is mostly
///        to avoid unpleasant situations where it's not possible to deserialize. You cannot use
///        anonymous and/or non-global constructors with SnapReconstructionPack() as these cannot
///        be reliably resolved later on when using SnapReconstructionUnpack().
/// 
/// Intended use is:
///    
///    //On save
///    SnapReconstructionPack(jsonToSave);
///    SnapStringToFile(SnapToJSON(jsonToSave, "filename.txt"));
///    SnapReconstructionCleanUp(jsonToSave);
///
///    //On load
///    loadedJson = SnapFromJSON(SnapStringFromFile("filename.txt"));
///    SnapReconstructionCleanUp(loadedJson);
/// 
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