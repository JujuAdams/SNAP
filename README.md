<h1 align="center">SNAP: Struct N' Array Parser 2.2.0</h1>

<p align="center">Replacement for ds_map/ds_list-based encoding/decoding</p>

<p align="center"><a href="https://github.com/JujuAdams/SNAP/releases/tag/2.0.0">Download the .yymps here</a></p>

&nbsp;

-----

&nbsp;

### foreach(struct/array, function) ###

Executes a function call for each element of the given `struct/array`. This iterator is shallow and will not also iterate over nested structs/arrays (though you can of course call `foreach` inside the specified `function`). `function` is passed the following parameters:

```GML
 arg0   -  Value found in the given struct/array
 arg1   -  0-indexed index of the value e.g. =0 for the first element, =1 for the second element etc.
[arg2]  -  When iterating over structs, this is the name of the variable that contains the given value
```

The order that values are sent into `function` is guaranteed for arrays (starting at index 0 and ascending), but is not guaranteed for structs due to the behaviour of GameMaker's internal hashmap. `function` is called in the scope of the instance/struct that calls `foreach()`.

&nbsp;

### snap_deep_copy(struct/array)

Returns a copy of the given `struct/array`, including a copy of any nested structs and arrays.

&nbsp;

### snap_to_json_string(struct/array, [pretty], [alphabetizeStructs]) ###

Turns struct and array nested data into a JSON string. The root data type can be either a struct or an array. Setting `[pretty]` to `true` will format the JSON string in a more pleasing human-readable way, whereas setting `[alphabetizeStructs]` to `true` will output the struct variables in ascending alphabetical order. Using pretty and/or alphabetized output does incur a performance penalty.

&nbsp;

### snap_from_json_string(string) ###

Decodes a JSON string into nested struct/array data. This function will happily ignore formatting whitespace and handles `\\`, `\"`, `\n`, `\r`, and `\t` escaped characters. Also supports `true`, `false`, and `null` values.

&nbsp;

### snap_to_binary(struct/array) ###

Returns a buffer that holds binary encoded struct and array nested data. The root data type can be either a struct or an array. This is substantially faster than `snap_to_json_string()`.

&nbsp;

### snap_from_binary(buffer, [offset], [size], [destroyBuffer]) ###

Unpacks binary encoded struct/array data. An `[offset]` and total `[size]` for the data within the buffer can be specified which is helpful for working with composite buffers. Set `[size]` to `-1` to use the entire size of the buffer. If `[destroyBuffer]` is set to `true` then the input buffer will be destroyed once the function has finished executing. This function is a lot faster than `snap_from_json_string()`.

&nbsp;

### snap_from_xml_string(string) ###

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

### snap_to_xml_string(struct/array, [alphabetizeStructs]) ###

Turns struct and array nested data into a XML string. The data must be structured as above in GML example for `snap_from_xml_string()`. Setting `[alphabetizeStructs]` to `true` will output child element in ascending alphabetical order. Using an alphabetized output incurs a performance penalty.

&nbsp;

### snap_difference(old, new)

Returns a data structure (itself made from structs/arrays) that describes the difference between the specified `old` and `new` struct/arrays.

&nbsp;

### snap_difference_apply(struct/array, differenceStruct)

Applies a difference delta structure created by `snap_difference()` to a struct/array.

**N.B.** Due to missing functionality in GMS2.3.0, array element and struct variable deletion is not fully functional. Instead, when an array element or struct variable is deleted, the value will be set to `undefined`.
