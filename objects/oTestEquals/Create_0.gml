a = {
    foo : "bar",
    hello : "world",
};

b = {
    foo : "bar",
    hello : "world",
};

c = {
    foo : "dedoo"
};

d = {
    foo : "bar",
    hello : "world",
    timothy : "dalton"
};

show_debug_message(string(snap_equals(a, b)) + " === 1");
show_debug_message(string(snap_equals(a, c)) + " === 0");
show_debug_message(string(snap_equals(a, d)) + " === 0");