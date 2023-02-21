os.execute("clear")
pcall(require, "luarocks.loader")
local awesome = awesome
local screen = screen
local client = client
local awful = require("awful")
awful.hotkeys_popup = require("awful.hotkeys_popup")
local gears = require("gears")
local wibox = require("wibox")
local naughty = require("naughty")
local beautiful = require("beautiful")
local menubar = require("menubar")
menubar.utils.terminal = terminal
require("awful.hotkeys_popup.keys")
naughty.connect_signal("request::display_error", function(message, startup)
	return naughty.notification({
		urgency = "critical",
		title = "Oops, an error happened " .. (function()
			if startup then
				return "during startup!"
			else
				return "at runtime!"
			end
		end)(),
		message = message
	})
end)
awful.spawn.with_line_callback([[bash -c '
inotifywait --event modify \
	--include '"'"'.*\.lua'"'"' \
	--recursive ./ \
	--monitor \
	--quiet \
	2> /dev/null
']], {
	stdout = function(line)
		return awesome.restart()
	end
})
beautiful.init(tostring(gears.filesystem.get_configuration_dir()) .. "themes/skyyysi/theme.lua")
local modules = require("modules")
local util = modules.lib.util
local terminal = os.getenv("TERMINAL") or "xterm"
local editor = os.getenv("EDITOR") or terminal .. " -e nano"
local modkey = "Mod1"
local main_menu = modules.boxes.main_menu({
	terminal = terminal
})
awful.spawn({
	"xrdb",
	"-merge",
	os.getenv("HOME") .. "/.Xresources"
})
tag.connect_signal("request::default_layouts", function()
	return awful.layout.append_default_layouts({
		awful.layout.suit.tile,
		awful.layout.suit.floating
	})
end)
screen.connect_signal("request::wallpaper", function(s)
	return awful.spawn({
		"nitrogen",
		"--restore"
	})
end)
screen.connect_signal("request::desktop_decoration", function(s)
	s.scaling_factor = 1
	awful.tag((function()
		local _accum_0 = { }
		local _len_0 = 1
		for i = 1, 10 do
			_accum_0[_len_0] = tostring(i)
			_len_0 = _len_0 + 1
		end
		return _accum_0
	end)(), s, awful.layout.layouts[1])
	s.promptbox = awful.widget.prompt()
	s.layoutbox = awful.widget.layoutbox({
		screen = s,
		buttons = {
			awful.button({ }, 1, function()
				return awful.layout.inc(1)
			end),
			awful.button({ }, 3, function()
				return awful.layout.inc(-1)
			end),
			awful.button({ }, 4, function()
				return awful.layout.inc(-1)
			end),
			awful.button({ }, 5, function()
				return awful.layout.inc(1)
			end)
		}
	})
	s.taglist = awful.widget.taglist({
		screen = s,
		filter = awful.widget.taglist.filter.all,
		buttons = {
			awful.button({ }, 1, function(t)
				return t:view_only()
			end),
			awful.button({
				modkey
			}, 1, function(t)
				if client.focus then
					return client.focus:move_to_tag(client.focus, t)
				end
			end),
			awful.button({ }, 3, awful.tag.viewtoggle),
			awful.button({
				modkey
			}, 3, function(t)
				if client.focus then
					return client.focus:toggle_tag(t)
				end
			end),
			awful.button({ }, 4, function(t)
				return awful.tag.viewprev(t.screen)
			end),
			awful.button({ }, 5, function(t)
				return awful.tag.viewnext(t.screen)
			end)
		}
	})
	s.tasklist = awful.widget.tasklist({
		screen = s,
		filter = awful.widget.tasklist.filter.currenttags,
		layout = {
			layout = wibox.layout.flex.horizontal
		},
		widget_template = {
			{
				{
					id = "icon_role",
					widget = wibox.widget.imagebox
				},
				margins = util.scale(4),
				widget = wibox.container.margin
			},
			id = "background_role",
			widget = wibox.container.background
		},
		buttons = {
			awful.button({ }, 1, function(c)
				return c:activate({
					context = "tasklist",
					action = "toggle_minimization"
				})
			end),
			awful.button({ }, 3, function()
				return awful.menu.client_list({
					theme = {
						width = util.scale(250)
					}
				})
			end),
			awful.button({ }, 4, function()
				return awful.client.focus.byidx(-1)
			end),
			awful.button({ }, 5, function()
				return awful.client.focus.byidx(1)
			end)
		}
	})
	local main_wibar_buttons = {
		buttons = {
			awful.button({ }, 3, function()
				return main_menu:toggle()
			end),
			awful.button({ }, 4, awful.tag.viewprev),
			awful.button({ }, 5, awful.tag.viewnext)
		}
	}
	s.main_wibar = awful.wibar({
		position = "top",
		screen = s,
		bg = gears.color.transparent,
		widget = modules.layouts.absolute_center({
			{
				{
					{
						awful.widget.launcher({
							image = beautiful.awesome_icon,
							menu = main_menu
						}),
						s.taglist,
						s.promptbox,
						layout = wibox.layout.fixed.horizontal
					},
					bg = beautiful.bg_normal,
					shape = function(cr, w, h)
						return gears.shape.partially_rounded_rect(cr, w, h, false, false, true, false, util.scale(10))
					end,
					widget = wibox.container.background
				},
				right = util.scale(1),
				bottom = util.scale(1),
				widget = wibox.container.margin
			},
			bg = beautiful.fg_normal,
			shape = function(cr, w, h)
				return gears.shape.partially_rounded_rect(cr, w, h, false, false, true, false, util.scale(10))
			end,
			widget = wibox.container.background
		}, {
			{
				{
					s.tasklist,
					bg = beautiful.bg_normal,
					shape = function(cr, w, h)
						return gears.shape.partially_rounded_rect(cr, w, h, false, false, true, true, util.scale(10))
					end,
					widget = wibox.container.background
				},
				id = "tasklist_border_role",
				right = util.scale(1),
				bottom = util.scale(1),
				left = util.scale(1),
				widget = wibox.container.margin
			},
			bg = beautiful.fg_normal,
			shape = function(cr, w, h)
				return gears.shape.partially_rounded_rect(cr, w, h, false, false, true, true, util.scale(10))
			end,
			widget = wibox.container.background
		}, {
			{
				{
					{
						awful.widget.keyboardlayout(),
						wibox.widget.systray(),
						wibox.widget.textclock(),
						s.layoutbox,
						layout = wibox.layout.fixed.horizontal
					},
					bg = beautiful.bg_normal,
					shape = function(cr, w, h)
						return gears.shape.partially_rounded_rect(cr, w, h, false, false, false, true, util.scale(10))
					end,
					widget = wibox.container.background
				},
				bottom = util.scale(1),
				left = util.scale(1),
				widget = wibox.container.margin
			},
			bg = beautiful.fg_normal,
			shape = function(cr, w, h)
				return gears.shape.partially_rounded_rect(cr, w, h, false, false, false, true, util.scale(10))
			end,
			widget = wibox.container.background
		}, main_wibar_buttons)
	})
	s.update_dock_tasklist_separator = function(self)
		local border_width = #self.clients > 0 and util.scale(1) or 0
		return util.for_children(self.main_wibar, "tasklist_border_role", function(child)
			child.right = border_width
			child.bottom = border_width
			child.left = border_width
			return child
		end)
	end
	s:update_dock_tasklist_separator()
	s.on_bar_refresh = function(self, callback)
		local _list_0 = s.tags
		for _index_0 = 1, #_list_0 do
			local tag = _list_0[_index_0]
			tag:connect_signal("property::selected", function(c)
				return callback()
			end)
		end
		s:connect_signal("property::clients", function(s)
			return callback()
		end)
		client.connect_signal("manage", function(c)
			return callback()
		end)
		return client.connect_signal("unmanage", function(c)
			return callback()
		end)
	end
	return s:on_bar_refresh(function()
		return s:update_dock_tasklist_separator()
	end)
end)
require("modules.settings.bindings")({
	menu = main_menu,
	modkey = modkey,
	terminal = terminal
})
require("modules.settings.rules")
return client.connect_signal("mouse::enter", function(c)
	return c:activate({
		context = "mouse_enter",
		raise = false
	})
end)
