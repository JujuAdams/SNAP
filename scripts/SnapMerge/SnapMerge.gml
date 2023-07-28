// Feather disable all
/// @returm N/A (undefined)
/// 
/// This function is designed to merge one simple tree-like structures into another. Values from the source tree are copied
/// into the destination tree recursively. Values from the source will overwrite values in the destination, but any values
/// that are present in the destination but not the source will be maintained. In situations where there is a datatype
/// conflict, the <resolveToSource> argument will determine which way data is copied.
/// 
/// N.B. Structs and arrays are copied by reference. If you wish to ensure that structs and arrays copied to the destination
///      are fresh copies, first use SnapDeepCopy() on the source.
/// 
/// @param source                   Source struct/array
/// @param destination              Destination struct/array
/// @param [resolveToSource=false]  Whether to prefer the source or the destination if there is a datatype conflict
/// 
/// @jujuadams 2022-10-30

function SnapMerge(_src, _dst, _resolveToSource = false)
{
    if (is_struct(_dst))
    {
        if (!is_struct(_src))
        {
            show_error("SNAP:\nRoot destination data structure is a struct but source is not (typeof=" + typeof(_src) + ")", true);
        }
    }
    else if (is_array(_dst))
    {
        if (!is_array(_src))
        {
            show_error("SNAP:\nRoot destination data structure is an array but source is not (typeof=" + typeof(_src) + ")", true);
        }
    }
    else
    {
        show_error("SNAP:\nRoot destination data structure is not a struct or an array", true);
    }
    
    __SnapMerge(_src, _dst, _resolveToSource);
}

function __SnapMerge(_src, _dst, _resolveToSource)
{
    if (is_struct(_src))
    {
        if (!is_struct(_dst))
        {
            return _resolveToSource? _src : _dst;
        }
        else
        {
            var _srcNames = variable_struct_get_names(_src);
            var _i = 0;
            repeat(array_length(_srcNames))
            {
                var _name = _srcNames[_i];
                var _srcValue = _src[$ _name];
                
                //Don't erroneously copy <undefined> from unfound member variables
                if (variable_struct_exists(_dst, _name))
                {
                    _dst[$ _name] = __SnapMerge(_srcValue, _dst[$ _name], _resolveToSource);
                }
                else
                {
                    _dst[$ _name] = _srcValue;
                }
                
                ++_i;
            }
            
            return _dst;
        }
    }
    else if (is_array(_src))
    {
        if (!is_array(_dst))
        {
            return _resolveToSource? _src : _dst;
        }
        else
        {
            var _srcLength = array_length(_src);
            var _dstLength = array_length(_dst);
            if (_dstLength < _srcLength) array_resize(_dst, _srcLength);
            
            var _i = 0;
            repeat(_srcLength)
            {
                _dst[@ _i] = __SnapMerge(_src[_i], _dst[_i], _resolveToSource);
                ++_i;
            }
            
            return _dst;
        }
    }
    else
    {
        return _src;
    }
}
