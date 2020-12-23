/// @return GML string that encodes the struct
/// 
/// @param struct                The struct to be encoded. Can contain structs, arrays, strings, and numbers (but the root must be a struct).   N.B. Will not encode ds_list, ds_map etc.
/// @param [alphabetizeStructs]  (bool) Sorts struct variable names is ascending alphabetical order as per ds_list_sort(). Defaults to <false>
/// 
/// @jujuadams 2020-12-23

//In the general case, functions/methods cannot be deserialised so we default to preventing their serialisation to begin with
//If you'd like to throw an error whenever this function tries to serialise a function/method, set SNAP_GML_SERIALISE_FUNCTION_NAMES to -1
//If you'd like to simply ignore functions/methods when serialising structs/arrays, set SNAP_GML_SERIALISE_FUNCTION_NAMES to 0
//If you'd like to use some clever tricks to deserialise functions/methods in a manner specific to your game, set SNAP_GML_SERIALISE_FUNCTION_NAMES to 1
#macro SNAP_GML_SERIALISE_FUNCTION_NAMES  -1

function snap_to_gml()
{
    var _ds          = argument[0];
    var _alphabetise = ((argument_count > 1) && (argument[1] != undefined))? argument[1] : false;
    
    return (new __snap_to_gml_parser(_ds, _alphabetise)).result;
}

function __snap_to_gml_parser(_ds, _alphabetise) constructor
{
    root        = _ds;
    alphabetise = _alphabetise;
    depth       = 0;
    
    result = "";
    buffer = buffer_create(1024, buffer_grow, 1);
    indent = "";
    
    static parse_struct = function(_struct)
    {
        var _names = variable_struct_get_names(_struct);
        var _count = array_length(_names);
        var _i = 0;
        
        if (alphabetise)
        {
            var _list = ds_list_create();
            
            repeat(_count)
            {
                _list[| _i] = _names[_i];
                ++_i;
            }
            
            ds_list_sort(_list, true);
            
            var _i = 0;
            repeat(_count)
            {
                _names[@ _i] = _list[| _i];
                ++_i;
            }
            
            ds_list_destroy(_list);
            var _i = 0;
        }
        
        if (_count > 0)
        {
            if (depth != 0)
            {
                buffer_write(buffer, buffer_text, "{\n");
                indent += "    ";
            }
            
            var _written = false;
            repeat(_count)
            {
                var _name = _names[_i];
                value = variable_struct_get(_struct, _name);
                
                if (!is_method(value) || (SNAP_GML_SERIALISE_FUNCTION_NAMES != 0))
                {
                    if (is_struct(_name) || is_array(_name))
                    {
                        show_error("Key type \"" + typeof(_name) + "\" not supported\n ", false);
                        _name = string(ptr(_name));
                    }
                    
                    if (depth == 0)
                    {
                        buffer_write(buffer, buffer_text, indent);
                        buffer_write(buffer, buffer_text, string(_name));
                        buffer_write(buffer, buffer_text, " = ");
                        write_value();
                        buffer_write(buffer, buffer_text, ";\n");
                    }
                    else
                    {
                        buffer_write(buffer, buffer_text, indent);
                        buffer_write(buffer, buffer_text, string(_name));
                        buffer_write(buffer, buffer_text, " : ");
                        write_value();
                        buffer_write(buffer, buffer_text, ",\n");
                    }
                    
                    _written = true;
                }
                
                ++_i;
            }
            
            if (depth != 0)
            {
                indent = string_copy(indent, 1, string_length(indent) - 4);
                if (_written) buffer_seek(buffer, buffer_seek_relative, -2);
                buffer_write(buffer, buffer_text, "\n" + indent + "}");
            }
        }
        else
        {
            buffer_write(buffer, buffer_text, "{}");
        }
    }
    
    
    
    static parse_array = function(_array)
    {
        var _count = array_length(_array);
        var _i = 0;
        
        if (_count > 0)
        {
            indent += "    ";
            buffer_write(buffer, buffer_text, "[\n");
            
            repeat(_count)
            {
                value = _array[_i];
                
                buffer_write(buffer, buffer_text, indent);
                write_value();
                buffer_write(buffer, buffer_text, ",\n");
                    
                ++_i;
            }
            
            indent = string_copy(indent, 1, string_length(indent) - 4);
            buffer_seek(buffer, buffer_seek_relative, -2);
            buffer_write(buffer, buffer_text, "\n" + indent + "]");
        }
        else
        {
            buffer_write(buffer, buffer_text, "[]");
        }
    }
    
    
    
    static write_value = function()
    {
        if (is_struct(value))
        {
            depth++;
            parse_struct(value);
            depth--;
        }
        else if (is_array(value))
        {
            depth++;
            parse_array(value);
            depth--;
        }
        else if (is_string(value))
        {
            //Sanitise strings
            value = string_replace_all(value, "\\", "\\\\");
            value = string_replace_all(value, "\n", "\\n");
            value = string_replace_all(value, "\r", "\\r");
            value = string_replace_all(value, "\t", "\\t");
            value = string_replace_all(value, "\"", "\\\"");
            
            buffer_write(buffer, buffer_text, "\"");
            buffer_write(buffer, buffer_text, value);
            buffer_write(buffer, buffer_text, "\"");
        }
        else if (is_undefined(value))
        {
            buffer_write(buffer, buffer_text, "undefined");
        }
        else if (is_bool(value))
        {
            buffer_write(buffer, buffer_text, value? "true" : "false");
        }
        else if (is_real(value))
        {
            //Strip off trailing zeroes, and if necessary, the decimal point too
            value = string_format(value, 0, 10);
            
            var _length = string_length(value);
            var _i = _length;
            repeat(_length)
            {
                if (string_char_at(value, _i) != "0") break;
                --_i;
            }
            
            if (string_char_at(value, _i) == ".") _i--;
            
            value = string_delete(value, _i + 1, _length - _i);
            
            buffer_write(buffer, buffer_text, value);
        }
        else if (is_method(value))
        {
            if (SNAP_GML_SERIALISE_FUNCTION_NAMES <= 0)
            {
                if (SNAP_GML_SERIALISE_FUNCTION_NAMES < 0) show_error("Functions/methods cannot be serialised\n(Please edit macro SNAP_GML_SERIALISE_FUNCTION_NAMES to change this behaviour)\n ", true);
                buffer_write(buffer, buffer_text, "undefined");
            }
            else
            {
                buffer_write(buffer, buffer_text, "\"");
                buffer_write(buffer, buffer_text, string(value));
                buffer_write(buffer, buffer_text, "\"");
            }
        }
        else
        {
            buffer_write(buffer, buffer_text, string(value));
        }
    }
    
    
    
    if (is_struct(root))
    {
        parse_struct(root);
    }
    else
    {
        show_error("Value not a struct. Returning empty string\n ", false);
    }
    
    
    
    buffer_seek(buffer, buffer_seek_start, 0);
    result = buffer_read(buffer, buffer_string);
    buffer_delete(buffer);
}