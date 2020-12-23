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

show_debug_message(snap_to_gml(struct, true));
show_debug_message(snap_to_json(snap_from_gml(snap_to_gml(struct, true)), true, true));

var _string = @"
//Here's a comment
a = {b:10};

/*Block comment
c = -999;
*/

//In-line block comment
d = /*888*/666;";

show_debug_message(snap_from_gml(_string));