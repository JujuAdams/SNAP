# BSON

BSON is a binary version of JSON popularised by MongoDB, it is a widely used format for interchanging data across networks due to it being fast and somewhat efficient. The specifiation can be found [here](https://bsonspec.org/spec.html) and an online tester can be found [here](https://mcraiha.github.io/tools/BSONhexToJSON/bsonfiletojson.html).

?> If you're looking for a faster alternative to JSON but aren't concerned about the interoperability benefits of BSON, take a look at SNAP's [custom binary format](custom-binary).

&nbsp;

## `SnapBufferWriteBSON`

*Returns:* N/A (`undefined`)

|Name                  |Datatype    |Purpose                                                                                                                                                                  |
|----------------------|------------|-------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
|`buffer`              |buffer      |Buffer to write data to                                                                                                                                                  |
|`struct/array`        |struct/array|The data to be encoded. Can contain structs, arrays, strings, and numbers.<br>**N.B.** Will not encode ds_list, ds_map etc.                                              |
|`[alphabetizeStructs]`|boolean     |Whether to alphabetize struct variable names. Defaults to `false`. Incurs a performance penalty if set to `true`                                                         |
|`[binaryBlobType]`    |integer     |The binary blob type to use, leave as `undefined` to encode the buffer_type as 128 - 131. See `subtype` in the spec for more information<br>**N.B.** Not supported in LTS|

!> SNAP's BSON implementation does not support uint64 and float128 types.

&nbsp;

## `SnapBufferReadBSON`

*Returns:* Struct or array, the data read from the buffer

|Name                   |Datatype|Purpose                                                                                                   |
|-----------------------|--------|----------------------------------------------------------------------------------------------------------|
|`buffer`               |buffer  |Binary data to be decoded                                                                                 |
|`offset`               |integer |Position in the buffer to read data from, relative to the start of the buffer                             |
|`[skipEmbeddedBuffers]`|boolean |Whether to skip past any embedded buffers. Defaults to `false`                                            |
|`[embeddedBufferType]` |integer |Overrides the internal buffer subtype for embedded buffers, see `subtype` in the spec for more information|

?> This particular BSON reader will not validate the sizes of containers or strings.

!> SNAP's BSON implementation does not support uint64 and float128 types.