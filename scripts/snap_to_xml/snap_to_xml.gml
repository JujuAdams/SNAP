/// @return XML string that encodes the struct/array nested data
/// 
/// @param struct/array    The data to be encoded
/// @param [alphabetize]   Optional, sorts struct attribute names in ascending alphabetical order. Defaults to <false>
/// 
/// @jujuadams 2020-07-21

//In the general case, functions/methods cannot be deserialised so we default to preventing their serialisation to begin with
//If you'd like to throw an error whenever this function tries to serialise a function/method, set SNAP_XML_SERIALISE_FUNCTION_NAMES to -1
//If you'd like to simply ignore functions/methods when serialising structs/arrays, set SNAP_XML_SERIALISE_FUNCTION_NAMES to 0
//If you'd like to use some clever tricks to deserialise functions/methods in a manner specific to your game, set SNAP_XML_SERIALISE_FUNCTION_NAMES to 1
#macro SNAP_XML_SERIALISE_FUNCTION_NAMES  -1

function snap_to_xml()
{
    var _ds          = argument[0];
    var _alphabetise = ((argument_count > 1) && (argument[1] != undefined))? argument[1] : false;
    
    return (new __snap_to_xml_parser(_ds, _alphabetise)).result;
}

function __snap_to_xml_parser(_ds, _alphabetise) constructor
{
    alphabetise = _alphabetise;
    
    result = "";
    buffer = buffer_create(1024, buffer_grow, 1);
    indent = "";
    
    static write_node = function(_struct)
    {
        buffer_write(buffer, buffer_text, indent);
        buffer_write(buffer, buffer_text, "<");
        buffer_write(buffer, buffer_text, _struct.type);
        
        var _attribute_struct = _struct[$ "attributes"];
        if (is_struct(_attribute_struct))
        {
            var _names = variable_struct_get_names(_attribute_struct);
            if (alphabetise) array_sort(_names, lb_sort_ascending);
            
            var _i = 0;
            repeat(array_length(_names))
            {
                var _key = _names[_i];
                var _value = _attribute_struct[$ _key];
                
                if (!is_method(_value) || (SNAP_XML_SERIALISE_FUNCTION_NAMES > 0))
                {
                    buffer_write(buffer, buffer_text, " ");
                    buffer_write(buffer, buffer_text, _key);
                    buffer_write(buffer, buffer_text, "=\"");
                    buffer_write(buffer, buffer_text, string(_value));
                    buffer_write(buffer, buffer_text, "\"");
                }
                else if (SNAP_XML_SERIALISE_FUNCTION_NAMES < 0)
                {
                    show_error("Functions/methods cannot be serialised\n(Please edit macro SNAP_XML_SERIALISE_FUNCTION_NAMES to change this behaviour)\n ", true);
                }
                
                ++_i;
            }
        }
        
        buffer_write(buffer, buffer_text, ">");
        
        var _content = _struct[$ "text"];
        if (_content != undefined)
        {
            buffer_write(buffer, buffer_text, string(_content));
        }
        else
        {
            var _children = _struct[$ "children"];
            if (is_array(_children))
            {
                var _count = array_length(_children);
                if (_count > 0)
                {
                    var _old_indent = indent;
                    indent += "    ";
                    
                    var _i = 0;
                    repeat(_count)
                    {
                        buffer_write(buffer, buffer_u8, 13);
                        write_node(_children[_i]);
                        ++_i;
                    }
                    
                    indent = _old_indent;
                    buffer_write(buffer, buffer_u8, 13);
                    buffer_write(buffer, buffer_text, indent);
                }
            }
        }
        
        buffer_write(buffer, buffer_text, "</");
        buffer_write(buffer, buffer_text, _struct.type);
        buffer_write(buffer, buffer_text, ">");
    }
    
    
    
    var _prolog_struct = _ds[$ "prolog"];
    if (is_struct(_prolog_struct))
    {
        var _attribute_struct = _prolog_struct[$ "attributes"];
        if (is_struct(_attribute_struct))
        {
            var _names = variable_struct_get_names(_attribute_struct);
            if (alphabetise) array_sort(_names, lb_sort_ascending);
            
            var _count = array_length(_names);
            if (_count > 0)
            {
                buffer_write(buffer, buffer_text, "<?xml");
                
                var _i = 0;
                repeat(_count)
                {
                    var _key = _names[_i];
                    var _value = _attribute_struct[$ _key];
                    
                    if (!is_method(_value) || (SNAP_XML_SERIALISE_FUNCTION_NAMES > 0))
                    {
                        buffer_write(buffer, buffer_text, " ");
                        buffer_write(buffer, buffer_text, _key);
                        buffer_write(buffer, buffer_text, "=\"");
                        buffer_write(buffer, buffer_text, string(_value));
                        buffer_write(buffer, buffer_text, "\"");
                    }
                    else if (SNAP_XML_SERIALISE_FUNCTION_NAMES < 0)
                    {
                        show_error("Functions/methods cannot be serialised\n(Please edit macro SNAP_XML_SERIALISE_FUNCTION_NAMES to change this behaviour)\n ", true);
                    }
                    
                    ++_i;
                }
                
                buffer_write(buffer, buffer_text, "?>\n");
            }
        }
    }
    
    
    
    var _children = _ds[$ "children"];
    if (is_array(_children))
    {
        var _i = 0;
        repeat(array_length(_children))
        {
            write_node(_children[_i]);
            ++_i;
        }
    }
    
    
    
    buffer_seek(buffer, buffer_seek_start, 0);
    result = buffer_read(buffer, buffer_string);
    buffer_delete(buffer);
}