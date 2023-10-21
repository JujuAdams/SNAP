testInput = [1, 2, {}, { test: {} }, new TestGlobalConstructor()];
show_debug_message(SnapVisualize(testInput));

SnapReconstructionPack(testInput);
show_debug_message(SnapVisualize(testInput));

SnapReconstructionCleanUp(testInput);
show_debug_message(SnapVisualize(testInput));

SnapReconstructionPack(testInput, undefined, true);
show_debug_message(SnapVisualize(testInput));

var _copy = SnapDeepCopy(testInput);
show_debug_message(SnapVisualize(_copy));

SnapReconstructionUnpack(_copy);
show_debug_message(SnapVisualize(_copy));

nonGlobalConstructor = function() constructor {}

try
{
    testInput = [new nonGlobalConstructor()];
    SnapReconstructionPack(testInput);
    show_debug_message(SnapVisualize(testInput));
    show_message("Unexpected success :(");
}
catch(_error)
{
    show_debug_message("Failure success! :D");
}

try
{
    testInput = [new global.testAnonymousGlobalConstructor()];
    SnapReconstructionPack(testInput);
    show_debug_message(SnapVisualize(testInput));
    show_message("Unexpected success :(");
}
catch(_error)
{
    show_debug_message("Failure success! :D");
}