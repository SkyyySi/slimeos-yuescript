local awful = require("awful")
local gears = require("gears")
local wibox = require("wibox")
local ruled = require("ruled")
local menubar = require("menubar")
local naughty = require("naughty")
local util = require("modules.lib.util")
local theme_assets = require("beautiful.theme_assets")
local scale = util.scale
local themes_path = gears.filesystem.get_configuration_dir() .. "themes/skyyysi/"
local t = { }
t.font = "Source Sans Pro, Medium, " .. tostring(math.floor(scale(12)))
t.bg_normal = "#135515C822FB"
t.bg_focus = "#00008E07F911"
t.bg_urgent = "#FFFF00000F12"
t.bg_minimize = "#445744574457"
t.bg_systray = t.bg_normal
t.fg_normal = "#FFFFFAFFF499"
t.fg_focus = "#FFFFFAFFF499"
t.fg_urgent = "#FFFFFAFFF499"
t.fg_minimize = "#FFFFFAFFF499"
t.useless_gap = scale(2)
t.border_width = scale(1)
t.border_color_normal = "#000000"
t.border_color_active = "#535d6c"
t.border_color_marked = "#91231c"
local taglist_square_size
taglist_square_size = scale(4)
t.taglist_squares_sel = theme_assets.taglist_squares_sel(taglist_square_size, t.fg_normal)
t.taglist_squares_unsel = theme_assets.taglist_squares_unsel(taglist_square_size, t.fg_normal)
t.menu_height = scale(50)
t.menu_width = scale(350)
t.icon_color = t.fg_focus or "#ffffff"
local load_icon
load_icon = function(path)
	return gears.color.recolor_image(themes_path .. path, t.icon_color)
end
t.titlebar_close_button_normal = load_icon("titlebar/close_normal.png")
t.titlebar_close_button_focus = load_icon("titlebar/close_focus.png")
t.titlebar_minimize_button_normal = load_icon("titlebar/minimize_normal.png")
t.titlebar_minimize_button_focus = load_icon("titlebar/minimize_focus.png")
t.titlebar_ontop_button_normal_inactive = load_icon("titlebar/ontop_normal_inactive.png")
t.titlebar_ontop_button_focus_inactive = load_icon("titlebar/ontop_focus_inactive.png")
t.titlebar_ontop_button_normal_active = load_icon("titlebar/ontop_normal_active.png")
t.titlebar_ontop_button_focus_active = load_icon("titlebar/ontop_focus_active.png")
t.titlebar_sticky_button_normal_inactive = load_icon("titlebar/sticky_normal_inactive.png")
t.titlebar_sticky_button_focus_inactive = load_icon("titlebar/sticky_focus_inactive.png")
t.titlebar_sticky_button_normal_active = load_icon("titlebar/sticky_normal_active.png")
t.titlebar_sticky_button_focus_active = load_icon("titlebar/sticky_focus_active.png")
t.titlebar_floating_button_normal_inactive = load_icon("titlebar/floating_normal_inactive.png")
t.titlebar_floating_button_focus_inactive = load_icon("titlebar/floating_focus_inactive.png")
t.titlebar_floating_button_normal_active = load_icon("titlebar/floating_normal_active.png")
t.titlebar_floating_button_focus_active = load_icon("titlebar/floating_focus_active.png")
t.titlebar_maximized_button_normal_inactive = load_icon("titlebar/maximized_normal_inactive.png")
t.titlebar_maximized_button_focus_inactive = load_icon("titlebar/maximized_focus_inactive.png")
t.titlebar_maximized_button_normal_active = load_icon("titlebar/maximized_normal_active.png")
t.titlebar_maximized_button_focus_active = load_icon("titlebar/maximized_focus_active.png")
t.wallpaper = themes_path .. "background.jpg"
t.layout_fairh = load_icon("layouts/fairhw.png")
t.layout_fairv = load_icon("layouts/fairvw.png")
t.layout_floating = load_icon("layouts/floatingw.png")
t.layout_magnifier = load_icon("layouts/magnifierw.png")
t.layout_max = load_icon("layouts/maxw.png")
t.layout_fullscreen = load_icon("layouts/fullscreenw.png")
t.layout_tilebottom = load_icon("layouts/tilebottomw.png")
t.layout_tileleft = load_icon("layouts/tileleftw.png")
t.layout_tile = load_icon("layouts/tilew.png")
t.layout_tiletop = load_icon("layouts/tiletopw.png")
t.layout_spiral = load_icon("layouts/spiralw.png")
t.layout_dwindle = load_icon("layouts/dwindlew.png")
t.layout_cornernw = load_icon("layouts/cornernww.png")
t.layout_cornerne = load_icon("layouts/cornernew.png")
t.layout_cornersw = load_icon("layouts/cornersww.png")
t.layout_cornerse = load_icon("layouts/cornersew.png")
t.awesome_icon = theme_assets.awesome_icon(scale(64), t.bg_focus, t.fg_focus)
t.icon_theme = "Papirus-Dark"
ruled.notification.connect_signal("request::rules", function()
	return ruled.notification.append_rule({
		rule = {
			urgency = "critical"
		},
		properties = {
			bg = "#ff0000",
			fg = "#ffffff"
		}
	})
end)
return t
