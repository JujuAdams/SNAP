/// @param buffer
/// 
/// @jujuadams 2022-10-30

function SnapBufferWriteBOM(_buffer)
{
    buffer_write(_buffer, buffer_u8, 0xEF);
    buffer_write(_buffer, buffer_u8, 0xBB);
    buffer_write(_buffer, buffer_u8, 0xBF);
}