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

c = {
    
};

a.array  = [b, c];
b.parent = a;
c.parent = c;

var _string = SnapStringify(a);
show_debug_message(_string);

SnapStringToFile("test", "test.txt", true);
var _loaded = SnapStringFromFile("test.txt", false);
show_debug_message(_loaded);