show_debug_message(SnapFromCSV("1,2,3\n4,5,6\n7,8,9"));
var _string = "1,2,3\r\nhello,\"hello, world!\",hello \"\" hello,\n\"\"\"\",8,9,\n";
show_debug_message(SnapFromCSV(_string));
show_debug_message(SnapToCSV(SnapFromCSV(_string)));
show_debug_message(SnapFromCSV(SnapToCSV(SnapFromCSV(_string))));

var _csv = SnapFromCSV(_string);
_csv[0][0] = function() {};
_csv[0][1] = ptr(id);
_csv[0][2] = id;
show_debug_message(SnapToCSV(_csv));