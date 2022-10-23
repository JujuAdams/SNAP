function SnapScratchBuffer()
{
    return buffer_create(1024, buffer_grow, 1);
}