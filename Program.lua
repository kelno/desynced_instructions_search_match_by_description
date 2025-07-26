-- function dump(o, indent)
--   indent = indent or ""
--   if type(o) == "table" then
--     for k, v in pairs(o) do
--       local key = tostring(k)
--       if type(v) == "table" then
--         print(indent .. key .. " = {")
--         dump(v, indent .. "  ")
--         print(indent .. "}")
--       else
--         print(indent .. key .. " = " .. tostring(v))
--       end
--     end
--   else
--     print(indent .. tostring(o))
--   end
-- end

local logPrefix = "[mod:instructions_search_match_by_description] "

local function modPrint(message)
  print(logPrefix .. message)
end

local function modError(message)
  print(logPrefix .. "Error: " .. message)
end

-- End helper functions



local prog = UI.GetRegisteredLayoutClass("Program")

if not prog then
  modError("Couldn't override Program — registered class not found")
  return
end

if not type(prog.on_filter) == "function" then
  modError(logPrefix .. "Couldn't override Program:on_filter — not a function")
  return
end

if not type(prog.construct) == "construct" then
  modError(logPrefix .. "Couldn't override Program:construct — not a function")
  return
end

-- Add description to the toolbox instructions entries for filtering later
local old_construct = prog.construct
prog.construct = function(self, ...)
  old_construct(self, ...)

  -- Add description to each instruction entry
  for _, cat in ipairs(self.toolbox) do
    for _, entry in ipairs(cat.inst_list) do
      local op = entry.op
      local inst = data.instructions[op]
      if inst and inst.desc then
        entry.desc = inst.desc
      end
    end
  end
end

-- Override the on_filter function to include description matching
-- local old_on_filter = prog.on_filter
prog.on_filter = function(self, search, filter, popup_toolbox)
  if filter == "" then filter = nil end
  local ContainsStringNoCase = filter and Tool.ContainsStringNoCase
  for _, cat in ipairs(popup_toolbox or self.toolbox) do
    local showcat
    for _, inst in ipairs(cat.inst_list) do
      local title = inst.title or ""
      local desc = inst.desc or ""
      local show = not filter or
          ContainsStringNoCase(L(title), filter) or
          ContainsStringNoCase(L(desc), filter)
      inst.hidden = not show
      showcat = showcat or show
    end
    cat.hidden = not showcat
    local collapse = not filter and cat.collapsed -- auto expand all categories when filtering
    cat.inst_list.hidden = collapse
    cat.icon = collapse and "icon_small_arrow_right" or "icon_small_arrow_down"
  end
end
modPrint("Override on_filter successful")

-- Original function:
-- function Program:on_filter(search, filter, popup_toolbox)
-- 	if filter == "" then filter = nil end
-- 	local ContainsStringNoCase = filter and Tool.ContainsStringNoCase
-- 	for _,cat in ipairs(popup_toolbox or self.toolbox) do
-- 		local showcat
-- 		for _,inst in ipairs(cat.inst_list) do
-- 			local show = not filter or ContainsStringNoCase(L(inst.title or ""), filter)
-- 			inst.hidden = not show
-- 			showcat = showcat or show
-- 		end
-- 		cat.hidden = not showcat
-- 		local collapse = not filter and cat.collapsed -- auto expand all categories when filtering
-- 		cat.inst_list.hidden = collapse
-- 		cat.icon = collapse and "icon_small_arrow_right" or "icon_small_arrow_down"
-- 	end
-- end
