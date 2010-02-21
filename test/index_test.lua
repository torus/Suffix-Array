require "sufarr"

assert (loadfile "./indexer.lua") ()

mkindex (".", "indexer.lua")

print (table.concat ({search (".", "indexer.lua", "local")}, ", "))
