struct = {
    a : true,
    b : false,
    c : undefined,
    d : 1/9,
    e : 15/100,
    array : [
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
    url : "https://www.jujuadams.com/"
};

show_debug_message(snap_to_json_string(snap_from_json_string(snap_to_json_string(struct))));
show_debug_message(snap_to_json_string(struct, false, false));
show_debug_message(snap_to_json_string(struct, false, true ));
show_debug_message(snap_to_json_string(struct, true , false));
show_debug_message(snap_to_json_string(struct, true , true ));