var _array = [
              [1, 2, 3,],
              ["a", "b", "c",],
              ["short row",],
             ];

show_debug_message(SnapBufferReadNSV(SnapBufferWriteNSV(ScratchBuffer(), _array), 0));
