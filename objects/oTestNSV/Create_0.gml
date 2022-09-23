var _array = [
              [1, 2, 3,],
              ["a", "b", "c",],
              ["short row",],
             ];

var _buffer = snap_to_nsv(_array);
show_debug_message(snap_from_nsv(snap_to_nsv(_array)));
