local awful = require("awful")
local gears = require("gears")
local wibox = require("wibox")
local ruled = require("ruled")
local beautiful = require("beautiful")
local menubar = require("menubar")
local naughty = require("naughty")
local Tuple = require("modules.lib.collection.Tuple")
return function(args)
	if args == nil then
		args = { }
	end
	if args.menu == nil then
		args.menu = {
			show = function() end,
			hide = function() end,
			toggle = function() end
		}
	end
	if args.modkey == nil then
		args.modkey = "Mod4"
	end
	if args.terminal == nil then
		args.terminal = "xterm"
	end
	awful.mouse.append_global_mousebindings({
		awful.button({ }, 3, function()
			return args.menu:toggle()
		end),
		awful.button({ }, 4, awful.tag.viewprev),
		awful.button({ }, 5, awful.tag.viewnext)
	})
	awful.keyboard.append_global_keybindings({
		awful.key(Tuple({
			args.modkey
		}), "s", awful.hotkeys_popup.show_help, {
			description = "show help",
			group = "awesome"
		}),
		awful.key(Tuple({
			args.modkey
		}), "w", function()
			return args.menu:show(), {
				description = "show main menu",
				group = "awesome"
			}
		end),
		awful.key(Tuple({
			args.modkey,
			"Control"
		}), "r", awesome.restart, {
			description = "reload awesome",
			group = "awesome"
		}),
		awful.key(Tuple({
			args.modkey,
			"Shift"
		}), "q", awesome.quit, {
			description = "quit awesome",
			group = "awesome"
		}),
		awful.key(Tuple({
			args.modkey
		}), "x", {
			function()
				return awful.prompt.run({
					prompt = "Run Lua code: ",
					textbox = awful.screen.focused().mypromptbox.widget,
					exe_callback = awful.util.eval,
					history_path = tostring(awful.util.get_cache_dir()) .. "/history_eval"
				})
			end,
			description = "lua execute prompt",
			group = "awesome"
		}),
		awful.key(Tuple({
			args.modkey
		}), "Return", function()
			return awful.spawn(args.terminal), {
				description = "open a terminal",
				group = "launcher"
			}
		end),
		awful.key(Tuple({
			args.modkey
		}), "r", function()
			return awful.screen.focused().mypromptbox:run(), {
				description = "run prompt",
				group = "launcher"
			}
		end),
		awful.key(Tuple({
			args.modkey
		}), "p", function()
			return menubar.show(), {
				description = "show the menubar",
				group = "launcher"
			}
		end)
	})
	awful.keyboard.append_global_keybindings({
		awful.key(Tuple({
			args.modkey
		}), "Left", awful.tag.viewprev, {
			description = "view previous",
			group = "tag"
		}),
		awful.key(Tuple({
			args.modkey
		}), "Right", awful.tag.viewnext, {
			description = "view next",
			group = "tag"
		}),
		awful.key(Tuple({
			args.modkey
		}), "Escape", awful.tag.history.restore, {
			description = "go back",
			group = "tag"
		})
	})
	awful.keyboard.append_global_keybindings({
		awful.key(Tuple({
			args.modkey
		}), "j", function()
			return awful.client.focus.byidx(1, {
				description = "focus next by index",
				group = "client"
			})
		end),
		awful.key(Tuple({
			args.modkey
		}), "k", function()
			return awful.client.focus.byidx(-1, {
				description = "focus previous by index",
				group = "client"
			})
		end),
		awful.key(Tuple({
			args.modkey
		}), "Tab", {
			function()
				awful.client.focus.history.previous()
				if client.focus then
					return client.focus:raise()
				end
			end,
			description = "go back",
			group = "client"
		}),
		awful.key(Tuple({
			args.modkey,
			"Control"
		}), "j", {
			function()
				return awful.screen.focus_relative(1)
			end,
			description = "focus the next screen",
			group = "screen"
		}),
		awful.key(Tuple({
			args.modkey,
			"Control"
		}), "k", {
			function()
				return awful.screen.focus_relative(-1)
			end,
			description = "focus the previous screen",
			group = "screen"
		}),
		awful.key(Tuple({
			args.modkey,
			"Control"
		}), "n", {
			function()
				do
					local c = awful.client.restore()
					if c then
						return c:activate({
							raise = true,
							context = "key.unminimize"
						})
					end
				end
			end,
			description = "restore minimized",
			group = "client"
		})
	})
	awful.keyboard.append_global_keybindings({
		awful.key(Tuple({
			args.modkey,
			"Shift"
		}), "j", {
			function()
				return awful.client.swap.byidx(1)
			end,
			description = "swap with next client by index",
			group = "client"
		}),
		awful.key(Tuple({
			args.modkey,
			"Shift"
		}), "k", {
			function()
				return awful.client.swap.byidx(-1)
			end,
			description = "swap with previous client by index",
			group = "client"
		}),
		awful.key(Tuple({
			args.modkey
		}), "u", awful.client.urgent.jumpto, {
			description = "jump to urgent client",
			group = "client"
		}),
		awful.key(Tuple({
			args.modkey
		}), "l", {
			function()
				return awful.tag.incmwfact(0.05)
			end,
			description = "increase master width factor",
			group = "layout"
		}),
		awful.key(Tuple({
			args.modkey
		}), "h", {
			function()
				return awful.tag.incmwfact(-0.05)
			end,
			description = "decrease master width factor",
			group = "layout"
		}),
		awful.key(Tuple({
			args.modkey,
			"Shift"
		}), "h", {
			function()
				return awful.tag.incnmaster(1, nil, true)
			end,
			description = "increase the number of master clients",
			group = "layout"
		}),
		awful.key(Tuple({
			args.modkey,
			"Shift"
		}), "l", {
			function()
				return awful.tag.incnmaster(-1, nil, true)
			end,
			description = "decrease the number of master clients",
			group = "layout"
		}),
		awful.key(Tuple({
			args.modkey,
			"Control"
		}), "h", {
			function()
				return awful.tag.incncol(1, nil, true)
			end,
			description = "increase the number of columns",
			group = "layout"
		}),
		awful.key(Tuple({
			args.modkey,
			"Control"
		}), "l", {
			function()
				return awful.tag.incncol(-1, nil, true)
			end,
			description = "decrease the number of columns",
			group = "layout"
		}),
		awful.key(Tuple({
			args.modkey
		}), "space", {
			function()
				return awful.layout.inc(1)
			end,
			description = "select next",
			group = "layout"
		}),
		awful.key(Tuple({
			args.modkey,
			"Shift"
		}), "space", {
			function()
				return awful.layout.inc(-1)
			end,
			description = "select previous",
			group = "layout"
		})
	})
	awful.keyboard.append_global_keybindings({
		awful.key({
			modifiers = Tuple({
				args.modkey
			}),
			keygroup = "numrow",
			description = "only view tag",
			group = "tag",
			on_press = function(index)
				local screen = awful.screen.focused()
				local tag = screen.tags[index]
				if tag then
					return tag:view_only()
				end
			end
		}),
		awful.key({
			modifiers = Tuple({
				args.modkey,
				"Control"
			}),
			keygroup = "numrow",
			description = "toggle tag",
			group = "tag",
			on_press = function(index)
				local screen = awful.screen.focused()
				local tag = screen.tags[index]
				if tag then
					return awful.tag.viewtoggle(tag)
				end
			end
		}),
		awful.key({
			modifiers = Tuple({
				args.modkey,
				"Shift"
			}),
			keygroup = "numrow",
			description = "move focused client to tag",
			group = "tag",
			on_press = function(index)
				if client.focus then
					do
						local tag = client.focus.screen.tags[index]
						if tag then
							return client.focus:move_to_tag(tag)
						end
					end
				end
			end
		}),
		awful.key({
			modifiers = Tuple({
				args.modkey,
				"Control",
				"Shift"
			}),
			keygroup = "numrow",
			description = "toggle focused client on tag",
			group = "tag",
			on_press = function(index)
				if client.focus then
					do
						local tag = client.focus.screen.tags[index]
						if tag then
							return client.focus:toggle_tag(tag)
						end
					end
				end
			end
		}),
		awful.key({
			modifiers = Tuple({
				args.modkey
			}),
			keygroup = "numpad",
			description = "select layout directly",
			group = "layout",
			on_press = function(index)
				do
					local t = awful.screen.focused().selected_tag
					if t then
						do
							local _exp_0 = t.layouts[index]
							if _exp_0 ~= nil then
								t.layout = _exp_0
							else
								t.layout = t.layout
							end
						end
					end
				end
			end
		})
	})
	client.connect_signal("request::default_mousebindings", function()
		return awful.mouse.append_client_mousebindings({
			awful.button({ }, 1, function(c)
				return c:activate({
					context = "mouse_click"
				})
			end),
			awful.button(Tuple({
				args.modkey
			}), 1, function(c)
				return c:activate({
					context = "mouse_click",
					action = "mouse_move"
				})
			end),
			awful.button(Tuple({
				args.modkey
			}), 3, function(c)
				return c:activate({
					context = "mouse_click",
					action = "mouse_resize"
				})
			end)
		})
	end)
	return client.connect_signal("request::default_keybindings", function()
		return awful.keyboard.append_client_keybindings({
			awful.key(Tuple({
				args.modkey
			}), "f", {
				function(c)
					c.fullscreen = not c.fullscreen
					return c:raise()
				end,
				description = "toggle fullscreen",
				group = "client"
			}),
			awful.key(Tuple({
				args.modkey,
				"Shift"
			}), "c", function(c)
				return c:kill(), {
					description = "close",
					group = "client"
				}
			end),
			awful.key(Tuple({
				args.modkey,
				"Control"
			}), "space", awful.client.floating.toggle, {
				description = "toggle floating",
				group = "client"
			}),
			awful.key(Tuple({
				args.modkey,
				"Control"
			}), "Return", function(c)
				return c:swap(awful.client.getmaster(), {
					description = "move to master",
					group = "client"
				})
			end),
			awful.key(Tuple({
				args.modkey
			}), "o", function(c)
				return c:move_to_screen(), {
					description = "move to screen",
					group = "client"
				}
			end),
			awful.key(Tuple({
				args.modkey
			}), "t", (function(c)
				c.ontop = not c.ontop
			end), {
				description = "toggle keep on top",
				group = "client"
			}),
			awful.key(Tuple({
				args.modkey
			}), "n", {
				function(c)
					c.minimized = true
				end,
				description = "minimize",
				group = "client"
			}),
			awful.key(Tuple({
				args.modkey
			}), "m", {
				function(c)
					c.maximized = not c.maximized
					return c:raise()
				end,
				description = "(un)maximize",
				group = "client"
			}),
			awful.key(Tuple({
				args.modkey,
				"Control"
			}), "m", {
				function(c)
					c.maximized_vertical = not c.maximized_vertical
					return c:raise()
				end,
				description = "(un)maximize vertically",
				group = "client"
			}),
			awful.key(Tuple({
				args.modkey,
				"Shift"
			}), "m", {
				function(c)
					c.maximized_horizontal = not c.maximized_horizontal
					return c:raise()
				end,
				description = "(un)maximize horizontally",
				group = "client"
			})
		})
	end)
end
