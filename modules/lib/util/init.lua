local _module_0 = { }
local awful = require("awful")
local gears = require("gears")
local wibox = require("wibox")
local ruled = require("ruled")
local beautiful = require("beautiful")
local menubar = require("menubar")
local naughty = require("naughty")
local lgi = require("lgi")
local gtk = lgi.require("Gtk", "3.0")
local tts = require("modules.lib.util.tts")
local string = require("modules.lib.util.string")
_module_0["string"] = string
local pretty_print
pretty_print = function(value)
	return tts.prettify(value)
end
_module_0["pretty_print"] = pretty_print
local lookup_icon
lookup_icon = function(icon_name)
	if gtk ~= nil then
		local _obj_0 = gtk.IconTheme
		if _obj_0 ~= nil then
			local _obj_1 = _obj_0.get_default()
			if _obj_1 ~= nil then
				local _obj_2 = _obj_1:lookup_icon(icon_name, 48, 0)
				if _obj_2 ~= nil then
					return _obj_2:get_filename()
				end
				return nil
			end
			return nil
		end
		return nil
	end
	return nil
end
_module_0["lookup_icon"] = lookup_icon
local lookup_gicon
lookup_gicon = function(gicon)
	local icon_name
	if gicon ~= nil then
		icon_name = gicon:to_string()
	end
	if not icon_name then
		return
	end
	if icon_name:match("/") then
		return icon_name
	end
	return lookup_icon(icon_name)
end
_module_0["lookup_gicon"] = lookup_gicon
local scaling_factor = 0.5
local dpi = beautiful.xresources.apply_dpi
local scale
scale = function(x, s)
	if s == nil then
		s = screen.primary
	end
	return scaling_factor * dpi(x * (s.scaling_factor or 1))
end
_module_0["scale"] = scale
local for_children
for_children = function(widget, id, callback)
	for _, child in ipairs(widget:get_children_by_id(id)) do
		callback(child)
	end
end
_module_0["for_children"] = for_children
return _module_0
