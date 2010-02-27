require "sufarr"
assert (loadfile "./indexer.lua") ()

mkindex ("xcode/Resources/kjv_mini.idx", "xcode/Resources/kjv_mini.txt")
mkindex ("xcode/Resources/kjv.idx", "xcode/Resources/kjv.txt")
