# INI

!> I hate INI files, it is a nasty little format, and I strongly encourage you to move to other data storage formats. YAML is especially useful for config files, and JSON is otherwise generally applicable.

&nbsp;

## `SnapFromINIString`

*Returns:* Struct, the data found inside the INI string

|Name       |Datatype|Purpose                                                                      |
|-----------|--------|-----------------------------------------------------------------------------|
|`string`   |string  |INI data to parse, represented as a string                                   |
|`[tryReal]`|boolean |Whether try to convert strings to real values if possible. Defaults to `true`|

!> Setting `tryReal` to `true` will incur a performance penalty.

&nbsp;

## `SnapFromINIFile`

*Returns:* Struct, the data found inside the INI file

|Name       |Datatype|Purpose                                                                      |
|-----------|--------|-----------------------------------------------------------------------------|
|`filename` |string  |INI file to parse                                                            |
|`[tryReal]`|boolean |Whether try to convert strings to real values if possible. Defaults to `true`|

!> Setting `tryReal` to `true` will incur a performance penalty.

&nbsp;

## `SnapFromINIBuffer`

*Returns:* Struct, the data found inside the buffer

|Name       |Datatype|Purpose                                                                              |
|-----------|--------|-------------------------------------------------------------------------------------|
|`buffer`   |buffer  |Buffer to read the INI data from                                                     |
|`offset`   |integer |Position in the buffer to read the INI data from, relative to the start of the buffer|
|`size`     |integer |Number of bytes to read                                                              |
|`[tryReal]`|boolean |Whether try to convert strings to real values if possible. Defaults to `true`        |

!> Setting `tryReal` to `true` will incur a performance penalty.