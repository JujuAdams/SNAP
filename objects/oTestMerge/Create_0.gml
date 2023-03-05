a = {
    testA: 1,
    testB: 3,
    shortArray: [
        "cat",
        "dog",
    ],
    longArray: [
        "maple",
        "willow",
        "oak",
    ],
};

b = {
    testA: 2,
    //testB: 4,
    shortArray: [
        "CAT",
        "DOG",
        "MOUSE",
    ],
    longArray: [
        "MAPLE",
        "WILLOW",
    ],
};

SnapMerge(b, a);
show_debug_message(SnapToJSON(a, true, true));