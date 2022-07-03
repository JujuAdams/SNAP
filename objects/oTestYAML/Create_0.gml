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

var _string = "{\"hello\" : \"world\", \"more\" : \"data\"}";

show_debug_message(snap_from_yaml(_string));

//show_debug_message(snap_to_yaml(struct, true));
yaml = snap_from_yaml(snap_to_yaml(struct, true));
show_debug_message(snap_to_yaml(yaml, true));
//show_debug_message(snap_to_json(yaml, true, true));