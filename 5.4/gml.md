# GML

&nbsp;

## `SnapToGML`

*Returns:* String, the data rewritten as a GML-compatible block of code

|Name                  |Datatype|Purpose                                                             |
|----------------------|--------|--------------------------------------------------------------------|
|`data`                |struct  |Data to encode                                                      |
|`[alphabetizeStructs]`|boolean |Whether to alphabetize structs by variable name. Defaults to `false`|

&nbsp;

## `SnapFromGML`

*Returns:* Struct, the resprentation of the input GML code

|Name    |Datatype|Purpose     |
|--------|--------|------------|
|`string`|string  |GML to parse|

&nbsp;

## `SnapBufferWriteGML`

*Returns:* N/A (`undefined`)

|Name                  |Datatype|Purpose                                                             |
|----------------------|--------|--------------------------------------------------------------------|
|`buffer`              |buffer  |Buffer to write the GML code into                                   |
|`data`                |struct  |Data to encode                                                      |
|`[alphabetizeStructs]`|boolean |Whether to alphabetize structs by variable name. Defaults to `false`|

The GML string will be inserted into the buffer at the current "head" position, as determined by GameMaker's native `buffer_tell()` function.

&nbsp;

## `SnapBufferReadGML`

*Returns:* Struct, the struct/array resprentation of the input GML code

|Name    |Datatype|Purpose                                                                              |
|--------|--------|-------------------------------------------------------------------------------------|
|`buffer`|buffer  |Buffer to read the GML code from                                                     |
|`offset`|integer |Position in the buffer to read the GML code from, relative to the start of the buffer|
|`size`  |integer |Number of bytes to read                                                              |