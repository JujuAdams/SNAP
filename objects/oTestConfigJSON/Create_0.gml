var _string = @"{
    a: 1
    b: 2
    b: 2.5
    c: [
        {
            a: 12
            b: 23
        }
        c
    ]
    c: [
        d
        e
        f
    ]
    
    d: {}
    d: {
        z: 26
    }
    
    e: {
        z: [
            a
        ]
    }
    
    e: {
        z: [
            b
        ]
    }
}";

var _json = SnapFromConfigJSON(_string);
show_debug_message(SnapVisualize(_json));