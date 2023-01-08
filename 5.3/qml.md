# QML

[QML](https://en.wikipedia.org/wiki/QML) (Qt Modeling Language) is a markup language originally designed for describing user interface layouts. It was created for [Qt](https://en.wikipedia.org/wiki/Qt_(software)), a cross-platform GUI framework.

SNAP's implementation of QML is incomplete as a complete QML implementation necessarily involves writing a whole user interface system (an exercise for the reader, perhaps). The design of QML has many benefits if used beyond the scope of UI layouts, primarily the fact that it is possible to give structs a "type", thereby allowing SNAP to call a constructor when deserializing QML.

Consider this short QML segment:
```qml
Tree {
	x: 678
	y: 426
	leaves: "willow"
}
```

In a manner similar to JSON, QML allows us to describe a struct (delineated by curly brackets `{}`) and the variable for that struct. The key difference is the label `Tree` however, which indicates that the struct that follows should use whatever constructor is tied to the label of `"Tree"`.

We might want to deserialize the above QML using the following GML code:
```gml
//Define a constructor for trees decoded from QML
function ConstructorTree() constructor
{
	x = 0;
	y = 0;
	leaves = "default";
	children = []; //Required for use with SNAP's QML parser
}

//Define a struct ("dictionary") that maps QML labels to GML constructors
var _instanceofDict = {
	"Tree": ConstructorTree
};

treeStruct = SnapFromQML(QMLstring, _instanceofDict);
```

In this situation, when the QML parser sees a new struct labelled `Tree` in the QML string, it will will construct a new instance of `ConstructorTree()` and then assign variables to it as required.

Structs created from QML can have children. As noted above in the `ConstructorTree()` function, all QML constructors must contain a variable called `children` that is initialized to be an empty array. When deserializing QML, children of a particular struct are stored in this `children` array. For example, the following QML string...
```qml
Copse {
	x1: 578
	y1: 326
	x2: 778
	y2: 526

	Tree {
		x: 678
		y: 426
		leaves: "willow"
	}

	Tree {
		x: 601
		y: 350
		leaves: "pine"
	}
}
```

...would be deserialized as the following data (written here as GML literals):

```gml
root = { //instanceof = "ConstructorField"
	x1: 578,
	y1: 326,
	x2: 778,
	y2: 526,
	children: [
		{ //instanceof = "ConstructorTree"
			x: 678
			y: 426
			leaves: "willow"
		},
		{ //instanceof = "ConstructorTree"
			x: 601,
			y: 350,
			leaves: "pine",
		}
	]
}
```

If you enable relaxed mode when calling a SNAP QML function, you need not define 100% of the constructors that you're using. Instead, SNAP will recognise the literal names of the constructor functions as valid QML labels.

!> "Relaxed mode" is convenient during development but is a significant security hole in your program if you expose relaxed QML parsing to your users.

As mentioned above, SNAP's QML parser is not a complete implementation:

1. QML allows for JavaScript to be used to declaratively define properties relative to other properties. This sort of behaviour is far *far* beyond the scope of SNAP. SNAP instead parses in-line JavaScript as a string literal.
2. QML allows for structs to be created "on" properties; effectively this assigns a struct to a variable on the parent (rather than the child struct being in the `children` array). SNAP's parser doesn't support this but can do in the future if [someone asks for it](https://github.com/JujuAdams/SNAP/issues).
3. QML allows for new properties to be defined in the QML file itself, with an associated type. SNAP does not support this syntax, or type safety for that matter, but you can freely define new variables on generated structs without limitation.
4. QML allows for variables to be set on nested structs (e.g. `font.pixelSize: 42`). SNAP will interpret the variable name as literally `"font.pixelSize"` rather than trying to find a variable called `font` that holds a struct with a member variable `pixelSize`.

&nbsp;

## `SnapToQML`

*Returns:* String, the data encoded as QML

|Name                  |Datatype    |Purpose                                                                               |
|----------------------|------------|--------------------------------------------------------------------------------------|
|`data`                |struct/array|The nested array/struct data to encode                                                |
|`instanceofDict`      |struct      |A struct that maps QML type names to GML constructors. See above for more information |
|`[relaxed]`           |boolean     |Whether to run in "relaxed mode", see above. Defaults to `false`                      |
|`[accurateFloats]`    |boolean     |Whether to output floats using a greater number of decimal points. Defaults to `false`|

!> Setting `accurateFloats` to `true` will incur a memory and performance penalty.

&nbsp;

## `SnapFromQML`

*Returns:* Array or struct, the root node of the QML data

|Name            |Datatype|Purpose                                                                              |
|----------------|--------|-------------------------------------------------------------------------------------|
|`string`        |string  |The QML string to parse                                                              |
|`instanceofDict`|struct  |A struct that maps QML type names to GML constructors. See above for more information|
|`[relaxed]`     |boolean |Whether to run in "relaxed mode", see above. Defaults to `false`                     |

&nbsp;

## `SnapBufferWriteQML`

*Returns:* N/A (`undefined`)

|Name              |Datatype    |Purpose                                                                               |
|------------------|------------|--------------------------------------------------------------------------------------|
|`buffer`          |buffer      |The buffer to write the QML string into                                               |
|`data`            |struct/array|The nested array/struct data to encode                                                |
|`instanceofDict`  |struct      |A struct that maps QML type names to GML constructors. See above for more information |
|`[relaxed]`       |boolean     |Whether to run in "relaxed mode", see above. Defaults to `false`                      |
|`[accurateFloats]`|boolean     |Whether to output floats using a greater number of decimal points. Defaults to `false`|

The QML string will be inserted into the buffer at the current "head" position, as determined by GameMaker's native `buffer_tell()` function.

!> Setting `accurateFloats` to `true` will incur a memory and performance penalty.

&nbsp;

## `SnapBufferReadQML`

*Returns:* Array or struct, the root node of the "loose JSON" data

|Name            |Datatype|Purpose                                                                                                                                          |
|----------------|--------|-------------------------------------------------------------------------------------------------------------------------------------------------|
|`buffer`        |buffer  |The buffer to read the QML string from                                                                                                           |
|`instanceofDict`|struct  |A struct that maps QML type names to GML constructors. See above for more information                                                            |
|`[relaxed]`     |boolean |Whether to run in "relaxed mode", see above. Defaults to `false`                                                                                 |
|`[offset]`      |integer |The position in the buffer to read the QML string from, relative to the start of the buffer. If not specified, the buffer's head position is used|

?> If you do **not** specify an offset then SNAP will modify the buffer's "head" position. This allows you to read sequential data more easily.