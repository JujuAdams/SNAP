function SnapBufferHandleBOM(_buffer)
{
    //Byte-order mark check. This sometimes gets added if the CSV file has been editted in a text editor
	if ((buffer_get_size(_buffer) >= 4) && (buffer_peek(_buffer, buffer_tell(_buffer), buffer_u32) & 0xFFFFFF == 0xBFBBEF))
    {
		buffer_seek(_buffer, buffer_seek_relative, 3);
	}
}