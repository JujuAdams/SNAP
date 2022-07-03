/// @return JSON string that encodes the struct/array nested data
/// 
/// @param struct/array          The data to be encoded. Can contain structs, arrays, strings, and numbers.   N.B. Will not encode ds_list, ds_map etc.
/// @param [pretty]              (bool) Whether to format the string to be human readable. Defaults to <false>
/// @param [alphabetizeStructs]  (bool) Sorts struct variable names is ascending alphabetical order as per ds_list_sort(). Defaults to <false>
/// 
/// @jujuadams 2022-07-03

//In the general case, functions/methods cannot be deserialised so we default to preventing their serialisation to begin with
//If you'd like to throw an error whenever this function tries to serialise a function/method, set SNAP_JSON_SERIALISE_FUNCTION_NAMES to -1
//If you'd like to simply ignore functions/methods when serialising structs/arrays, set SNAP_JSON_SERIALISE_FUNCTION_NAMES to 0
//If you'd like to use some clever tricks to deserialise functions/methods in a manner specific to your game, set SNAP_JSON_SERIALISE_FUNCTION_NAMES to 1
#macro SNAP_JSON_SERIALISE_FUNCTION_NAMES  -1

function snap_to_json()
{
    var _ds          = argument[0];
    var _pretty      = ((argument_count > 1) && (argument[1] != undefined))? argument[1] : false;
    var _alphabetise = ((argument_count > 2) && (argument[2] != undefined))? argument[2] : false;
    
    return (new __snap_to_json_parser(_ds, _pretty, _alphabetise)).result;
}

