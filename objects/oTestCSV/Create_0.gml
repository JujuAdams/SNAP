var _string = "1,2,3\r\nhello,\"hello, world!\",hello \"\" hello,\n\"\"\"\",8,9,\n";

show_debug_message(snap_from_csv(_string));
show_debug_message(snap_to_csv(snap_from_csv(_string)));
show_debug_message(snap_from_csv(snap_to_csv(snap_from_csv(_string))));

var _csv = snap_from_csv(_string);
_csv[0][0] = function() {};
_csv[0][1] = ptr(id);
_csv[0][2] = id;
show_debug_message(snap_to_csv(_csv));