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
    test : "text! ",
    test2: " text!",
    test3 : "\"Hello world!\"",
    url : "https://www.jujuadams.com/",
    func : function() {},
    pointer: ptr(id),
    instance: id,
};

var _string = SnapToLooseJSON(struct);
show_debug_message(_string);
output = SnapFromLooseJSON(_string);

show_debug_message(SnapToLooseJSON(SnapFromLooseJSON(SnapToLooseJSON(struct))));
show_debug_message(SnapToLooseJSON(struct, false, false, true));
show_debug_message(SnapToLooseJSON(struct, false, true ));
show_debug_message(SnapToLooseJSON(struct, true,  false));
show_debug_message(SnapToLooseJSON(struct, true,  true, true));

var _string = @'{
a: 1 //Comment
/*
b: "2"
*/
c: /*oops*/3,
d: 4//done
e: "string!            //"';
_string += "\nf: @'multiline\n\nstring'\n}";

show_debug_message(SnapFromLooseJSON(_string));

var _output = SnapFromLooseJSON("{\"f\":\"a\\\\b\"}");
show_debug_message(_output);

var _output = SnapFromLooseJSON("{[a,b]:{value:c,other value:d}}");
_output.b.value = "e";
show_debug_message(_output);