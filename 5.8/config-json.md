# Config JSON

&nbsp;

## `SnapFromConfigJSON`

*Returns:* Array or struct, the root node of the "config JSON" data

|Name    |Datatype|Purpose                 |
|--------|--------|------------------------|
|`string`|string  |The JSON string to parse|

&nbsp;


## `SnapBufferReadConfigJSON`

*Returns:* Array or struct, the root node of the "config JSON" data

|Name      |Datatype|Purpose                                                                                                                                                    |
|----------|--------|-----------------------------------------------------------------------------------------------------------------------------------------------------------|
|`buffer`  |buffer  |The buffer to read the "config JSON" string from                                                                                                           |
|`[offset]`|integer |The position in the buffer to read the "config JSON" string from, relative to the start of the buffer. If not specified, the buffer's head position is used|

?> If you do **not** specify an offset then SNAP will modify the buffer's "head" position. This allows you to read sequential data more easily.