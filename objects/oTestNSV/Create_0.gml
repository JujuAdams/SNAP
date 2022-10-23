var _array = [
              [1, 2, 3,],
              ["a", "b", "c",],
              ["short row",],
             ];

show_debug_message(SnapFromNSV(SnapToNSV(SnapScratchBuffer(), _array), 0));
