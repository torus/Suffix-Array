function dotest (dir)
   local idxer = sufarr.create_indexer (dir .. "/test.lua")
   sufarr.save_index (idxer, dir .. "/luatest.idx")

   local idx = sufarr.load_index (dir .. "/luatest.idx", dir .. "/test.lua")
   local lb = sufarr.search_lower_bound (idx, "index")
   local ub = sufarr.search_upper_bound (idx, "index")

   print (string.format ("%s - %s", lb, ub))

   local f = io.open (dir .. "/test.lua")

   local i = lb
   while i < ub do
      local p = sufarr.get_position (idx, i)
      f:seek ("set", p)
      local str = f:read ()
      print (string.format ("%d: %s", p, str))
      i = i + 1
   end
end
