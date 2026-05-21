# Tilemaps

&nbsp;

## `SnapBufferWriteTilemap`

*Returns:* N/A (`undefined`)

|Name     |Datatype|Purpose                      |
|---------|--------|-----------------------------|
|`buffer` |buffer  |Buffer to write the data into|
|`tilemap`|tilemap |Tilemap to serialize         |

Stores the contents of a tilemap in a buffer, starting at the buffer's current head position.

!> The name of the tileset to use is embedded in the tilemap data so any renamed or deleted tilesets will fail to read.

&nbsp;

## `SnapBufferReadTilemapNew`

*Returns:* N/A (`undefined`)

|Name    |Datatype|Purpose                                                                                                                                            |
|--------|--------|---------------------------------------------------------------------------------------------------------------------------------------------------|
|`buffer`|buffer  |Buffer to write the data into                                                                                                                      |
|`offset`|integer |The position in the buffer to read the tilemap from, relative to the start of the buffer. If set to `undefined`, the buffer's head position is used|
|`layer` |string  |Name of room layer to create the tilemap on                                                                                                        |

Creates a new tilemap on the given layer. The tilemap's dimensions and position will be set to whatever is in the data found in the buffer.

!> The name of the tileset to use is embedded in the tilemap data (see above) so any renamed or deleted tilesets will fail to read.

?> If you do **not** specify an offset then SNAP will modify the buffer's "head" position. This allows you to read sequential data more easily.

&nbsp;

## `SnapBufferReadTilemapOverwrite`

*Returns:* N/A (`undefined`)

|Name            |Datatype|Purpose                                                                                                                                            |
|----------------|--------|---------------------------------------------------------------------------------------------------------------------------------------------------|
|`buffer`        |buffer  |Buffer to write the data into                                                                                                                      |
|`offset`        |integer |The position in the buffer to read the tilemap from, relative to the start of the buffer. If set to `undefined`, the buffer's head position is used|
|`tilemap`       |tilemap |Tilemap whose contents this function should overwrite                                                                                              |
|`[readPosition]`|boolean |Whether to set the position of the tilemap based on the coordinates in the tilemap data. Defaults to `false` if not specified                      |

Overwrites the contents of an already existing tilemap based on data serialized by `SnapBufferWriteTilemap()`. If the width or height of the incoming tilemap is larger than the current tilemap, extra tiles will not be created. If the width or height is smaller than the current tilemap, the empty space will be set to `0` (no tile).

!> The name of the tileset to use is embedded in the tilemap data (see above) so any renamed or deleted tilesets will fail to read.

?> If you do **not** specify an offset then SNAP will modify the buffer's "head" position. This allows you to read sequential data more easily.