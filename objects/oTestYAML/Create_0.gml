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
};

var _string = "-\n- - a\n  - b\n-\n-\n- b";

//var _string = @"- 
//- - a
//  - 
//- 
//- 
//- b";

//show_debug_message(snap_to_yaml(struct, true));
show_debug_message(snap_from_yaml(_string));