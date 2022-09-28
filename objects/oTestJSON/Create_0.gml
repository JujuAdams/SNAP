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
    url : "https://www.jujuadams.com/",
    func : function() {},
    pointer: ptr(id),
    instance: id,
};

show_debug_message(snap_to_json(snap_from_json(snap_to_json(struct))));
show_debug_message(snap_to_json(struct, false, false));
show_debug_message(snap_to_json(struct, false, true ));
show_debug_message(snap_to_json(struct, true , false));
show_debug_message(snap_to_json(struct, true , true ));

var _string = @'{
"a" : "1", //Comment
/*
"b" : "2"
*/
"c" : /*oops*/ "3",
"d": 4//done
}';

show_debug_message(snap_from_json(_string));