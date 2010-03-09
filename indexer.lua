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

function get_str_pos (idxf, m)
   idxf:seek ("set", (m - 1) * 4)
   local c = idxf:read (4)
   -- print (string.format ("c: %q", c))
   local c1, c2, c3, c4 = c:byte (1, 4)

   -- if c1 < 0 then c1 = 256 + c1 end
   -- if c2 < 0 then c2 = 256 + c2 end
   -- if c3 < 0 then c3 = 256 + c3 end
   -- if c4 < 0 then c4 = 256 + c4 end

   local pos = c1 * 0x1000000 + c2 * 0x10000 + c3 * 0x100 + c4

   return pos
end

function get_str (pos, srcf, len)
   srcf:seek ("set", pos)
   local str = srcf:read (len)

   return str
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

      local pos = get_str_pos (idxf, m)
      local str = get_str (pos, srcf, len)

      -- print (string.format ("str: %s, word: %s, pos: %d",
      --                       tostring (str), word, pos))

      if str:lower () < word:lower () then
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
   -- print (string.format ("c: %q", c))
   local c1, c2, c3, c4 = c:byte (1, 4)
   local pos = c1 * 0x1000000 + c2 * 0x10000 + c3 * 0x100 + c4

   return pos
end

function search_range (idxf, srcf, word)
   local size = idxf:seek ("end") / 4
   local lb = lower_bound (idxf, srcf, size, word)
   local ub = lower_bound (idxf, srcf, size, word .. "\255")

   return lb, ub
end

function get_result_texts (idxf, srcf, lb, ub)
   local results = {}

   local i = lb
   while i < ub do
      local pos = get_position_lua (idxf, i)

      srcf:seek ("set", pos)
      local line = srcf:read ()

      table.insert (results, line)
      i = i + 1
      if i > lb + 10 then
         break
      end
   end

   return unpack (results)
end

local newline_lb, newline_ub

function search_begin_of_paragraph_on_file (idxf, srcf, pos)
   if not newline_lb then
      newline_lb, newline_ub = search_range (idxf, srcf, "\n")
   end

   local maxpos = 0

   local i = newline_lb
   while i < newline_ub do
      local p = get_position_lua (idxf, i) + 1
      if p > pos then
      else
         if p == pos then
            return p
         else
            if maxpos < p then
               maxpos = p
            end
         end
      end

      i = i + 1
   end

   return maxpos
end

function search_on_file (idxfile, srcfile, word)
   if word == "" then
      return
   end

   -- binary search
   local idxf = io.open (idxfile)
   local srcf = io.open (srcfile)

   local lb, ub = search_range (idxf, srcf, word)

   return get_result_texts (idxf, srcf, lb, ub)
end

function search (srcfile, word)
   local lb = sufarr.search_lower_bound (idx, word)
   local ub = sufarr.search_upper_bound (idx, word)

   -- print (string.format ("lb: %d, ub: %d", lb, ub))

   local f = io.open (srcfile)

   local results = {}

   local i = lb
   while i < ub do
      local pos = sufarr.get_position (idx, i)

      f:seek ("set", pos)
      local line = f:read ()

      table.insert (results, line)
      i = i + 1
      if i > lb + 10 then
         break
      end
   end

   f:close ()

   return unpack (results)
end
