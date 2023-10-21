testInput = [1, 2, {}, { test: {} }];

SnapReconstructionPack(testInput);
show_debug_message(SnapVisualize(testInput));

SnapReconstructionCleanUp(testInput);
show_debug_message(SnapVisualize(testInput));

SnapReconstructionPack(testInput);
show_debug_message(SnapVisualize(testInput));

SnapReconstructionUnpack(testInput);
show_debug_message(SnapVisualize(testInput));