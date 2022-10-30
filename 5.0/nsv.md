# NSV

Null-Separated Value fules, or NSVs, are a custom data format designed for GameMaker that replicates the behaviour of CSVs but allowing for much faster ingestion in GameMaker than would be possible with standard CSVs. You will find NSVs especially helpful when handling large quantities of tabulated data, such as an item database or localisation strings.

NSVs can only be written and read using buffers as their use of null characters interferes with a string representation of the data. NSVs should only be used to store and retrieve 2D arrays that contain numbers or strings. If you're looking to store more complex data structures in whilst optimising performance, please use the [Custom Binary](custom-binary) functions.

!> NSVs only work on "rectangular" data where the length of each child array is the same.

&nbsp;

## `SnapToNSV`

*Returns:* N/A (`undefined`)

|Name              |Datatype|Purpose                                                                               |
|------------------|--------|--------------------------------------------------------------------------------------|
|`buffer`          |buffer  |The buffer to write the NSV data into                                                 |
|`data`            |2D array|The 2D array to encode                                                                |
|`[width]`         |integer |The length of each child array. If not provided, SNAP will find the maximum length    |
|`[accurateFloats]`|boolean |Whether to output floats using a greater number of decimal points. Defaults to `false`|

The NSV data will be inserted into the buffer at the current "head" position, as determined by GameMaker's native `buffer_tell()` function.

!> Setting `accurateFloats` to `true` will incur a memory and performance penalty.

&nbsp;

## `SnapFromNSV`

*Returns:* 2D array

|Name      |Datatype|Purpose                                                                                                                                        |
|----------|--------|-----------------------------------------------------------------------------------------------------------------------------------------------|
|`buffer`  |buffer  |The buffer to read the NSV data from                                                                                                           |
|`[offset]`|integer |The position in the buffer to read the NSV data from, relative to the start of the buffer. If not specified, the buffer's head position is used|

?> If you do **not** specify an offset then SNAP will modify the buffer's "head" position. This allows you to read sequential data more easily.