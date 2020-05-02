<h1 align="center">SNAP: Struct N' Array Parser 2.0.0</h1>

<p align="center">Replacement for ds_map/ds_list-based JSON encoding/decoding</p>

<p align="center"><a href="https://github.com/JujuAdams/SNAP/releases/tag/2.0.0">Download the .yymps here</a></p>

&nbsp;

-----

&nbsp;

### snap_to_json_string(struct/array, [pretty], [alphabetizeStructs]) ###

Turns struct and array nested data into a JSON string. The root data type can be either a struct or an array. Setting `[pretty]` to `true` will format the JSON string in a more pleasing human-readable way, whereas setting `[alphabetizeStructs]` to `true` will output the struct variables in ascending alphabetical order. Using pretty and/or alphabetized output does incur a performance penalty.

&nbsp;

### snap_from_json_string(string) ###

Decodes a JSON string into nested struct/array data. This function will happily ignore formatting whitespace and handles `\\`, `\"`, `\n`, `\r`, and `\t` escaped characters. Also supports `true`, `false`, and `null` values.

&nbsp;

### snap_to_binary(struct/array) ###

Returns a buffer that holds binary encoded struct and array nested data. The root data type can be either a struct or an array. This is substantially faster than `sna_to_json()`.

&nbsp;

### snap_from_binary(buffer, [offset], [size], [destroyBuffer]) ###

Unpacks binary encoded struct/array data. An `[offset]` and total `[size]` for the data within the buffer can be specified which is helpful for working with composite buffers. Set `[size]` to `-1` to use the entire size of the buffer. If `[destroyBuffer]` is set to `true` then the input buffer will be destroyed once the function has finished executing. This function is a lot faster than `json_to_sna()`.
