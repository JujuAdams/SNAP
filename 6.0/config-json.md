# Config JSON

"Config JSON" is custom JSON-like loose format, and is even less strict than "Loose JSON".

Config JSON focuses on being easy to write. It dispenses with commas and double quotes where they are not needed. Config JSON can also contain single-line and multi-line comments (they are ignored on load).
It allows to use duplicated keys (data either is just replaced in case of integers and string, or merged in case of arrays and structs).

```
{
  // display info
  height: 720,
  width: 960,
  width: 1280,
  /* names */
  names: [john and yoko],
  names: ["paul", george, "ringo"],
}
```

This would result in GML struct:

```
{}
 |- height: 720
 |- names:[]
 |         |- "john and yoko"
 |         |- "paul"
 |         |- "george"
 |         \- "ringo"
 \- width: 1280
```

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

?> There's no write function, as GML struct cannot have duplicated keys or comments, so [SnapBufferWriteLooseJSON](loose-json?id=snapbufferwriteloosejson) can be used instead. Remember that you would lose comments when overriding existing file.
