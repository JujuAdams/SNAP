<h1 align="center">SNAP: Struct N' Array Parser 3.0.0</h1>

<p align="center">Replacement for ds_map/ds_list-based encoding/decoding</p>

<p align="center"><a href="https://github.com/JujuAdams/SNAP/releases/tag/2.0.0">Download the .yymps here</a></p>

&nbsp;

Functions included are:

1. `foreach(struct/array, method, [dsType])`
2. `snap_deep_copy(struct/array)`
3. `snap_to_json(struct/array, [pretty], [alphabetizeStructs])`
4. `snap_from_json(string)`
5. `snap_to_binary(struct/array)`
6. `snap_from_binary(buffer, [offset], [size], [destroyBuffer])`
7. `snap_from_xml(string)`
8. `snap_to_xml(struct/array, [alphabetizeStructs])`

-----

&nbsp;

### foreach(struct/array/ds, method, [dsType]) ###

Executes a function call for each element of the given `struct/array`. This iterator is shallow and will not also iterate over nested structs/arrays (though you can of course call `foreach` inside the specified method). This function can also iterate over all members of a ds_map, ds_list, or ds_grid - you will need to specify a value for `[dsType]` to iterate over a data structure.

`function` is passed the following parameters:
```GML
 arg0   -  Value found in the given struct/array
 arg1   -  0-indexed index of the value e.g. =0 for the first element, =1 for the second element etc.
 arg2   -  When iterating over structs, the name of the variable that contains the given value; otherwise <undefined>
```

The order that values are sent into `method` is guaranteed for arrays (starting at index 0 and ascending), but is not guaranteed for structs due to the behaviour of GameMaker's internal hashmap.

&nbsp;

### snap_deep_copy(struct/array)

Returns a copy of the given `struct/array`, including a copy of any nested structs and arrays.

&nbsp;

### snap_to_json(struct/array, [pretty], [alphabetizeStructs]) ###

Turns struct and array nested data into a JSON string. The root data type can be either a struct or an array. Setting `[pretty]` to `true` will format the JSON string in a more pleasing human-readable way, whereas setting `[alphabetizeStructs]` to `true` will output the struct variables in ascending alphabetical order. Using pretty and/or alphabetized output does incur a performance penalty.

&nbsp;

### snap_from_json(string) ###

Decodes a JSON string into nested struct/array data. This function will happily ignore formatting whitespace and handles `\\`, `\"`, `\n`, `\r`, and `\t` escaped characters. Also supports `true`, `false`, and `null` values.

&nbsp;

### snap_to_binary(struct/array) ###

Returns a buffer that holds binary encoded struct and array nested data. The root data type can be either a struct or an array. This is substantially faster than `snap_to_json()`.

&nbsp;

### snap_from_binary(buffer, [offset], [size], [destroyBuffer]) ###

Unpacks binary encoded struct/array data. An `[offset]` and total `[size]` for the data within the buffer can be specified which is helpful for working with composite buffers. Set `[size]` to `-1` to use the entire size of the buffer. If `[destroyBuffer]` is set to `true` then the input buffer will be destroyed once the function has finished executing. This function is a lot faster than `snap_from_json_string()`.

&nbsp;

### snap_from_xml(string) ###

Decodes a XML string into nested struct/array data. Each XML element is  struct. Element attributes are stored inside a sub-struct called `_attr`. Child elements are stored using their name as the member variable name in the parent. If more than one element with the same name exists then they are put into an array. If an element's content is a string then it is stored under the member variable `_text`. If an element has neither attributes nor children nor content then it is stored as an empty struct. The XML prolog is stored in a struct in the root struct under the member variable `_prolog`.

This is a bit wordy, so here's an example. The following XML and struct/array literal are interchangable:

```XML
<root halign="left" valign="top">
    <text>Hello World!</text>
    <button url="http://www.jujuadams.com/">Click me!</button>
    <button url="http://www.spiderlili.com/">Or me!</button>
    <empty_tag></empty_tag>
</root>
```

```GML
{
    root : {
        _attr : {
            halign : "left",
            valign : "top",
        },
        text : {
            _text : "Hello World!"
        },
        button : [
            {
                _attr : {
                    url   : "http://www.jujuadams.com/
                },
                _text : "Click me!"
            },
            {
                _attr : {
                    url   : "http://www.spiderlili.com/
                },
                text : "Or me!"
            }
        ],
        empty_tag : {}
     }
 }
```

&nbsp;

### snap_to_xml(struct/array, [alphabetizeStructs]) ###

Turns struct and array nested data into a XML string. The data must be structured as above in GML example for `snap_from_xml()`. Setting `[alphabetizeStructs]` to `true` will output child element in ascending alphabetical order. Using an alphabetized output incurs a performance penalty.