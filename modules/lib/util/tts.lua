--- Pro tip: You can also use this as the actual string conversion used
--- by a table using metaprogramming, like this:
--[[
local table_to_string = require("table_to_string")

local mytable, mt = {}, {}
mt.__tostring = table_to_string
setmetatable(mytable, mt)
--]]

local math = math
local setmetatable = setmetatable
local type = type
local string = string
local tostring = tostring
local pairs = pairs

local tts = {
	-- Contains format strings
	prettify = {
		style = {
			string = '\x1b[33m"%s"\x1b[0m',
			number = "\x1b[33m%s\x1b[0m",
			["function"] = "\x1b[35;1m%s\x1b[0m",
			thread = "\x1b[35;1m%s\x1b[0m", -- coroutine
			userdata = "\x1b[36;1m%s\x1b[0m",
			table = {
				---@type string[] An array of colors that will be cycled through
				bracket = { "\x1b[35m%s\x1b[0m", "\x1b[32m%s\x1b[0m", "\x1b[36m%s\x1b[0m", },
				indent = "\x1b[2m|---\x1b[0m",
			},
		},
	},
	util = {},
	mt = {
		__call = function(self, ...)
			return self.tts(...)
		end
	},
}

do
	local mt = {}
	function mt.just_return(v)
		return v
	end

	function mt:__index(k)
		return mt.just_return
	end

	function mt:__call(v)
		return self[type(v)](v)
	end

	setmetatable(tts.prettify, mt)
end

tts.mt.__index = tts.mt
setmetatable(tts, tts.mt)

--- Replace escape sequences with their litteral representation.
---@param s string
---@return string
function tts.util.string_escape(s)
	s = s:gsub("\\", "\x1b[1m\\\\\x1b[22m")
		:gsub("\a", "\x1b[1m\\a\x1b[22m")--:gsub("\7", "\x1b[1m\\a\x1b[22m")
		:gsub("\b", "\x1b[1m\\b\x1b[22m")--:gsub("\8", "\x1b[1m\\b\x1b[22m")
		:gsub("\f", "\x1b[1m\\f\x1b[22m")--:gsub("\12", "\x1b[1m\\f\x1b[22m")
		:gsub("\n", "\x1b[1m\\n\x1b[22m")--
		:gsub("\r", "\x1b[1m\\r\x1b[22m")--:gsub("\13", "\x1b[1m\\r\x1b[22m")
		:gsub("\t", "\x1b[1m\\t\x1b[22m")--:gsub("\9", "\x1b[1m\\t\x1b[22m")
		:gsub("\v", "\x1b[1m\\v\x1b[22m")--:gsub("\11", "\x1b[1m\\v\x1b[22m")
		:gsub("\"", '\x1b[1m\\"\x1b[22m')
		:gsub("\127", "\x1b[1m\\127\x1b[22m") -- DEL / delete key

	--- See: https://www.asciitable.com/
	for i = 1, 26 do
		local c = string.char(i)
		s = s:gsub(c, "\x1b[1m\\" .. tostring(i) .. "\x1b[22m")
	end

	for i = 28, 31 do
		local c = string.char(i)
		s = s:gsub(c, "\x1b[1m\\" .. tostring(i) .. "\x1b[22m")
	end

	s = s:gsub("\127", "\x1b[1m\\127\x1b[22m")

	return s
end

---@param str string
---@param n number
---@return string
function tts.util.string_multiply(str, n)
	local outs = ""
	local floor = math.floor(n)
	local point = n - floor

	if n > 0 then
		for i = 1, n do
		outs = outs..str
		end
	end

	if point > 0 then
		local len = #str * floor
		outs = outs..str:sub(1, math.floor(len))
	end

	return outs
end

--- Cycle through a table
function tts.util.cycle(tb, i)
	return tb[((i - 1) % #tb) + 1]
end

local function bracket_color_inc(args, bracket)
	local ret = tts.util.cycle(tts.prettify.style.table.bracket, args.bracket_depth):format(bracket)
	args.bracket_depth = args.bracket_depth + 1
	return ret
end

local function bracket_color_dec(args, bracket)
	args.bracket_depth = args.bracket_depth - 1
	return tts.util.cycle(tts.prettify.style.table.bracket, args.bracket_depth):format(bracket)
end

local function in_list(list, obj)
    for _, v in ipairs(list) do
        if v == obj then
            return true
        end
    end

    return false
end

---@class tts._args
---@field table table
---@field indent string|nil
---@field depth integer|nil
---@field parent table|nil
---@field bracket_depth integer|nil
---@field encountered_tables table[]|nil

---@param args tts._args
---@return string
function tts.tts(args)
	args.table = args.table
	args.depth = args.depth or 0
	args.bracket_depth = args.bracket_depth or 1
	args.parent = args.parent
	args.encountered_tables = args.encountered_tables or {}

	if type(args.table) ~= "table" then
		return ""
	end

	local bracket_indent = tts.util.string_multiply(tts.prettify.style.table.indent, args.depth)
	local full_indent = bracket_indent..tts.prettify.style.table.indent

	if next(args.table) == nil then
		return bracket_color_inc(args, "{")..bracket_color_dec(args, "}")
	end

	local outs = bracket_color_inc(args, "{").."\n"

	for k, v in pairs(args.table) do
		local tv = type(v)
		local tk = type(k)

		if tv == "table" then
			--- Prevent infinite recursion
			if args.table == args.parent or in_list(args.encountered_tables, args.table) then
				return "\x1b[2m...\x1b[0m"
			end

        	table.insert(args.encountered_tables, args.table)

			v = tts.tts {
				table = v,
				depth = args.depth + 1,
				bracket_depth = args.bracket_depth + 1,
				parent = args.table
			}
		else
			v = tts.prettify[tv](v)
		end

		outs = ("%s%s%s%s%s = %s,\n"):format(outs, full_indent, bracket_color_inc(args, "["), tts.prettify[tk](k), bracket_color_dec(args, "]"), v, args.table)
	end

	return outs..bracket_indent..bracket_color_dec(args, "}")
end

---@param str string
function tts.prettify.string(str)
	return (tts.prettify.style.string):format(tts.util.string_escape(str))
end

---@param num number
function tts.prettify.number(num)
	return "\x1b[34m"..tostring(num).."\x1b[00m"
end

---@param func function
tts.prettify["function"] = function(func)
	return tts.prettify.style["function"]:format(func)
end

---@param th thread
function tts.prettify.thread(th)
	return tts.prettify.style.thread:format(th)
end

---@param ud userdata
function tts.prettify.userdata(ud)
	return tts.prettify.style.userdata:format(ud)
end

---@param tb table
function tts.prettify.table(tb)
	local mt = getmetatable(tb)

	--- If a table already has a string conversion, we should just
	--- use that, because this can mean that you probably should not
	--- blindly print its contents
	if mt then
		if mt.__tostring then
			return tostring(tb)
		end

		return tts({ table = tb })..",\nmetatable: "..tts({ table = mt })
	end

	return tts { table = tb }
end

return tts
