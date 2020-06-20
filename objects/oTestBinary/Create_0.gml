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

var _base64 = "3wAAAAmhYQGlYXJyYXndAAAABAUGB98AAAACpm5lc3RlZN8AAAACpWFycmF53QAAAAOkbW9yZaRNT1JFp00gTyBSIEWmbmVzdGVkp25lc3RlZCGmc3RydWN0p3N0cnVjdCGhYgChY8ChZMs/vHHHHGWPnaFlyz/DMzMzMzMzpHRlc3SldGV4dCGldGVzdDKuIkhlbGxvIHdvcmxkISKjdXJsumh0dHBzOi8vd3d3Lmp1anVhZGFtcy5jb20v";
var _buffer = buffer_base64_decode(_base64)

show_debug_message(snap_to_json(snap_from_binary(_buffer), true, true));

//show_debug_message(snap_to_json(snap_from_binary(snap_to_binary(struct)), true, true));