# VDF

Valve's [KeyValue format](https://developer.valvesoftware.com/wiki/KeyValues), more commonly known as the "Valve Data Format" or VDF, is a simple struct-based data format used for several Source Engine titles. The format curiously doesn't support arrays and all values must be strings, but its simplicity makes it attractive for human-readable configuration files and the like.

!> SNAP's VDF parser does not support the use of `#include` or `#base`.

&nbsp;

## `SnapToVDF`

*Returns:* String, the VDF-encoded data

|Name                  |Datatype    |Purpose                                                                               |
|----------------------|------------|--------------------------------------------------------------------------------------|
|`data`                |struct/array|The nested struct data to encode                                                      |
|`[alphabetizeStructs]`|boolean     |Whether to alphabetize structs by variable name. Defaults to `false`                  |
|`[accurateFloats]`    |boolean     |Whether to output floats using a greater number of decimal points. Defaults to `false`|

!> Setting any of the optional arguments to `true` will incur a memory and performance penalty. You will generally only want to turn the optional features on during development.

&nbsp;

## `VDF`

*Returns:* Struct, the root node of the VDF data

|Name    |Datatype|Purpose                |
|--------|--------|-----------------------|
|`string`|string  |The VDF string to parse|

&nbsp;

## `SnapBufferWriteVDF`

*Returns:* N/A (`undefined`)

|Name                  |Datatype    |Purpose                                                                               |
|----------------------|------------|--------------------------------------------------------------------------------------|
|`buffer`              |buffer      |The buffer to write the VDF string into                                               |
|`data`                |struct/array|The nested array/struct data to encode                                                |
|`[alphabetizeStructs]`|boolean     |Whether to alphabetize structs by variable name. Defaults to `false`                  |
|`[accurateFloats]`    |boolean     |Whether to output floats using a greater number of decimal points. Defaults to `false`|

The VDF string will be inserted into the buffer at the current "head" position, as determined by GameMaker's native `buffer_tell()` function.

!> Setting any of the optional arguments to `true` will incur a memory and performance penalty. You will generally only want to turn the optional features on during development.

&nbsp;

## `SnapBufferReadVDF`

*Returns:* Struct, the root node of the JSON data

|Name      |Datatype|Purpose                                                                                                                                          |
|----------|--------|-------------------------------------------------------------------------------------------------------------------------------------------------|
|`buffer`  |buffer  |The buffer to read the VDF string from                                                                                                           |
|`[offset]`|integer |The position in the buffer to read the VDF string from, relative to the start of the buffer. If not specified, the buffer's head position is used|

?> If you do **not** specify an offset then SNAP will modify the buffer's "head" position. This allows you to read sequential data more easily.