require "sufarr"

assert (loadfile "./indexer.lua") ()

mkindex ("test/idx", "indexer.lua")
loadindex ("test/idx", "indexer.lua")
print (table.concat ({search ("indexer.lua", "fun")}, ", "))
