/// @param buffer

function SnapBufferWriteBOM(_buffer)
{
    buffer_write(_buffer, buffer_u32, 0x00BFBBEF);
    buffer_seek(_buffer, buffer_seek_relative, -1);
}