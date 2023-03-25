# XML

&nbsp;

## `SnapToXML`

*Returns:* String, the CSV data

|Name  |Datatype|Purpose       |
|------|--------|--------------|
|`data`|struct  |Data to encode|

&nbsp;

## `SnapFromXML`

*Returns:* Struct, the struct/array resprentation of the input XML data

|Name    |Datatype|Purpose                                  |
|--------|--------|-----------------------------------------|
|`string`|string  |XML data, presented as a string, to parse|

&nbsp;

## `SnapBufferWriteYAML`

*Returns:* N/A (`undefined`)

|Name    |Datatype|Purpose                          |
|--------|--------|---------------------------------|
|`buffer`|buffer  |Buffer to write the XML data into|
|`data`  |struct  |Data to encode                   |

The XML string will be inserted into the buffer at the current "head" position, as determined by GameMaker's native `buffer_tell()` function.

&nbsp;

## `SnapBufferReadYAML`

*Returns:* Struct, the struct/array resprentation of the input XML data

|Name    |Datatype|Purpose                                                                              |
|--------|--------|-------------------------------------------------------------------------------------|
|`buffer`|buffer  |Buffer to read the CSV data from                                                     |
|`offset`|integer |Position in the buffer to read the CSV data from, relative to the start of the buffer|
|`size`  |integer |Number of bytes to read                                                              |