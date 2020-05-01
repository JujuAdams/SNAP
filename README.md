<h1 align="center">Struct n' Array JSON 1.0.0</h1>

<p align="center">Replacement for ds_map/ds_list-based JSON encoding/decoding</p>

<p align="center"><a href="https://github.com/JujuAdams/struct-n-array-JSON/releases/tag/1.0.0">Download the .yymps here</a></p>

&nbsp;

-----

&nbsp;

### sna_to_json_string(struct/array, [pretty], [alphabetizeStructs]) ###

Turns struct and array nested data into a JSON string. The root data type can be either a struct or an array. Setting `[pretty]` to `true` will format the JSON string in a more pleasing human-readable way, whereas setting `[alphabetizeStructs]` to `true` will output the struct variables in ascending alphabetical order. Using pretty and/or alphabetized output does incur a performance penalty.

&nbsp;

### json_string_to_sna(string) ###

Decodes a JSON string into nested struct/array data. This function will happily ignore whitespace and supports `true`, `false`, and `null` values.
