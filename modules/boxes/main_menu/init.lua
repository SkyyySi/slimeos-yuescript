local awful = require("awful")
local gears = require("gears")
local wibox = require("wibox")
local ruled = require("ruled")
local beautiful = require("beautiful")
local menubar = require("menubar")
local naughty = require("naughty")
local util = require("modules.lib.util")
local lgi = require("lgi")
local gio = lgi.Gio
local app_categories = {
	"AudioVideo",
	"Development",
	"Education",
	"Game",
	"Graphics",
	"Network",
	"Office",
	"Science",
	"Settings",
	"System",
	"Utility",
	"Other"
}
local create_menu_entry_for_app
create_menu_entry_for_app = function(app_info)
	return {
		app_info:get_name(),
		function()
			return app_info:launch()
		end,
		util.lookup_gicon(app_info:get_icon())
	}
end
local get_all_apps
get_all_apps = function()
	local all_apps = {
		{
			"Multimedia",
			{ },
			util.lookup_icon("applications-multimedia")
		},
		{
			"Development",
			{ },
			util.lookup_icon("applications-development")
		},
		{
			"Education",
			{ },
			util.lookup_icon("applications-education")
		},
		{
			"Games",
			{ },
			util.lookup_icon("applications-games")
		},
		{
			"Internet",
			{ },
			util.lookup_icon("applications-graphics")
		},
		{
			"Network",
			{ },
			util.lookup_icon("applications-internet")
		},
		{
			"Office",
			{ },
			util.lookup_icon("applications-office")
		},
		{
			"Science",
			{ },
			util.lookup_icon("applications-science")
		},
		{
			"Settings",
			{ },
			util.lookup_icon("preferences-desktop")
		},
		{
			"System",
			{ },
			util.lookup_icon("applications-system")
		},
		{
			"Utilities",
			{ },
			util.lookup_icon("applications-utilities")
		},
		{
			"Other",
			{ },
			util.lookup_icon("applications-other")
		}
	}
	for _, app_info in ipairs(gio.AppInfo.get_all()) do
		local _continue_0 = false
		repeat
			if app_info:get_boolean("NoDisplay") or not app_info:get_show_in() then
				_continue_0 = true
				break
			end
			local category_was_found = false
			for _, app_category in ipairs(app_info:get_string_list("Categories")) do
				for i, known_category in ipairs(app_categories) do
					if app_category == known_category then
						category_was_found = true
						do
							local _obj_0 = all_apps[i][2]
							_obj_0[#_obj_0 + 1] = create_menu_entry_for_app(app_info)
						end
						break
					end
				end
				if category_was_found then
					break
				end
			end
			if not category_was_found then
				do
					local _obj_0 = all_apps[12][2]
					_obj_0[#_obj_0 + 1] = create_menu_entry_for_app(app_info)
				end
			end
			_continue_0 = true
		until true
		if not _continue_0 then
			break
		end
	end
	for k, app_list in ipairs(all_apps) do
		table.sort(app_list[2], function(a, b)
			return a[1]:lower() < b[1]:lower()
		end)
	end
	local _accum_0 = { }
	local _len_0 = 1
	for _index_0 = 1, #all_apps do
		local app_list = all_apps[_index_0]
		if next(app_list[2]) ~= nil then
			_accum_0[_len_0] = app_list
			_len_0 = _len_0 + 1
		end
	end
	return _accum_0
end
local main_menu_items = { }
main_menu_items.awesome = {
	{
		"hotkeys",
		function()
			return awful.hotkeys_popup.show_help(nil, awful.screen.focused()), util.lookup_icon("input-keyboard-symbolic")
		end
	},
	{
		"manual",
		tostring(terminal) .. " -e man awesome",
		util.lookup_icon("help-info-symbolic")
	},
	{
		"edit config",
		tostring(editor) .. " " .. tostring(awesome.conffile),
		util.lookup_icon("edit-symbolic")
	},
	{
		"restart",
		awesome.restart,
		util.lookup_icon("system-restart-symbolic")
	},
	{
		"quit",
		(function()
			return awesome.quit()
		end),
		util.lookup_icon("exit")
	}
}
main_menu_items.apps = get_all_apps()
return function(args)
	local terminal = args.terminal or "xterm"
	local browser = args.browser or function()
		return gio.AppInfo.launch_default_for_uri("https://")
	end
	local filemanager = args.filemanager or function()
		return gio.AppInfo.launch_default_for_uri("file://" .. tostring(os.getenv('HOME')))
	end
	return awful.menu({
		items = {
			{
				"awesome",
				main_menu_items.awesome,
				beautiful.awesome_icon
			},
			{
				"Apps",
				main_menu_items.apps,
				util.lookup_icon("applications-all")
			},
			{
				"Terminal",
				terminal,
				util.lookup_icon("terminal")
			},
			{
				"Filemanager",
				filemanager,
				util.lookup_icon("system-file-manager")
			},
			{
				"Browser",
				browser,
				util.lookup_icon("browser")
			}
		}
	})
end
