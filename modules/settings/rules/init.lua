local awful = require("awful")
local gears = require("gears")
local wibox = require("wibox")
local ruled = require("ruled")
local beautiful = require("beautiful")
local menubar = require("menubar")
local naughty = require("naughty")
ruled.client.connect_signal("request::rules", function()
	ruled.client.append_rule({
		id = "global",
		rule = { },
		properties = {
			focus = awful.client.focus.filter,
			raise = true,
			screen = awful.screen.preferred,
			placement = awful.placement.no_overlap + awful.placement.no_offscreen
		}
	})
	ruled.client.append_rule({
		id = "floating",
		rule_any = {
			instance = {
				"copyq",
				"pinentry"
			},
			class = {
				"Arandr",
				"Blueman-manager",
				"Gpick",
				"Kruler",
				"Sxiv",
				"Tor Browser",
				"Wpa_gui",
				"veromix",
				"xtightvncviewer"
			},
			name = {
				"Event Tester"
			},
			role = {
				"AlarmWindow",
				"ConfigManager",
				"pop-up"
			}
		},
		properties = {
			floating = true
		}
	})
	return ruled.client.append_rule({
		id = "titlebars",
		rule_any = {
			type = {
				"normal",
				"dialog"
			}
		},
		properties = {
			titlebars_enabled = true
		}
	})
end)
ruled.notification.connect_signal("request::rules", function()
	return ruled.notification.append_rule({
		rule = { },
		properties = {
			screen = awful.screen.preferred,
			implicit_timeout = 5
		}
	})
end)
return naughty.connect_signal("request::display", function(n)
	if n.urgency == "critical" then
		c.timeout = 0
	end
	return naughty.layout.box({
		notification = n
	})
end)
