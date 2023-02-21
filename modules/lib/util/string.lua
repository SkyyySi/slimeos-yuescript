local _module_0 = { }
local awful = require("awful")
local gears = require("gears")
local wibox = require("wibox")
local ruled = require("ruled")
local beautiful = require("beautiful")
local menubar = require("menubar")
local naughty = require("naughty")
local string = string
local math = math
local strip
strip = function(str, char)
	if char == nil then
		char = "%s"
	end
	return "" .. str:gsub("^" .. tostring(char) .. "+", ""):gsub(tostring(char) .. "+$", "")
end
_module_0["strip"] = strip
local join
join = function(str_list, joiner)
	if joiner == nil then
		joiner = ", "
	end
	if #str_list == 0 then
		return ""
	end
	local out = ""
	for k, str in ipairs(str_list) do
		if next(str_list, k) == nil then
			out = out .. str
		else
			out = out .. (str .. joiner)
		end
	end
	return out
end
_module_0["join"] = join
local rep
rep = function(str, n)
	if n == nil then
		n = 1
	end
	local floor = math.floor(n)
	local rest = n - floor
	local out = string.rep(str, floor)
	if rest > 0 then
		for i = 1, math.floor(rest * #str) do
			out = out .. str:sub(i, i)
		end
	end
	return out
end
_module_0["rep"] = rep
local pad_left
pad_left = function(str, len, char)
	if char == nil then
		char = " "
	end
	return str .. rep(char, len)
end
_module_0["pad_left"] = pad_left
local pad_right
pad_right = function(str, len, char)
	if char == nil then
		char = " "
	end
	return rep(char, len) .. str
end
_module_0["pad_right"] = pad_right
return _module_0
