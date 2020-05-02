//old_struct = {
//   a : {
//       first : "first",
//   },
//   b : 2,
//   c : 3,
//};
//
//new_struct = {
//    a : {
//        first : "hmm",
//        second : "wu!",
//    },
//    b : 3,
//    c : {
//        nested : "nested!",
//    }
//};

old_struct = [
    5,
    6,
    {
        hello : "world",
    }
];

new_struct = [
    5,
    6,
    {
        hello : "world",
        first : "yo",
        wheeee : "yoyoyoyo",
    }
];

var _diff_forward = snap_difference(old_struct, new_struct);
var _diff_back    = snap_difference(new_struct, old_struct);
show_debug_message(snap_to_json_string(_diff_forward, true, true));
show_debug_message(snap_to_json_string(_diff_back   , true, true));

snap_difference_apply(old_struct, _diff_forward);
show_debug_message(snap_to_json_string(old_struct, true, true));

snap_difference_apply(old_struct, _diff_back);
show_debug_message(snap_to_json_string(old_struct, true, true));