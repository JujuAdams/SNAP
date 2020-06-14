a = {
    foo   : "bar",
    hello : "world",
    undef : undefined,
};

b = {
    foo   : "bar",
    hello : "world",
    undef : undefined,
};

c = {
    foo : "dedoo"
};

d = {
    foo     : "bar",
    hello   : "world",
    timothy : "dalton",
};

e = {
    foo   : "bar",
    hello : "world",
    undef : "undefined?",
};

show_debug_message(string(snap_equals(a, b)) + " === 1");
show_debug_message(string(snap_equals(a, c)) + " === 0");
show_debug_message(string(snap_equals(a, d)) + " === 0");
show_debug_message(string(snap_equals(a, e)) + " === 0");