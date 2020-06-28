var _string = "1,2,3\nhello,\"hello, world!\",hello \"\" hello,\n\"\"\"\",8,9,\n";

show_debug_message(snap_from_csv(_string));
show_debug_message(snap_to_csv(snap_from_csv(_string)));
show_debug_message(snap_from_csv(snap_to_csv(snap_from_csv(_string))));