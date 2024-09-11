// Feather disable all
/// @returm Copy of the given struct/array, including a copy of any nested structs and arrays
/// 
/// This function is designed to copy simple tree-like structures that have been imported from SNAP functions.
/// It can be used in general to recursively copy struct/arrays. Be careful that your data doesn't have reference loops!
/// This function, unlike SnapDeepCopyLegacy(), will correctly copy constructor behaviour too
/// 
///   N.B. Sequences structs are not "real" structs in GameMaker and cannot be copied in their entirety.
/// 
/// @param struct/array   The struct/array to be copied
/// 
/// @jujuadams 2023-10-21

function SnapDeepCopy(_value)
{
    try
    {
        static_get(SnapDeepCopy);
    }
    catch(_error)
    {
        show_error("SNAP:\nSnapDeepCopy() not supported\nPlease update to a version of GameMaker with native function static_get()\nAlternatively, use SnapDeepCopyLegacy()\n ", true); 
    }
    
    return __SnapDeepCopyInner(_value, self, self);
}

function __SnapDeepCopyInner(_value, _oldStruct, _newStruct)
{
    var _copy = _value;
    
    if (is_method(_value))
    {
        var _self = method_get_self(_value);
        if (_self == _oldStruct)
        {
            //If this method is bound to the source struct, create a new method bound to the new struct
            _copy = method(_newStruct, method_get_index(_value));
        }
        else if (_self != undefined)
        {
            //If the scope of the method isn't <undefined> (global) then spit out a warning
            show_debug_message("SnapDeepCopy(): Warning! Deep copy found a method reference that could not be appropriately handled");
        }
    }
    else if (is_struct(_value))
    {
        var _namesArray = variable_struct_get_names(_value);
        var _copy = {};
        
        //Copy statics to replicate constructor behaviour
        static_set(_copy, static_get(_value));
        
        var _i = 0;
        repeat(array_length(_namesArray))
        {
            var _name = _namesArray[_i];
            _copy[$ _name] = __SnapDeepCopyInner(_value[$ _name], _value, _copy);
            ++_i;
        }
    }
    else if (is_array(_value))
    {
        var _count = array_length(_value);
        var _copy = array_create(_count);
        var _i = 0;
        repeat(_count)
        {
            _copy[@ _i] = __SnapDeepCopyInner(_value[_i], _oldStruct, _newStruct);
            ++_i;
        }
    }
    
    return _copy;
}
