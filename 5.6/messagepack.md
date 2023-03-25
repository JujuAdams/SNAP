# MessagePack

[MessagePack](https://msgpack.org/index.html) is a binary format that is an alternative to JSON. It is both smaller and faster to parse with libraries for parsing available in many languages. MessagePack is especially useful for communicating with servers written in other languages.

?> If you're looking for a faster alternative to JSON but aren't concerned about the interoperability benefits of MessagePack, take a look at SNAP's [custom binary format](custom-binary).

&nbsp;

## `SnapBufferWriteMessagePack`

*Returns:* N/A (`undefined`)

|Name    |Datatype    |Purpose                             |
|--------|------------|------------------------------------|
|`buffer`|buffer      |Buffer to write the binary data into|
|`data`  |struct/array|Data to encode                      |

The MessagePack data will be inserted into the buffer at the current "head" position, as determined by GameMaker's native `buffer_tell()` function.

&nbsp;

## `SnapBufferReadMessagePack`

*Returns:* Struct or array, the data read from the buffer

|Name    |Datatype|Purpose                                                                      |
|--------|--------|-----------------------------------------------------------------------------|
|`buffer`|buffer  |Buffer to read the MessagePack data from                                     |
|`offset`|integer |Position in the buffer to read data from, relative to the start of the buffer|