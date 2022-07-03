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

buffer = snap_to_binary(struct);
show_debug_message(buffer_base64_encode(buffer, 0, -1));
returned_data = snap_from_binary(buffer);
show_debug_message(snap_to_json(returned_data, true, true));