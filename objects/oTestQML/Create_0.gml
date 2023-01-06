root = new ExampleClassRoot();
with(root)
{
    a = true;
    b = false;
    c = undefined;
    d = 1/9;
    e = 15/100;
    
    array = [
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
    ];
    
    test = "text!";
    test2 = "\"Hello world!\"";
    url = "https://www.jujuadams.com/";
    func = function() {};
    pointer = ptr(other.id);
    instance = other.id;
    
    array_push(children, new ExampleClassRectangle());
    array_push(children, new ExampleClassRectangle());
};

var _constructorDict = {
    "Root":      ExampleClassRoot,
    "Rectangle": ExampleClassRectangle,
};

show_debug_message(SnapToQML(root, _constructorDict));