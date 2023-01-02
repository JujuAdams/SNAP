# Loose JSON

"Loose JSON" is a custom JSON-like format developed for use in configuration files. Loose JSON stands somewhere between [JSON](json) and [YAML](yaml) and attempts to combine the familiarity of the former with the writing convenience of the latter.

Loose JSON focuses on being easy to write. It dispenses with commas and double quotes where they are not needed. Loose JSON can also contain single-line and multi-line comments. Any standard JSON is automatically parseable as Loose JSON, but Loose JSON isn't typically parseable as standard JSON.

Consider the following JSON:

```json
{
	"graphics": {
		"width": 1920,
		"height": 1080,
		"fullscreen": true
	},
	"names": ["john and yoko", "paul", "george", "ringo"]
}
```

This could be written as the following loose JSON:

```
{
	graphics: {
		width: 1920
		height: 1080
		fullscreen: true
	}
	names: [john and yoko, paul, george, ringo]
}
```

In loose JSONT, the keywords `true` and `false` (without quotes) are transformed into booleans as one would expect. The keyword `null` (again, without quotes) is converted into GameMaker's native `undefined` datatype.

A string must be delimited using double quotes in the following situations:
1. If a string needs to contain any reserved symbols (`:` `,` `\n` `\r` `{` `}` `[` `]`)
2. If a string needs to be exactly `"true"` `"false"` or `"null"`
3. If a string must contain whitespace at the start or end

&nbsp;

## `SnapToLooseJSON`

*Returns:* String, the data encoded as "loose JSON"

|Name                  |Datatype    |Purpose                                                                                               |
|----------------------|------------|------------------------------------------------------------------------------------------------------|
|`data`                |struct/array|The nested array/struct data to encode                                                                |
|`[pretty]`            |boolean     |Whether to output a "pretty" string, one that uses indentation for easier reading. Defaults to `false`|
|`[alphabetizeStructs]`|boolean     |Whether to alphabetize structs by variable name. Defaults to `false`                                  |
|`[accurateFloats]`    |boolean     |Whether to output floats using a greater number of decimal points. Defaults to `false`                |

!> Setting any of the optional arguments to `true` will incur a memory and performance penalty. You will generally only want to turn the optional features on during development.

&nbsp;

## `SnapFromLooseJSON`

*Returns:* Array or struct, the root node of the "loose JSON" data

|Name    |Datatype|Purpose                 |
|--------|--------|------------------------|
|`string`|string  |The JSON string to parse|

&nbsp;

## `SnapBufferWriteLooseJSON`

*Returns:* N/A (`undefined`)

|Name                  |Datatype    |Purpose                                                                                               |
|----------------------|------------|------------------------------------------------------------------------------------------------------|
|`buffer`              |buffer      |The buffer to write the "loose JSON" string into                                                      |
|`data`                |struct/array|The nested array/struct data to encode                                                                |
|`[pretty]`            |boolean     |Whether to output a "pretty" string, one that uses indentation for easier reading. Defaults to `false`|
|`[alphabetizeStructs]`|boolean     |Whether to alphabetize structs by variable name. Defaults to `false`                                  |
|`[accurateFloats]`    |boolean     |Whether to output floats using a greater number of decimal points. Defaults to `false`                |

The "loose JSON" string will be inserted into the buffer at the current "head" position, as determined by GameMaker's native `buffer_tell()` function.

!> Setting any of the optional arguments to `true` will incur a memory and performance penalty. You will generally only want to turn the optional features on during development.

&nbsp;

## `SnapBufferReadLooseJSON`

*Returns:* Array or struct, the root node of the "loose JSON" data

|Name      |Datatype|Purpose                                                                                                                                                   |
|----------|--------|----------------------------------------------------------------------------------------------------------------------------------------------------------|
|`buffer`  |buffer  |The buffer to read the "loose JSON" string from                                                                                                           |
|`[offset]`|integer |The position in the buffer to read the "loose JSON" string from, relative to the start of the buffer. If not specified, the buffer's head position is used|

?> If you do **not** specify an offset then SNAP will modify the buffer's "head" position. This allows you to read sequential data more easily.