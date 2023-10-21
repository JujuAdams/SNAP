# Utilities

SNAP has a handful of utility scripts that you might find useful when working with datasets made out of nested arrays and structs.

&nbsp;

## `SnapVisualize`

*Returns:* String, a human-readable "ASCII art" diagram showing the structure of the input struct/array.

|Name     |Datatype    |Purpose                                                                       |
|---------|------------|------------------------------------------------------------------------------|
|`value`  |struct/array|Value to process for display                                                  |
|`[ascii]`|boolean     |Whether to use ASCII compatibility mode. If not specified, defaults to `false`|

&nbsp;

## `SnapForeach`

*Returns:* N/A (`undefined`)

|Name      |Datatype       |Purpose                                                            |
|----------|---------------|-------------------------------------------------------------------|
|`data`    |struct/array/ds|Data to operate on. See below                                      |
|`method`  |method         |Method to execute for each member of the data structure            |
|`[dsType]`|`ds_type_*`    |Data structure type. Not used when iterating over a struct or array|

Executes a method call for each element of the given struct/array/data structure. This iterator is shallow and will not also iterate over nested structs/arrays (though you can of course call `SnapForeach()` inside the specified method).

This function can also iterate over all members of a ds_map, ds_list, or ds_grid. You will need to specify a value for `[dsType]` to iterate over a data structure.

The specified method is passed the following parameters:

|Argument     |Purpose                                                                                                              |
|-------------|---------------------------------------------------------------------------------------------------------------------|
|`argument0`  |Value found in the given struct/array/ds                                                                             |
|`argument1`  |0-indexed index of the value e.g. `0` for the first element, `1` for the second element etc.                         |
|`[argument2]`|When iterating over structs or map, the name of the variable/key that contains the given value; otherwise `undefined`|

The order that values are sent into `method` is guaranteed for arrays and ds_lists (starting at index `0` and ascending), but is not guaranteed for structs or maps due to the behaviour of GameMaker's internal hashmap.

&nbsp;

## `SnapDeepCopy`

*Returns:* Struct or array, a deep copy of the input data respecting constructors

|Name      |Datatype    |Purpose     |
|----------|------------|------------|
|`data`    |struct/array|Data to copy|

!> This function is only available in versions of GameMaker with the native functions `static_get()` and `static_set()`.

&nbsp;

## `SnapDeepCopyLegacy`

*Returns:* Struct or array, a deep copy of the input data ignoring constructors

|Name      |Datatype    |Purpose     |
|----------|------------|------------|
|`data`    |struct/array|Data to copy|

&nbsp;

## `SnapDeepAdd`

*Returns:* N/A (`undefined`)

|Name                |Datatype    |Purpose     |
|--------------------|------------|------------|
|`source`            |struct/array|            |
|`destination`       |struct/array|            |
|`[ignoreNonNumbers]`|boolean     |            |

&nbsp;

## `SnapMerge`

*Returns:* N/A (`undefined`)

|Name               |Datatype    |Purpose                                                                                                                         |
|-------------------|------------|--------------------------------------------------------------------------------------------------------------------------------|
|`source`           |struct/array|Source struct/array to copy from                                                                                                |
|`destination`      |struct/array|Destination struct/array to copy to                                                                                             |
|`[resolveToSource]`|boolean     |Whether to prefer the source or the destination if there is a datatype conflict. Defaults to `false`, preferring the destination|

This function is designed to merge one simple tree-like structures into another. Values from the source tree are copied into the destination tree recursively. Values from the source will overwrite values in the destination, but any values that are present in the destination but not the source will be maintained. In situations where there is a datatype conflict, the `resolveToSource` argument will determine which way data is copied.

!> Structs and arrays are copied by reference. If you wish to ensure that structs and arrays copied to the destination are fresh copies, first use `SnapDeepCopy()` on the source.

&nbsp;

## `SnapShallowAdd`

*Returns:* N/A (`undefined`)

|Name                |Datatype    |Purpose     |
|--------------------|------------|------------|
|`source`            |struct/array|            |
|`destination`       |struct/array|            |
|`[ignoreNonNumbers]`|boolean     |            |

&nbsp;

## `SnapStringify`

*Returns:* String

|Name   |Datatype|Purpose     |
|-------|--------|------------|
|`value`|any     |            |

&nbsp;

## `SnapNumberToString`

*Returns:* N/A (`undefined`)

|Name   |Datatype|Purpose     |
|-------|--------|------------|
|`value`|any     |            |

&nbsp;

# Files

The following functions relate to file operations, specifically embedding or removing the UTF-8 byte order mark (BOM). This is often needed to get programs to recognise that the data in a file is encoded as UTF-8 and is helpful in avoiding communication issues.

## `SnapStringFromFile`

*Returns:* N/A (`undefined`)

|Name         |Datatype|Purpose                                                                                |
|-------------|--------|---------------------------------------------------------------------------------------|
|`filename`   |string  |Filename to read from                                                                  |
|`[removeBOM]`|boolean |Whether to remove the BOM from the start of the file (if it exists). Defaults to `true`|

&nbsp;

## `SnapStringToFile`

*Returns:* N/A (`undefined`)

|Name      |Datatype|Purpose                                                             |
|----------|--------|--------------------------------------------------------------------|
|`string`  |string  |String to write to the file                                         |
|`filename`|string  |Filename to write to                                                |
|`[addBOM]`|boolean |Whether to add the BOM to the start of the file. Defaults to `false`|

&nbsp;

## `SnapBufferWriteBOM`

*Returns:* N/A (`undefined`)

|Name    |Datatype|Purpose                   |
|--------|--------|--------------------------|
|`buffer`|buffer  |Buffer to write the BOM to|

&nbsp;

## `SnapBufferReadBOM`

*Returns:* Boolean, whether a UTF-8 byte order mark was found

|Name    |Datatype|Purpose          |
|--------|--------|-----------------|
|`buffer`|buffer  |Buffer to process|

&nbsp;

## `SnapMD5`

*Returns:* Hexadecimal string, the MD5 hash of the given struct/array

|Name   |Datatype|Purpose          |
|-------|--------|-----------------|
|`value`|any     |The value to hash|

This function can also be used on non-struct/array data, though the hash may not line up with other MD5 implementations.