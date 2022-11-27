struct = {
    a : true,
    b : false,
    c : undefined,
    d : 1/9,
    e : 15/100,
    array : [
        [[]],
        5,
        6,
        7,
        {
            struct : "struct!",
            nested : {
                nested : "nested!",
                array : [
                    "more",
                    "MORE",
                    "M O R E"
                ]
            }
        }
    ],
    test : "text!",
    test2 : "\"Hello world!\"",
    url : "https://www.jujuadams.com/",
    func : function() {},
    pointer: ptr(id),
    instance: id,
};

struct = {
    a: [[[]]],
}

show_debug_message("");
show_debug_message("--- Test 1 ---");
var _string = "{\"hello\" : \"world\", \"more\" : \"data\"}";
show_debug_message(SnapToYAML(SnapFromYAML(_string)));

show_debug_message("");
show_debug_message("--- Test 2 ---");
var _string = SnapToYAML(struct, true);
show_debug_message(_string);

show_debug_message("");
show_debug_message("--- Test 3 ---");
yaml = SnapFromYAML(_string);
show_debug_message(SnapToYAML(yaml, true));

show_debug_message("");
show_debug_message("--- Test 4 ---");
show_debug_message(SnapFromYAML(SnapToYAML(yaml, true), true, true));

show_debug_message("");
show_debug_message("--- Test 5 ---");
show_debug_message(SnapFromYAML("foo: some_fake_yui_code({ wish_i_could: do_this })"));

show_debug_message("");
show_debug_message("--- Test 6 ---");
show_debug_message(SnapFromYAML("foo: yui_array[2]"));