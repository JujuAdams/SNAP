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

var _string = SnapToQML(root, _constructorDict);
show_debug_message(_string);
show_debug_message(SnapToJSON(SnapFromQML(_string, _constructorDict), true, true, true));
show_debug_message(SnapToQML(SnapFromQML(_string, _constructorDict), _constructorDict));