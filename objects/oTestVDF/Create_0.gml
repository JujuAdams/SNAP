struct = {
    a : true,
    b : false,
    c : undefined,
    d : 1/9,
    e : 15/100,
    struct: {
        nested0: "hello",
        nested1: "world",
    },
    test : "text!",
    test2 : "\"Hello world!\"",
    url : "https://www.jujuadams.com/",
    func : function() {},
    pointer: ptr(id),
    instance: id,
};

show_debug_message("---------------------------------------------------------------------------------------");
show_debug_message(SnapToVDF(struct));
show_debug_message("---------------------------------------------------------------------------------------");
show_debug_message(SnapToVDF(struct, true));
show_debug_message("---------------------------------------------------------------------------------------");
show_debug_message(SnapToVDF(struct, false, true));
show_debug_message("---------------------------------------------------------------------------------------");
show_debug_message(SnapToVDF(struct, true, true));
show_debug_message("---------------------------------------------------------------------------------------");