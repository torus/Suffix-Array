require "sufarr"

assert (loadfile "./indexer.lua") ()

mkindex ("test/pidx", "test/idx", "indexer.lua")
-- loadindex ("test/idx", "indexer.lua")
print (table.concat ({search_on_file ("test/idx", "indexer.lua", "idx")}, "\n"))

function test_para (pidxfile, srcfile, testpos)
   local pidxf = io.open (pidxfile)
   local srcf = io.open (srcfile)

   local p = lower_bound_paragraph (pidxf, testpos)
   -- local p = search_begin_of_paragraph_on_file (idxf, srcf, testpos)
   print ("p = " .. p)
   local f = io.open (srcfile)
   f:seek ("set", p)
   local line = f:read ()
   local nextp = f:seek ("cur")

   print ("nextp = " .. nextp)
   assert (p <= testpos)
   assert (nextp > testpos)
end

-- for i = 1, 100 do
--    test_para ("test/idx", "indexer.lua", i * 10)
-- end

test_para ("test/pidx", "indexer.lua", 923)
