# YAML

&nbsp;

## `SnapToYAML`

*Returns:* String, the YAML data

|Name                  |Datatype    |Purpose                                                                               |
|----------------------|------------|--------------------------------------------------------------------------------------|
|`data`                |struct/array|Data to encode                                                                        |
|`[alphabetizeStructs]`|boolean     |Whether to alphabetize structs by variable name. Defaults to `false`                  |
|`[accurateFloats]`    |boolean     |Whether to output floats using a greater number of decimal points. Defaults to `false`|

!> Setting either of the optional arguments to `true` will incur a memory and performance penalty. You will generally only want to turn the optional features on during development.

&nbsp;

## `SnapFromYAML`

*Returns:* Struct or array, the struct/array resprentation of the input YAML data

|Name    |Datatype|Purpose           |
|--------|--------|------------------|
|`string`|string  |YAML data to parse|

&nbsp;

## `SnapBufferWriteYAML`

*Returns:* N/A (`undefined`)

|Name                  |Datatype    |Purpose                                                                               |
|----------------------|------------|--------------------------------------------------------------------------------------|
|`buffer`              |buffer      |Buffer to write the YAML data into                                                    |
|`data`                |struct/array|Data to encode                                                                        |
|`[alphabetizeStructs]`|boolean     |Whether to alphabetize structs by variable name. Defaults to `false`                  |
|`[accurateFloats]`    |boolean     |Whether to output floats using a greater number of decimal points. Defaults to `false`|

!> Setting either of the optional arguments to `true` will incur a memory and performance penalty. You will generally only want to turn the optional features on during development.

&nbsp;

## `SnapBufferReadYAML`

*Returns:* Struct or array, the struct/array resprentation of the input YAML data

|Name               |Datatype|Purpose                                                                                                                                                  |
|-------------------|--------|---------------------------------------------------------------------------------------------------------------------------------------------------------|
|`buffer`           |buffer  |Buffer to read the YAML data from                                                                                                                        |
|`offset`           |integer |Offset in the buffer to read data from                                                                                                                   |
|`[replaceKeywords]`|boolean |Whether to replace keyword strings (`"true"`, `"false"`, `"null"`) with their equivalents. Defaults to `true`                                            |
|`[trackFieldOrder]`|boolean |Whether to track the order of struct fields as they appear in the YAML string (stored in `__snapFieldOrder` field on each GML struct). Default to `false`|
|`[tabSize=2]`      |integer |Size of tabs, measured in "number of spaces". This is used to calculate indentation                                                                      |