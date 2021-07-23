a = {
    root : true,
    second_thing : 2.22222222222
}

b = {
    data : "thing",
    more_data : -42.463576357890428579687,
    array_time : ["first", "second", 3],
    struct_array : [a, a, a],
}

a.child  = b;
b.parent = a;

show_debug_message(snap_string(a));