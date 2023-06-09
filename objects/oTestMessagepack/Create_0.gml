struct = {
    a : true,
    b : false,
    c : undefined,
    d : 1/9,
    e : 15/100,
    negative: -1,
    bigger_negative: -256,
    really_big_negative: -256000,
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
                    "M O R E",
                    function() {},
                ]
            }
        }
    ],
    test : "text!",
    test2 : "\"Hello world!\"",
    url : "https://www.jujuadams.com/",
    func : function() {},
    instance: id,
};

buffer = ScratchBuffer();
SnapBufferWriteMessagePack(buffer, struct);
show_debug_message(SnapVisualize(SnapBufferReadMessagePack(buffer, 0)));