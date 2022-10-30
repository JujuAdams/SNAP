# JSON

[JavaScript Object Notation](https://www.json.org/json-en.html), otherwise known as JSON, is a commonly-used data format on the web. It is a text-based format insofar that JSON is expressed as a human-readable string of symbols, letters, and numbers. Its use has grown over the years such that it is frequently used through software engineering. JSON hits the sweet spot of simple, human-readable, and general enough to express nested datasets. JSON does have its limits however: it is not memory-efficient, it can be slow to parse (load), it is hard to write by hand, and JSON cannot express cylical self-reference. In reality, JSON is more than adequate for most data storage in GameMaker and you'll find yourself using it a lot for everything from savedata, to REST APIs, to item databases.

JSON in GameMaker used to be handled by the nested ds_list and ds_map constructions. Old-style GameMaker JSON could be converted from lists/maps to a string and back again using `json_encode()` and `json_decode()`. As of GameMaker 2.3, the preference these days is to represent JSON data as arrays and structs rather than lists and maps, and the functions `json_stringify()` and `json_parse()` should be used instead. These functions aren't perfect, however, and there is room for improvement.

SNAP's JSON stringification functions (`SnapToJSON()` and `SnapToJSONBuffer()`) allow you to customise the accuracy of floating point numbers and the appearance of the resulting JSON string. The former option works around a flaw in `json_stringify()` where only two decimal places are stored for a decimal number, and the later makes JSON output much easier to read. Both behaviour incur a performance and memory penalty but they are often useful during development if nothing else.

The JSON parser (`SnapFromJson()` and `SnapFromJSONBuffer()`) covers basic JSON reading as well as allowing for in-line and block comments. This isn't strictly part of the JSON specification, but being able to comment out sections of JSON is a useful feature. SNAP's JSON parser also allows for hanging commas at the end of arrays and objects which is convenient when writing JSON by hand.

&nbsp;

## SnapToJSON

*Returns:* String, the JSON-encoded data

&nbsp;

## SnapToJSON

*Returns:* Array or struct, the root node of the JSON data

&nbsp;

## SnapToJSONBuffer

*Returns:* N/A (`undefined`)

&nbsp;

## SnapFromJSONBuffer

*Returns:* Array or struct, the root node of the JSON data