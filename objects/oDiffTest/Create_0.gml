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

var _diff =  snap_difference(old_struct, new_struct);
show_debug_message(snap_to_json_string(_diff, true, true, true));

snap_difference_apply(old_struct, _diff);

show_debug_message(snap_to_json_string(old_struct, true, true, true));