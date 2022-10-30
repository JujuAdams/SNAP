# CSV

&nbsp;

## `SnapToCSV`

*Returns:* String, the CSV data

|Name               |Datatype|Purpose                                                                                |
|-------------------|--------|---------------------------------------------------------------------------------------|
|`data`             |2D array|The 2D array to encode                                                                 |
|`[cellDelimiter]`  |string  |The delimiter to use to split cells from each other. Defaults to `,`                   |
|`[stringDelimiter]`|string  |The delimiter to use to indicate a cell explicitly contains a string. Defaults to `","`|
|`[accurateFloats]` |boolean |Whether to output floats using a greater number of decimal points. Defaults to `false` |

!> Setting `accurateFloats` to `true` will incur a memory and performance penalty.

&nbsp;

## `SnapFromCSV`

*Returns:* 2D array

|Name    |Datatype|Purpose                |
|--------|--------|-----------------------|
|`string`|string  |The CSV string to parse|

&nbsp;

## `SnapToCSVBuffer`

*Returns:* N/A (`undefined`)

|Name               |Datatype|Purpose                                                                                |
|-------------------|--------|---------------------------------------------------------------------------------------|
|`buffer`           |buffer  |The buffer to write the CSV string into                                                |
|`data`             |2D array|The 2D array to encode                                                                 |
|`[cellDelimiter]`  |string  |The delimiter to use to split cells from each other. Defaults to `,`                   |
|`[stringDelimiter]`|string  |The delimiter to use to indicate a cell explicitly contains a string. Defaults to `","`|
|`[accurateFloats]` |boolean |Whether to output floats using a greater number of decimal points. Defaults to `false` |

The CSV string will be inserted into the buffer at the current "head" position, as determined by GameMaker's native `buffer_tell()` function.

!> Setting `accurateFloats` to `true` will incur a memory and performance penalty.

&nbsp;

## `SnapFromCSVBuffer`

*Returns:* 2D array

|Name      |Datatype|Purpose                                                                                                                                        |
|----------|--------|-----------------------------------------------------------------------------------------------------------------------------------------------|
|`buffer`  |buffer  |The buffer to read the CSV data from                                                                                                           |
|`[offset]`|integer |The position in the buffer to read the CSV data from, relative to the start of the buffer. If not specified, the buffer's head position is used|

?> If you do **not** specify an offset then SNAP will modify the buffer's "head" position. This allows you to read sequential data more easily.