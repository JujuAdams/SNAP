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

var _string = SnapToJSON(struct);

show_debug_message(SnapToJSON(SnapFromJSON(SnapToJSON(struct))));
show_debug_message(SnapToJSON(struct, false, false, true));
show_debug_message(SnapToJSON(struct, false, true ));
show_debug_message(SnapToJSON(struct, true,  false));
show_debug_message(SnapToJSON(struct, true,  true, true));

var _string = @'{
"a" : "1", //Comment
/*
"b" : "2"
*/
"c" : /*oops*/ "3",
"d": 4//done
}';

show_debug_message(SnapFromJSON(_string));