function __snap_to_json_parser(_ds, _pretty, _alphabetise) constructor
{
    root        = _ds;
    pretty      = _pretty;
    alphabetise = _alphabetise;
    
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
        
        if (pretty)
        {
            if (_count > 0)
            {
                buffer_write(buffer, buffer_text, "{\n");
                indent += "    ";
                
                var _written = false;
                repeat(_count)
                {
                    var _name = _names[_i];
                    value = variable_struct_get(_struct, _name);
                    
                    if (!is_method(value) || (SNAP_JSON_SERIALISE_FUNCTION_NAMES != 0))
                    {
                        if (is_struct(_name) || is_array(_name))
                        {
                            show_error("Key type \"" + typeof(_name) + "\" not supported\n ", false);
                            _name = string(ptr(_name));
                        }
                        
                        buffer_write(buffer, buffer_text, indent + "\"");
                        buffer_write(buffer, buffer_text, string(_name));
                        buffer_write(buffer, buffer_text, "\" : ");
                        
                        write_value();
                        
                        buffer_write(buffer, buffer_text, ",\n");
                        _written = true;
                    }
                    
                    ++_i;
                }
                
                indent = string_copy(indent, 1, string_length(indent) - 4);
                if (_written) buffer_seek(buffer, buffer_seek_relative, -2);
                buffer_write(buffer, buffer_text, "\n" + indent + "}");
            }
            else
            {
                buffer_write(buffer, buffer_text, "{}");
            }
        }
        else
        {
            buffer_write(buffer, buffer_text, "{");
            
            var _written = false;
            repeat(_count)
            {
                var _name = _names[_i];
                value = variable_struct_get(_struct, _name);
                
                if (!is_method(value) || (SNAP_JSON_SERIALISE_FUNCTION_NAMES != 0))
                {
                    if (is_struct(_name) || is_array(_name))
                    {
                        show_error("Key type \"" + typeof(_name) + "\" not supported\n ", false);
                        _name = string(ptr(_name));
                    }
                    
                    buffer_write(buffer, buffer_text, "\"");
                    buffer_write(buffer, buffer_text, string(_name));
                    buffer_write(buffer, buffer_text, "\":");
                    
                    write_value();
                    
                    buffer_write(buffer, buffer_text, ",");
                    _written = true;
                }
                
                ++_i;
            }
            
            if (_written) buffer_seek(buffer, buffer_seek_relative, -1);
            buffer_write(buffer, buffer_text, "}");
        }
    }
    
    
    
    static parse_array = function(_array)
    {
        var _count = array_length(_array);
        var _i = 0;
        
        if (pretty)
        {
            if (_count > 0)
            {
                buffer_write(buffer, buffer_text, "[\n");
                indent += "    ";
                
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
        else
        {
            buffer_write(buffer, buffer_text, "[");
            
            repeat(_count)
            {
                value = _array[_i];
                
                write_value();
                buffer_write(buffer, buffer_text, ",");
                
                ++_i;
            }
            
            if (_count > 0) buffer_seek(buffer, buffer_seek_relative, -1);
            buffer_write(buffer, buffer_text, "]");
        }
    }
    
    
    
    static write_value = function()
    {
        if (is_real(value))
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
        else if (is_array(value))
        {
            parse_array(value);
        }
        else if (is_method(value)) //Implicitly also a struct so we have to check this first
        {
            if (SNAP_JSON_SERIALISE_FUNCTION_NAMES <= 0)
            {
                if (SNAP_JSON_SERIALISE_FUNCTION_NAMES < 0) show_error("Functions/methods cannot be serialised\n(Please edit macro SNAP_JSON_SERIALISE_FUNCTION_NAMES to change this behaviour)\n ", true);
                buffer_write(buffer, buffer_text, "null");
            }
            else
            {
                buffer_write(buffer, buffer_text, "\"");
                buffer_write(buffer, buffer_text, string(value));
                buffer_write(buffer, buffer_text, "\"");
            }
        }
        else if (is_struct(value))
        {
            parse_struct(value);
        }
        else if (is_undefined(value))
        {
            buffer_write(buffer, buffer_text, "null");
        }
        else if (is_bool(value))
        {
            buffer_write(buffer, buffer_text, value? "true" : "false");
        }
        else if (is_ptr(value))
        {
            buffer_write(buffer, buffer_text, "\"");
            buffer_write(buffer, buffer_text, string(value));
            buffer_write(buffer, buffer_text, "\"");
        }
        else
        {
            // YoYoGames in their finite wisdom added a new datatype in GMS2022.5 that doesn't stringify nicely
            //     string(instance.id) = "ref 100001"
            // This means we end up writing a string with a space in it to JSON. This is leads to invalid output
            // We can check <typeof(id) == "ref"> but string comparison is slow and gross
            // 
            // Instance IDs have the following detectable characteristics:
            // typeof(value)       = "ref"
            // is_array(value)     = false  *
            // is_bool(value)      = false  *
            // is_infinity(value)  = false
            // is_int32(value)     = false
            // is_int64(value)     = false
            // is_method(value)    = false  *
            // is_nan(value)       = false
            // is_numeric(value)   = true
            // is_ptr(value)       = false  *
            // is_real(value)      = false  *
            // is_string(value)    = false  *
            // is_struct(value)    = false  *
            // is_undefined(value) = false  *
            // is_vec3(value)      = false  *  (covered by is_array())
            // is_vec4(value)      = false  *  (covered by is_array())
            // 
            // Up above we've already tested the datatypes marked with asterisks
            // We can fish out instance references by checking <is_numeric() == true> and then excluding int32 and int64 datatypes
            
            if (is_numeric(value) && !is_int32(value) && !is_int64(value))
            {
                buffer_write(buffer, buffer_text, string(real(value))); //Save the numeric component of the instance ID
            }
            else
            {
                buffer_write(buffer, buffer_text, string(value));
            }
        }
    }
    
    
    
    if (is_struct(root))
    {
        parse_struct(root);
    }
    else if (is_array(root))
    {
        parse_array(root);
    }
    else
    {
        show_error("Value not struct or array. Returning empty string\n ", false);
    }
    
    
    
    buffer_seek(buffer, buffer_seek_start, 0);
    result = buffer_read(buffer, buffer_string);
    buffer_delete(buffer);
}