local idx

function mkindex (dir, file)
   local idxer = sufarr.create_indexer (file)
   sufarr.save_index (idxer, dir .. "/luatest.idx")

   idx = sufarr.load_index (dir .. "/luatest.idx", file)
end

function search (dir, file, word)
   local lb = sufarr.search_lower_bound (idx, word)
   local ub = sufarr.search_upper_bound (idx, word)

   print (string.format ("%s - %s", lb, ub))

   local f = io.open (file)

   local results = {}

   local i = lb
   while i < ub do
      local p = sufarr.get_position (idx, i)
      f:seek ("set", p)
      local str = f:read ()
      print (string.format ("%d: %s", p, str))
      table.insert (results, str)
      i = i + 1
      if i > lb + 10 then
         break
      end
   end

   return unpack (results)
end
