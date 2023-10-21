# Config JSON

&nbsp;

## `SnapToConfigJSON`

*Returns:* String, the data encoded as "config JSON"

|Name                  |Datatype    |Purpose                                                                                               |
|----------------------|------------|------------------------------------------------------------------------------------------------------|
|`data`                |struct/array|The nested array/struct data to encode                                                                |
|`[pretty]`            |boolean     |Whether to output a "pretty" string, one that uses indentation for easier reading. Defaults to `false`|
|`[alphabetizeStructs]`|boolean     |Whether to alphabetize structs by variable name. Defaults to `false`                                  |
|`[accurateFloats]`    |boolean     |Whether to output floats using a greater number of decimal points. Defaults to `false`                |

!> Setting any of the optional arguments to `true` will incur a memory and performance penalty. You will generally only want to turn the optional features on during development.

&nbsp;

## `SnapFromConfigJSON`

*Returns:* Array or struct, the root node of the "config JSON" data

|Name    |Datatype|Purpose                 |
|--------|--------|------------------------|
|`string`|string  |The JSON string to parse|

&nbsp;

## `SnapBufferWriteLooseJSON`

*Returns:* N/A (`undefined`)

|Name                  |Datatype    |Purpose                                                                                               |
|----------------------|------------|------------------------------------------------------------------------------------------------------|
|`buffer`              |buffer      |The buffer to write the "config JSON" string into                                                     |
|`data`                |struct/array|The nested array/struct data to encode                                                                |
|`[pretty]`            |boolean     |Whether to output a "pretty" string, one that uses indentation for easier reading. Defaults to `false`|
|`[alphabetizeStructs]`|boolean     |Whether to alphabetize structs by variable name. Defaults to `false`                                  |
|`[accurateFloats]`    |boolean     |Whether to output floats using a greater number of decimal points. Defaults to `false`                |

The "config JSON" string will be inserted into the buffer at the current "head" position, as determined by GameMaker's native `buffer_tell()` function.

!> Setting any of the optional arguments to `true` will incur a memory and performance penalty. You will generally only want to turn the optional features on during development.

&nbsp;

## `SnapBufferReadLooseJSON`

*Returns:* Array or struct, the root node of the "config JSON" data

|Name      |Datatype|Purpose                                                                                                                                                    |
|----------|--------|-----------------------------------------------------------------------------------------------------------------------------------------------------------|
|`buffer`  |buffer  |The buffer to read the "config JSON" string from                                                                                                           |
|`[offset]`|integer |The position in the buffer to read the "config JSON" string from, relative to the start of the buffer. If not specified, the buffer's head position is used|

?> If you do **not** specify an offset then SNAP will modify the buffer's "head" position. This allows you to read sequential data more easily.