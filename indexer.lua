local idx                       -- used in search
local last_title
local last_body
local last_result_count = 0
local last_pos_list = {}
local last_text_list = {}
local last_search_word = ""

function get_paragraph ()
   return last_title or "--", last_body or "---"
end

function select_item (pidxfile, srcfile, n)        -- n: 0 origin
   print ("selected: " .. n)
   local pos = last_pos_list[n + 1]
   if pos then
      local srcf = io.open (srcfile)
      local pidxf = io.open (pidxfile)

      -- local beginpos = search_begin_of_paragraph_on_file (idxf, srcf, pos)
      local beginpos = lower_bound_paragraph (pidxf, pos)

      print ("pos: " .. pos .. " beginpos: " .. beginpos)

      srcf:seek ("set", beginpos)
      local line = srcf:read ()
      last_title, last_body = line:match ("^(.-) (.*)$")

      srcf:close ()
      pidxf:close ()
   end
end

function mk_paragraph_index (idxf, srcf)
   local lb, ub = search_range (idxf, srcf, "\n")

   local dest = {0}             -- 0: beginning of the document
   for i = lb, ub - 1 do
      local pos = get_position_lua (idxf, i)
      table.insert (dest, pos)
   end
   table.sort (dest)

   return dest
end

function mkindex (pidxfile, idxfile, srcfile)
   local idxer = sufarr.create_indexer (srcfile)
   sufarr.save_index (idxer, idxfile)

   local idxf = io.open (idxfile)
   local srcf = io.open (srcfile)

   local pidx = mk_paragraph_index (idxf, srcf)
   local pidxf = io.open (pidxfile, "wb")
   for i, p in ipairs (pidx) do
      pidxf:write (sufarr.pack_pos (p + 1))
   end

   pidxf:close ()
   idxf:close ()
   srcf:close ()
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

   assert (c1 >= 0)
   assert (c2 >= 0)
   assert (c3 >= 0)
   assert (c4 >= 0)

   local pos = c1 * 0x1000000 + c2 * 0x10000 + c3 * 0x100 + c4

   return pos
end

function get_str (pos, srcf, len)
   srcf:seek ("set", pos)
   local str = srcf:read (len)

   return str
end

function lower_bound_paragraph (pidxf, pos)
   local m, mpos
   local size = pidxf:seek ("end") / 4
   local n1, n2 = 1, size + 1

   -- print (string.format ("lower_bound_paragraph: %d, %d", size, pos))

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

      mpos = get_str_pos (pidxf, m)

      -- print (string.format ("n1: %d, n2: %d, m: %d, mpos: %d", n1, n2, m, mpos))

      if mpos == pos then
         return pos
      elseif mpos < pos then
         n1 = m
      else
         n2 = m
      end
      size = n2 - n1

      if n1 == n2 - 1 then
         mpos = get_str_pos (pidxf, n1)
         break
      end
   end

   return mpos
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
   local positions = {}
   local results = {}

   local i = lb
   while i < ub do
      local pos = get_position_lua (idxf, i)

      srcf:seek ("set", pos)
      local line = srcf:read ()

      table.insert (results, line)
      table.insert (positions, pos)
      i = i + 1
      if i > lb + 10 then
         break
      end
   end

   return positions, results
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

-- search seeking on file
function search_on_file (idxfile, srcfile, word)
   if word == "" then
      last_result_count = 0
      return 0
   end

   last_search_word = word

   -- binary search
   local idxf = io.open (idxfile)
   local srcf = io.open (srcfile)

   local lb, ub = search_range (idxf, srcf, word)

   local pos_list, text_list = get_result_texts (idxf, srcf, lb, ub)
   last_pos_list = pos_list
   last_text_list = text_list
   last_result_count = ub - lb

   idxf:close ()
   srcf:close ()
   return last_result_count, unpack (text_list)
end

function previous_search_results ()
   return unpack (last_text_list)
end

function previous_search_word ()
   return last_search_word
end

function previous_result_count ()
   return last_result_count
end

---------------

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
