# Grids and Arrays

&nbsp;

## `SnapBufferWriteGrid`

*Returns:* N/A (`undefined`)

|Name      |Datatype    |Purpose                             |
|----------|------------|------------------------------------|
|`buffer`  |buffer      |Buffer to write the data into       |
|`grid`    |ds_grid     |Data to encode                      |
|`datatype`|struct/array|Datatype to use to encode each datum|

The grid data will be inserted into the buffer at the current "head" position, as determined by GameMaker's native `buffer_tell()` function.

&nbsp;

## `SnapBufferReadGrid`

*Returns:* ds_grid, the data read from the buffer

|Name    |Datatype|Purpose                                                                      |
|--------|--------|-----------------------------------------------------------------------------|
|`buffer`|buffer  |Buffer to read the grid data from                                            |
|`offset`|integer |Position in the buffer to read data from, relative to the start of the buffer|

?> If you do **not** specify an offset then SNAP will modify the buffer's "head" position. This allows you to read sequential data more easily.

&nbsp;

## `SnapBufferWrite2DArray`

*Returns:* N/A (`undefined`)

|Name      |Datatype    |Purpose                             |
|----------|------------|------------------------------------|
|`buffer`  |buffer      |Buffer to write the data into       |
|`array`   |array       |Data to encode                      |
|`datatype`|struct/array|Datatype to use to encode each datum|

The array data will be inserted into the buffer at the current "head" position, as determined by GameMaker's native `buffer_tell()` function.

!> This function will only work on "rectangular" arrays where the length of each child array is the same.

&nbsp;

## `SnapBufferRead2DArray`

*Returns:* Array, the data read from the buffer

|Name    |Datatype|Purpose                                                                      |
|--------|--------|-----------------------------------------------------------------------------|
|`buffer`|buffer  |Buffer to read the grid data from                                            |
|`offset`|integer |Position in the buffer to read data from, relative to the start of the buffer|

?> If you do **not** specify an offset then SNAP will modify the buffer's "head" position. This allows you to read sequential data more easily.