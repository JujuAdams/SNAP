# Custom Binary

&nbsp;

## `SnapBufferWriteBinary`

*Returns:* N/A (`undefined`)

|Name    |Datatype    |Purpose                             |
|--------|------------|------------------------------------|
|`buffer`|buffer      |Buffer to write the binary data into|
|`data`  |struct/array|Data to encode                      |

The data will be inserted into the buffer at the current "head" position, as determined by GameMaker's native `buffer_tell()` function.

&nbsp;

## `SnapBufferReadBinary`

*Returns:* Struct or array, the data read from the buffer

|Name    |Datatype|Purpose                                                                      |
|--------|--------|-----------------------------------------------------------------------------|
|`buffer`|buffer  |Buffer to read the NSV data from                                             |
|`offset`|integer |Position in the buffer to read data from, relative to the start of the buffer|