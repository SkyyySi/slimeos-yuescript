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
local getmetatable = getmetatable
local type = type
local table = table
local string = string
local tostring = tostring
local pairs = pairs
local ipairs = ipairs
local rawget = rawget
local unpack = unpack or table.unpack

local tts = {
	-- Contains format strings
	prettify = {
		style = {
			string = '\x1b[33m"%s"\x1b[0m',
			number = "\x1b[34m%s\x1b[0m",
			["function"] = "\x1b[35;1m%s\x1b[0m",
			thread = "\x1b[35;1m%s\x1b[0m", -- coroutine
			userdata = "\x1b[36;1m%s\x1b[0m",
			table = {
				---@type string[] An array of colors that will be cycled through
				bracket = { "%s", "\x1b[35m%s\x1b[0m", "\x1b[32m%s\x1b[0m", "\x1b[36m%s\x1b[0m" },
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

	function mt:__call(v, ...)
		return self[type(v)](v, ...)
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

function tts.util.strip_colors(s)
	return s:gsub("\x1b[^m]*m", "")
end

--local terminal = require("slimeos.lib.util.terminal")
---@param obj any The object you want to estimate the length after stringyfication of 
---@param max_needed_length integer If the determined length of `obj` is longer than this, `estimate_length` will early return
---@return integer estimated_length
local function estimate_length(obj, max_needed_length)
	if max_needed_length < 0 then
		return 0
	end

	local length = 0

	local mt = getmetatable(obj)

	if mt and mt.__tostring then
		length = length + #tostring(obj)
	elseif type(obj) == "table" then
		length = length + 6 -- `+ 6`, because we also count `[] = ` and the trailing comma
		for _, v in pairs(obj) do
			length = length + estimate_length(v, max_needed_length) + 2 -- `+ 2`, because we also count ", " separation
			if length > max_needed_length then
				return length
			end
		end
	elseif type(obj) == "string" then
		length = length + #tts.util.strip_colors(obj) + 2 -- `+ 2`, because we also count quotes
	else
		length = length + #tostring(obj)
	end

	return length
end

do
	---@enum
	local keywords = {
		["and"] = true,
		["end"] = true,
		["in"] = true,
		["repeat"] = true,
		["break"] = true,
		["false"] = true,
		["local"] = true,
		["return"] = true,
		["do"] = true,
		["for"] = true,
		["nil"] = true,
		["then"] = true,
		["else"] = true,
		["function"] = true,
		["not"] = true,
		["true"] = true,
		["elseif"] = true,
		["if"] = true,
		["or"] = true,
		["until"] = true,
		["while"] = true,
	}

	function tts.util.quote_key(key, args)
		local tk = type(key)
		local key_pretty = tts.prettify[tk](key)

		if tk == "string" and not keywords[key] then
			if key:match("^[a-zA-Z_][a-zA-Z0-9_]*$") then
				return key
			end

			return key_pretty
		end

		return bracket_color_inc(args, "[") .. key_pretty .. bracket_color_dec(args, "]")
	end
end

function tts.util.get_length_of_longest_line(s)
	s = tts.util.strip_colors(s)

	if not s:match("\n") then
		return #s
	end

	local longest = 0
	local prev = 0

	for length in s:gmatch("()\n") do
		local temp = length - prev - 1
		longest = temp > longest and temp or longest
		prev = length
	end

	return longest
end

---@class tts._args
---@field table table
---@field name string|nil
---@field root_args table|nil
---@field indent string|nil
---@field depth integer|nil
---@field parent table|nil
---@field bracket_depth integer|nil
---@field encountered_tables table[]|nil
---@field max_line_length integer|nil
---@field current_outs string|nil
---@field force_long boolean|nil
---@field line_prefix string|nil
---@field ignore_tostring boolean|nil
---@field parents table[]|nil

---@param args tts._args
---@return string
function tts.tts(args)
	args.table = args.table
	args.name = args.name and (args.name .. ".") or ""
	args.depth = args.depth or 0
	args.bracket_depth = args.bracket_depth or 1
	args.parent = args.parent
	args.encountered_tables = args.encountered_tables or {}
	args.max_line_length = args.max_line_length or 80 -- terminal.geometry().width
	args.current_outs = args.current_outs or ""
	if args.force_long == nil then
		args.force_long = true
	end
	args.line_prefix = args.line_prefix or ""

	args.parents = args.parents or {}

	if not args.root_args then
		args.root_args = {}
		for k, v in pairs(args) do
			args.root_args[k] = v
		end
	end

	local bracket_indent = tts.util.string_multiply(tts.prettify.style.table.indent, args.depth)
	local full_indent = bracket_indent..tts.prettify.style.table.indent

	local spacer = "\n"
	local one_liner = false

	if not args.force_long then
		local estimated_length = estimate_length(args.table, args.max_line_length - #tts.prettify.style.table.indent * (args.depth + 1) - #args.current_outs)

		--print(estimated_length, args.max_line_length)
		if estimated_length < args.max_line_length then
			spacer = " "
			one_liner = true
		end
	end

	if next(args.table) == nil then
		return bracket_color_inc(args, "{")..bracket_color_dec(args, "}")
	end

	local outs = bracket_color_inc(args, "{")..spacer

	for k, v in pairs(args.table) do
		local tv = type(v)
		local tk = type(k)

		local line_prefix = (one_liner and "" or full_indent) .. tts.util.quote_key(k, args) .. " = "

		if tv == "table" then
			local mt_v = getmetatable(v)

			--- If a table already has a string conversion, we should just
			--- use that, because this can means that you probably should not
			--- blindly print its contents
			if (not args.ignore_tostring) and mt_v and rawget(mt_v, "__tostring") then
				v = tostring(v)
			else
				--- Prevent infinite recursion
				if (args.table == args.parent) or in_list(args.parents, args.table) or in_list(args.encountered_tables, args.table) then
					v = "\x1b[2m" .. args.name .. tostring(k) .. "\x1b[0m"
				else
					local depth_add = one_liner and 0 or 1

					v = tts.tts {
						table = v,
						name = k,
						depth = args.depth + depth_add,
						bracket_depth = args.bracket_depth + depth_add,
						parent = args.table,
						encountered_tables = args.encountered_tables,
						max_line_length = args.max_line_length,
						current_outs = outs,
						line_prefix = (one_liner and "" or bracket_indent) .. tts.util.quote_key(k, args) .. " = ",
						ignore_tostring = args.ignore_tostring,
						parents = { args.table, unpack(args.parents) },
					}
				end
			end
		else
			v = tts.prettify[tv](v)
		end

		outs = ("%s%s%s%s%s"):format(outs, line_prefix, v, (next(args.table, k) ~= nil and "," or ""), spacer)
	end

	outs = outs..(one_liner and "" or bracket_indent)..bracket_color_dec(args, "}")

	if not args.root_args.force_long then
		local longest = #tts.util.strip_colors(args.line_prefix) + tts.util.get_length_of_longest_line(outs) + #args.table
		--print(outs .. " -> " .. tostring(longest))

		if longest > args.max_line_length then
			args.root_args.force_long = true
			return tts.tts(args.root_args)
		end
	end

	return outs
end

---@param str string
function tts.prettify.string(str)
	return tts.prettify.style.string:format(tts.util.string_escape(str))
end

---@param num number
function tts.prettify.number(num)
	return tts.prettify.style.number:format(num)
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
function tts.prettify.table(tb, raw)
	local mt = getmetatable(tb)

	if mt then
		if (not raw) and mt.__tostring then
			return tostring(tb)
		end

		return tts({ table = tb, ignore_tostring = raw }).."\n\x1b[2mmetatable:\x1b[0m "..tts({ table = mt, ignore_tostring = raw })
	end

	return tts { table = tb, ignore_tostring = raw }
end

return tts
