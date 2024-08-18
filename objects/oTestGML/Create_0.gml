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

show_debug_message(SnapToGML(struct, true));
show_debug_message(SnapVisualize(SnapFromGML(SnapToGML(struct, true))));

SnapEnvGMLSetToken("TestVar", 4);
SnapEnvGMLSetTokenFunction("TestVarFunc", function()
{
    return 0.1;
});
SnapEnvGMLSetToken("max", max);
SnapEnvGMLSetToken("TestFunc", function()
{
    if (argument_count <= 0) return undefined;
    
    var _max = argument[0];
    var _i = 1;
    repeat(argument_count-1)
    {
        _max = max(argument[_i], _max);
        ++_i;
    }
    
    return _max;
});

var _string = @"
c = 2000 + TestVar + TestVarFunc + TestFunc(100, 120, 110) + max(100, 120, 110)";

show_debug_message(SnapVisualize(SnapFromGML(_string)));