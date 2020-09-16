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

show_debug_message(snap_to_yaml(struct, true));