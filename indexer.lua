local idx
-- local idxfile

function mkindex (idxfile, srcfile)
   local idxer = sufarr.create_indexer (srcfile)
   sufarr.save_index (idxer, idxfile)
end

function loadindex (idxfile_, srcfile)
   idx = sufarr.load_index (idxfile_, srcfile)
   -- idxfile = idxfile_
end

function lower_bound (idxf, srcf, size, word)
   local m
   local n1, n2 = 1, size + 1
   local len = #word

   while true do
      assert (n1 < n2)

      -- lower bound = minimum x; str(x) < word
      if math.fmod (size, 2) == 0 then
         -- even
         m = size / 2 + n1
      else
         -- odd
         m = (size + 1) / 2 + n1
      end

      assert (n1 <= m)
      assert (n2 > m)

      idxf:seek ("set", (m - 1) * 4)
      local c = idxf:read (4)
      print (string.format ("c: %q", c))
      local c1, c2, c3, c4 = c:byte (1, 4)
      local pos = c1 * 0x1000000 + c2 * 0x10000 + c3 * 0x100 + c4

      srcf:seek ("set", pos)
      local str = srcf:read (len)

      print (string.format ("word: %s, pos: %d", word, pos))

      if str < word then
         n1 = m
      else
         n2 = m
      end
      size = n2 - n1

      if n1 == n2 - 1 then
         break
      end
   end

   return n1
end

function get_position_lua (idxf, i)
   idxf:seek ("set", i * 4)
   local c = idxf:read (4)
   print (string.format ("c: %q", c))
   local c1, c2, c3, c4 = c:byte (1, 4)
   local pos = c1 * 0x1000000 + c2 * 0x10000 + c3 * 0x100 + c4

   return pos
end

function search_lua (idxfile, srcfile, word)
   -- binary search
   local idxf = io.open (idxfile)
   local srcf = io.open (srcfile)
   local size = idxf:seek ("end") / 4

   local lb = lower_bound (idxf, srcf, size, word)
   local ub = lower_bound (idxf, srcf, size, word .. "\255")

   print (string.format ("lb: %d, ub: %d", lb, ub))

   local results = {}

   local i = lb
   while i < ub do
      -- local pos = sufarr.get_position (idx, i)
      local pos = get_position_lua (idxf, i)
      local p = math.max (0, pos - 5)

      srcf:seek ("set", p)
      local line
      while not (srcf:seek () > pos) do
         line = srcf:read ()
      end

      table.insert (results, line)
      i = i + 1
      if i > lb + 10 then
         break
      end
   end

   return unpack (results)
end

function search (srcfile, word)
   local lb = sufarr.search_lower_bound (idx, word)
   local ub = sufarr.search_upper_bound (idx, word)
   local f = io.open (srcfile)
   local results = {}

   local i = lb
   while i < ub do
      local pos = sufarr.get_position (idx, i)
      local p = math.max (0, pos - 5)

      f:seek ("set", p)
      local line
      while not (f:seek () > pos) do
         line = f:read ()
      end

      table.insert (results, line)
      i = i + 1
      if i > lb + 10 then
         break
      end
   end

   return unpack (results)
end
