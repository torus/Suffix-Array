require "sufarr"
assert (loadfile "./indexer.lua") ()

mkindex ("xcode/Resources/kjv_mini.idx", "xcode/Resources/kjv_mini.txt")
