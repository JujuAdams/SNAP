// Feather disable all
function ScratchBuffer()
{
    return buffer_create(1024, buffer_grow, 1);
}
