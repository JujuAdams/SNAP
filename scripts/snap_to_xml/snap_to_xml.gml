/// @return XML string that encodes the struct/array nested data
/// 
/// @param struct/array           The data to be encoded
/// @param [alphabetizeStructs]   (bool) Sorts struct variable names is ascending alphabetical order as per ds_list_sort(). Defaults to <false>
/// 
/// @jujuadams 2020-06-14

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
    
    static write_node = function(_element_name, _struct)
    {
        buffer_write(buffer, buffer_text, indent);
        buffer_write(buffer, buffer_text, "<");
        buffer_write(buffer, buffer_text, _element_name);
        
        var _attribute_struct = variable_struct_get(_struct, "_attr");
        if (is_struct(_attribute_struct))
        {
            var _names = variable_struct_get_names(_attribute_struct);
            var _count = array_length(_names);
            var _i = 0;
            repeat(_count)
            {
                var _key = _names[_i];
                buffer_write(buffer, buffer_text, " ");
                buffer_write(buffer, buffer_text, _key);
                buffer_write(buffer, buffer_text, "=\"");
                buffer_write(buffer, buffer_text, string(variable_struct_get(_attribute_struct, _key)));
                buffer_write(buffer, buffer_text, "\"");
                ++_i;
            }
        }
        
        buffer_write(buffer, buffer_text, ">");
        
        var _names = variable_struct_get_names(_struct);
        var _count = array_length(_names);
        
        var _content = variable_struct_get(_struct, "_text");
        if (_content != undefined)
        {
            buffer_write(buffer, buffer_text, string(_content));
        }
        else if (_count > 0)
        {
            if (alphabetise)
            {
                var _list = ds_list_create();
            
                var _i = 0;
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
            }
            
            var _old_indent = indent;
            indent += "    ";
            var _i = 0;
            repeat(_count)
            {
                var _key = _names[_i];
                
                if ((_key != "_attr") && (_key != "_text"))
                {
                    var _value = variable_struct_get(_struct, _key);
                    
                    if (is_struct(_value))
                    {
                        buffer_write(buffer, buffer_u8, 13);
                        write_node(_key, _value);
                    }
                    else if (is_array(_value))
                    {
                        var _j = 0;
                        repeat(array_length(_value))
                        {
                            buffer_write(buffer, buffer_u8, 13);
                            write_node(_key, _value[_j]);
                            ++_j;
                        }
                    }
                }
                
                ++_i;
            }
            
            indent = _old_indent;
            buffer_write(buffer, buffer_u8, 13);
            buffer_write(buffer, buffer_text, indent);
        }
        
        buffer_write(buffer, buffer_text, "</");
        buffer_write(buffer, buffer_text, _element_name);
        buffer_write(buffer, buffer_text, ">");
    }
    
    var _prolog_struct = variable_struct_get(_ds, "_prolog");
    if (is_struct(_prolog_struct))
    {
        var _attribute_struct = variable_struct_get(_prolog_struct, "_attr");
        if (is_struct(_attribute_struct))
        {
            var _names = variable_struct_get_names(_attribute_struct);
            var _count = array_length(_names);
            if (_count > 0)
            {
                buffer_write(buffer, buffer_text, "<?xml");
                
                var _i = 0;
                repeat(_count)
                {
                    var _key = _names[_i];
                    buffer_write(buffer, buffer_text, " ");
                    buffer_write(buffer, buffer_text, _key);
                    buffer_write(buffer, buffer_text, "=\"");
                    buffer_write(buffer, buffer_text, string(variable_struct_get(_attribute_struct, _key)));
                    buffer_write(buffer, buffer_text, "\"");
                    ++_i;
                }
                
                buffer_write(buffer, buffer_text, "?>\n");
            }
        }
    }
    
    var _names = variable_struct_get_names(_ds);
    var _count = array_length(_names);
    var _i = 0;
    repeat(_count)
    {
        var _key = _names[_i];
        if (_key != "_prolog") write_node(_key, variable_struct_get(_ds, _key));
        ++_i;
    }
    
    buffer_seek(buffer, buffer_seek_start, 0);
    result = buffer_read(buffer, buffer_string);
    buffer_delete(buffer);
}