# QML

&nbsp;

## `SnapToQML`

*Returns:* String, the data encoded as QML

|Name                  |Datatype    |Purpose                                                                               |
|----------------------|------------|--------------------------------------------------------------------------------------|
|`data`                |struct/array|The nested array/struct data to encode                                                |
|`instanceofDict`      |struct      |A struct that maps QML type names to GML constructors. See above for more information |
|`[relaxed]`           |boolean     |Whether to run in "relaxed mode", see above. Defaults to `false`                      |
|`[accurateFloats]`    |boolean     |Whether to output floats using a greater number of decimal points. Defaults to `false`|

!> Setting any of the optional arguments to `true` will incur a memory and performance penalty. You will generally only want to turn the optional features on during development.

&nbsp;

## `SnapFromQML`

*Returns:* Array or struct, the root node of the QML data

|Name            |Datatype|Purpose                                                                              |
|----------------|--------|-------------------------------------------------------------------------------------|
|`string`        |string  |The QML string to parse                                                              |
|`instanceofDict`|struct  |A struct that maps QML type names to GML constructors. See above for more information|
|`[relaxed]`     |boolean |Whether to run in "relaxed mode", see above. Defaults to `false`                     |

&nbsp;

## `SnapBufferWriteQML`

*Returns:* N/A (`undefined`)

|Name              |Datatype    |Purpose                                                                               |
|------------------|------------|--------------------------------------------------------------------------------------|
|`buffer`          |buffer      |The buffer to write the QML string into                                               |
|`data`            |struct/array|The nested array/struct data to encode                                                |
|`instanceofDict`  |struct      |A struct that maps QML type names to GML constructors. See above for more information |
|`[relaxed]`       |boolean     |Whether to run in "relaxed mode", see above. Defaults to `false`                      |
|`[accurateFloats]`|boolean     |Whether to output floats using a greater number of decimal points. Defaults to `false`|

The QML string will be inserted into the buffer at the current "head" position, as determined by GameMaker's native `buffer_tell()` function.

!> Setting any of the optional arguments to `true` will incur a memory and performance penalty. You will generally only want to turn the optional features on during development.

&nbsp;

## `SnapBufferReadQML`

*Returns:* Array or struct, the root node of the "loose JSON" data

|Name            |Datatype|Purpose                                                                                                                                          |
|----------------|--------|-------------------------------------------------------------------------------------------------------------------------------------------------|
|`buffer`        |buffer  |The buffer to read the QML string from                                                                                                           |
|`instanceofDict`|struct  |A struct that maps QML type names to GML constructors. See above for more information                                                            |
|`[relaxed]`     |boolean |Whether to run in "relaxed mode", see above. Defaults to `false`                                                                                 |
|`[offset]`      |integer |The position in the buffer to read the QML string from, relative to the start of the buffer. If not specified, the buffer's head position is used|

?> If you do **not** specify an offset then SNAP will modify the buffer's "head" position. This allows you to read sequential data more easily.