# GML

&nbsp;

## `SnapToGML`

*Returns:* String, the data rewritten as a GML-compatible block of code

|Name                  |Datatype|Purpose                                                             |
|----------------------|--------|--------------------------------------------------------------------|
|`data`                |struct  |Data to encode                                                      |
|`[alphabetizeStructs]`|boolean |Whether to alphabetize structs by variable name. Defaults to `false`|

&nbsp;

## `SnapFromGML`

*Returns:* Struct, the resprentation of the input GML code

|Name    |Datatype|Purpose     |
|--------|--------|------------|
|`string`|string  |GML to parse|

Parses and executes simple GML code stored in a string. Returns the scope, as given by the `scope` parameter. This GML parser is very stripped back and supports a small subset of GML. The use of this parser should be limited to reading data in keeping with the overall intentions of SNAP as a data-oriented library.

The parser supports:
- Struct / array literals (JSON)
- Most GML operators, including ternaries (`condition? valueIfTrue : valueIfFalse`)
- Executing functions
- Instantiating constructors (with `new`)
- Setting global variables
- Setting scoped variables

The parser does not support:
- if/else, while, etc. flow control
- Function and constructor definition
- Dot notation for variable access in structs/instances
- Square bracket notation for array value access
- Anything else that's not explicitly mentioned

Tokens for macros, GML constants, assets etc. can be added by defining them as key-value pairs in the `tokenStruct` parameter. Tokens can be added globally for all executions of `SnapFromGML()` and `SnapBufferReadGML()` by calling `SnapEnvGMLSetToken()` and `SnapEnvGMLSetTokenFunction()`. Please see those functions for more information.

The scope for setting variables is given by by `scope` parameter. By default, variables are set in global scope. You may want to replace this with a struct or an instance depending on your use case.

If you set the `allowAllAssets` parameter to `true` then the GML parser will treat all assets in your project as accessible (effectively this adds all assets in your project as valid tokens). It is not recommended to ship any code with this parameter set to `true` as it may introduce security issues; instead you should explicitly add tokens for assets that you would like to be made accessible.

&nbsp;

## `SnapBufferWriteGML`

*Returns:* N/A (`undefined`)

|Name                  |Datatype|Purpose                                                             |
|----------------------|--------|--------------------------------------------------------------------|
|`buffer`              |buffer  |Buffer to write the GML code into                                   |
|`data`                |struct  |Data to encode                                                      |
|`[alphabetizeStructs]`|boolean |Whether to alphabetize structs by variable name. Defaults to `false`|

The GML string will be inserted into the buffer at the current "head" position, as determined by GameMaker's native `buffer_tell()` function.

&nbsp;

## `SnapBufferReadGML`

*Returns:* Struct, the struct/array resprentation of the input GML code

|Name    |Datatype|Purpose                                                                              |
|--------|--------|-------------------------------------------------------------------------------------|
|`buffer`|buffer  |Buffer to read the GML code from                                                     |
|`offset`|integer |Position in the buffer to read the GML code from, relative to the start of the buffer|
|`size`  |integer |Number of bytes to read                                                              |

Parses and executes simple GML code stored in a buffer as a string. Returns the scope, as given by the `scope` parameter. This GML parser is very stripped back and supports a small subset of GML. The use of this parser should be limited to reading data in keeping with the overall intentions of SNAP as a data-oriented library.

!> The string in the buffer should include the null terminator.

The parser supports:
- Struct / array literals (JSON)
- Most GML operators, including ternaries (`condition? valueIfTrue : valueIfFalse`)
- Executing functions
- Instantiating constructors (with `new`)
- Setting global variables
- Setting scoped variables

The parser does not support:
- if/else, while, etc. flow control
- Function and constructor definition
- Dot notation for variable access in structs/instances
- Square bracket notation for array value access
- Anything else that's not explicitly mentioned

Tokens for macros, GML constants, assets etc. can be added by defining them as key-value pairs in the `tokenStruct` parameter. Tokens can be added globally for all executions of `SnapFromGML()` and `SnapBufferReadGML()` by calling `SnapEnvGMLSetToken()` and `SnapEnvGMLSetTokenFunction()`. Please see those functions for more information.

The scope for setting variables is given by by `scope` parameter. By default, variables are set in global scope. You may want to replace this with a struct or an instance depending on your use case.

If you set the `allowAllAssets` parameter to `true` then the GML parser will treat all assets in your project as accessible (effectively this adds all assets in your project as valid tokens). It is not recommended to ship any code with this parameter set to `true` as it may introduce security issues; instead you should explicitly add tokens for assets that you would like to be made accessible.

&nbsp;

## `SnapEnvGMLSetToken`

*Returns:* N/A (`undefined`)

|Name       |Datatype|Purpose                   |
|-----------|--------|--------------------------|
|`tokenName`|string  |Name of the token to alias|
|`value`    |any     |Value for the token       |

Adds a token to all future calls to `SnapFromGML()` and `SnapBufferReadGML()`. When evaluated, the token will return the value set by this function. This is useful to carry across constants into the GML parser e.g. the width and height of a tile in your game.

&nbsp;

## `SnapEnvGMLSetTokenFunction`

*Returns:* N/A (`undefined`)

|Name        |Datatype|Purpose                                      |
|------------|--------|---------------------------------------------|
|`tokenName` |string  |Name of the token to alias                   |
|`function`  |function|Function to execute when evaluating the token|
|`[metadata]`|any     |Value for the token                          |

Adds a token to all future calls to `SnapFromGML()` and `SnapBufferReadGML()`. When evaluated, the token will execute the defined function. The return value from that function will be used as the value for the token. This is useful for dynamically updating values (time, mouse position and so on). The `metadata` parameter is passed as the one (and only) parameter for the defined function.

&nbsp;

## `SnapEnvGMLSetNativeTokens`

*Returns:* N/A (`undefined`)

|Name|Datatype|Purpose|
|----|--------|-------|
|None|        |       |

Adds all (I think!) native GML constants and global variables to the SNAP GML environment. This means that these native values will be available for reading (but not writing) within the SNAP GML parser.