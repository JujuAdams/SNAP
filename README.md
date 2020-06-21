<h1 align="center">SNAP: Struct N' Array Parser 3.2.0</h1>

<p align="center">Easy struct/array saving and loading</p>

<p align="center"><a href="https://github.com/JujuAdams/SNAP/releases/tag/2.0.0">Download the .yymps here</a></p>

&nbsp;

Functions included are:

1. `foreach(struct/array, method, [dsType])`
2. `snap_deep_copy(struct/array)`
3. `snap_to_json(struct/array, [pretty], [alphabetizeStructs])`
4. `snap_from_json(string)`
5. `snap_to_binary(struct/array)`
6. `snap_from_binary(buffer, [offset], [destroyBuffer])`
7. `snap_to_messagepack(struct/array)`
8. `snap_from_messagepack(buffer, [offset], [destroyBuffer])`
9. `snap_from_xml(string)`
10. `snap_to_xml(struct/array, [alphabetizeStructs])`
11. `snap_from_ini_string(string, [tryReal])`
12. `snap_from_ini_file(filename, [tryReal])`

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

Turns struct and array nested data into a JSON string. The root datatype can be either a struct or an array. Setting `[pretty]` to `true` will format the JSON string in a more pleasing human-readable way, whereas setting `[alphabetizeStructs]` to `true` will output the struct variables in ascending alphabetical order. Using pretty and/or alphabetized output does incur a performance penalty.

&nbsp;

### snap_from_json(string) ###

Decodes a JSON string into nested struct/array data. This function will happily ignore formatting whitespace and handles `\\`, `\"`, `\n`, `\r`, and `\t` escaped characters. Also supports `true`, `false`, and `null` values.

&nbsp;

### snap_to_binary(struct/array) ###

Returns a buffer that holds binary encoded struct and array nested data. The root datatype can be either a struct or an array. This is substantially faster than `snap_to_json()`.

&nbsp;

### snap_from_binary(buffer, [offset], [destroyBuffer]) ###

Unpacks binary encoded struct/array data. An `[offset]` for the data within the buffer can be specified which is helpful for working with composite buffers. If `[destroyBuffer]` is set to `true` then the input buffer will be destroyed once the function has finished executing. This function is a lot faster than `snap_from_json_string()`.

&nbsp;

### snap_to_messagepack(struct/array) ###

Returns a buffer that holds a binary representation of struct and array nested data according to the [messagepack](https://msgpack.org/index.html) specification. The root datatype can any datatype. This function is slower then the proprietary `snap_to_binary()`, but the [messagepack](https://msgpack.org/index.html) format is widely used and tends to output slightly smaller buffers.

&nbsp;

### snap_from_messagepack(buffer, [offset], [destroyBuffer]) ###

Unpacks [messagepack](https://msgpack.org/index.html) binary data into a struct/array data. An `[offset]` for the data within the buffer can be specified which is helpful for working with composite buffers. If `[destroyBuffer]` is set to `true` then the input buffer will be destroyed once the function has finished executing. `snap_from_messagepack()` is a little slower than `snap_from_binary()`.

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

&nbsp;

### snap_from_ini_string(string, [tryReal]) ###

Parses a string representation of an .ini file into nested structs: sections are stored as nested structs inside the root struct. Setting `[tryReal]` to `true` (the default value) will instruct the function to attempt to turn any values into real numbers if possible.

_**N.B.** This script is only intended to read the .ini files and strings that GM generates using the native `ini_close()` function. This is not a full implementation of an .ini specification (not that an official one really exists)._

&nbsp;

### snap_from_ini_file(filename, [tryReal]) ###

Convenience function that loads an .ini file from disk and passes it into `snap_from_ini_string()`.

