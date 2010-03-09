require "sufarr"

assert (loadfile "./indexer.lua") ()

mkindex ("test/idx", "indexer.lua")
-- loadindex ("test/idx", "indexer.lua")
print (table.concat ({search_on_file ("test/idx", "indexer.lua", "idx")}, "\n"))

function test_para (idxfile, srcfile, testpos)
   local idxf = io.open (idxfile)
   local srcf = io.open (srcfile)

   local p = search_begin_of_paragraph_on_file (idxf, srcf, testpos)
   print ("p = " .. p)
   local f = io.open (srcfile)
   f:seek ("set", p)
   local line = f:read ()
   local nextp = f:seek ("cur")

   print ("nextp = " .. nextp)
   assert (p <= testpos)
   assert (nextp > testpos)
   print (line)
end

-- for i = 1, 100 do
--    test_para ("test/idx", "indexer.lua", i * 10)
-- end

test_para ("test/idx", "indexer.lua", 923)
