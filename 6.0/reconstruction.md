# Reconstruction

&nbsp;

## `SnapReconstructionPack`

*Returns:* N/A (`undefined`)

|Name                      |Datatype    |Purpose                                                                                                       |
|--------------------------|------------|--------------------------------------------------------------------------------------------------------------|
|`value`                   |string/array|The nested array/struct data to process                                                                       |
|`[instanceofVariableName]`|string      |Name of the special variable to store `instanceof()` data in. If not specified, defaults to `"__instanceof__"`|
|`[unsetConstructor]`      |boolean     |Whether to unset constructors for structs. If not specified, defaults to `false`                              |

Recursively navigates over a nested struct/array and writes the `instanceof()` value for structs into a special value in the struct itself. This value can then be serialized with the rest of the struct's non-static variables using a SNAP function or `json_stringify()` etc.  When deserializing data, either using a SNAP function or `json_parse()`, you should reconstruct the constructor for structs by calling `SnapReconstructionUnpack()`.

If `unsetConstructor` is set to `true`, the constructor for structs is also cleared which is handy to work around current (2023.8, 2023-10-21) bugs in `json_stringify()`. You will need to restore the `instanceof()` value using `SnapReconstructionUnpack()` if you intend to keep using static variables/methods in these structs.

!> There are significant limitations to what constructors can be serialized. This is mostly to avoid unpleasant situations where it's not possible to deserialize. You cannot use anonymous and/or non-global constructors with `SnapReconstructionPack()` as these cannot be reliably resolved later on when using `SnapReconstructionUnpack()`.

Intended use is:

```
//On save
SnapReconstructionPack(jsonToSave);
SnapStringToFile(SnapToJSON(jsonToSave, "filename.txt"));
SnapReconstructionCleanUp(jsonToSave);

//On load
loadedJson = SnapFromJSON(SnapStringFromFile("filename.txt"));
SnapReconstructionCleanUp(loadedJson);
```

!> This function is only available in versions of GameMaker with the native functions `static_get()` and `static_set()`.

&nbsp;

## `SnapReconstructionUnpack`

*Returns:* N/A (`undefined`)

|Name                      |Datatype    |Purpose                                                                                                       |
|--------------------------|------------|--------------------------------------------------------------------------------------------------------------|
|`value`                   |string/array|The nested array/struct data to process                                                                       |
|`[instanceofVariableName]`|string      |Name of the special variable to store `instanceof()` data in. If not specified, defaults to `"__instanceof__"`|
|`[cleanUp]`               |boolean     |Whether to unset constructors for structs. If not specified, defaults to `false`                              |

Recursively navigates over a nested struct/array and restores `instanceof()` values for structs based on the value of a special variable in each struct. These special variables are set by the companion function `SnapReconstructionPack()`.

If `unsetConstructor` is set to `false`, the special variable used to store the `instanceof()` value for each struct will be maintained rather than deleted.

!> You cannot use anonymous and/or non-global constructors with `SnapReconstructionPack()` as these cannot be reliably resolved.

!> This function is only available in versions of GameMaker with the native functions `static_get()` and `static_set()`.

&nbsp;

## `SnapReconstructionCleanUp`

*Returns:* N/A (`undefined`)

|Name                      |Datatype    |Purpose                                                                                                       |
|--------------------------|------------|--------------------------------------------------------------------------------------------------------------|
|`value`                   |string/array|The nested array/struct data to process                                                                       |
|`[instanceofVariableName]`|string      |Name of the special variable to store `instanceof()` data in. If not specified, defaults to `"__instanceof__"`|

Cleans up special variables inserted into structs by `SnapReconstructionPack()`.

!> This function is only available in versions of GameMaker with the native functions `static_get()` and `static_set()`.