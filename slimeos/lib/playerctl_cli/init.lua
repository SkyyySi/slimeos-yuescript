if __PLAYERCTL_SIGNALS_ALREADY_CREATED then
	return function() end
end
local require = require
local os = os
local getmetatable = getmetatable
local setmetatable = setmetatable
local type = type
local tostring = tostring
local tonumber = tonumber
local pairs = pairs
local ipairs = ipairs
local awesome = awesome
local awful = require("awful")
local gears = require("gears")
local util = require("slimeos.lib.util")
local lgi = require("lgi")
local cairo, Playerctl = lgi.cairo, lgi.Playerctl
local cache_dir = ""
local XDG_CACHE_HOME = os.getenv("XDG_CACHE_HOME")
local HOME = os.getenv("HOME")
if XDG_CACHE_HOME and (XDG_CACHE_HOME ~= "") then
	cache_dir = XDG_CACHE_HOME .. "/awesome"
else
	cache_dir = HOME .. "/.cache/awesome"
end
awful.spawn({
	"mkdir",
	"-p",
	cache_dir
})
local art_path = cache_dir .. "/coverart"
local safe_art_path = util.string.shell_escape(art_path)
local art_script_fmt = "curl -o '" .. tostring(safe_art_path) .. "' -fsSL '%s';ffmpeg -y -i '" .. tostring(safe_art_path) .. "' '" .. tostring(safe_art_path) .. ".png'"
local gen_art_script
gen_art_script = function(metadata)
	return art_script_fmt:format(metadata.art_url)
end
local is_playing_status_parser
is_playing_status_parser = function(status_string)
	local status = false
	if status_string == "Playing" then
		status = true
	end
	awesome.emit_signal("playerctl::metadata::playing", status)
	return status
end
local PlayerctlMetadata, PlayerctlMetadata_mt = {
	__name = "PlayerctlMetadata"
}, {
	fields = {
		"album",
		"art_cairo",
		"art_path",
		"art_url",
		"artist",
		"length",
		"player_name",
		"position",
		"status",
		"title",
		"volume"
	}
}
PlayerctlMetadata.__index = PlayerctlMetadata
PlayerctlMetadata_mt.__index = PlayerctlMetadata_mt
setmetatable(PlayerctlMetadata, PlayerctlMetadata_mt)
PlayerctlMetadata.same_song_as = function(self, other)
	if not other then
		return false
	end
	if self.artist ~= other.artist then
		return false
	end
	if self.title ~= other.title then
		return false
	end
	return true
end
do
	local quote
	quote = function(value)
		local tv = type(value)
		if tv == "string" then
			return '"' .. value .. '"'
		elseif tv == "number" then
			return ("%.02f"):format(value)
		else
			return tostring(value)
		end
	end
	PlayerctlMetadata.__tostring = function(self)
		local outs
		local first
		first = true
		for k, v in pairs(self) do
			if first then
				first = false
				outs = self.__name .. " {\n    " .. k .. ": " .. quote(v)
			else
				outs = outs .. "\n    " .. k .. ": " .. quote(v)
			end
		end
		return outs .. "\n}"
	end
end
PlayerctlMetadata_mt.__call = function(cls, o)
	return setmetatable(o or { }, cls)
end
local old_metadata = { }
local send_metadata_signal
send_metadata_signal = function(line)
	if (not line) or (line == "") then
		return
	end
	local tmp = util.string.split(line, "\t")
	local metadata = PlayerctlMetadata({
		album = tmp[5],
		art_url = tmp[9],
		artist = tmp[6],
		length = tonumber(tmp[8]) or 100,
		player_name = tmp[1],
		position = tonumber(tmp[2]) or 0,
		status = is_playing_status_parser(tmp[3]) or false,
		title = tmp[7],
		volume = tonumber(tmp[4]) or 0
	})
	metadata.completion = metadata.position / (metadata.length / 100)
	if (not metadata.art_url) or (metadata.art_url == "") or (metadata.art_url == old_metadata.art_url) then
		metadata.art_path = old_metadata.art_path
		metadata.art_cairo = old_metadata.art_cairo
		awesome.emit_signal("playerctl::metadata", metadata)
		old_metadata = metadata
		return
	end
	return awful.spawn.easy_async_with_shell(gen_art_script(metadata), function(stdout, stderr, reason, exit_code)
		metadata.art_path = art_path .. ".png"
		metadata.art_cairo = cairo.ImageSurface.create_from_png(metadata.art_path)
		awesome.emit_signal("playerctl::metadata", metadata)
		old_metadata = metadata
	end)
end
local make_metadata_update_signal_listener
make_metadata_update_signal_listener = function()
	return gears.timer({
		timeout = 1,
		autostart = true,
		call_now = true,
		callback = function()
			return awful.spawn.easy_async({
				"playerctl",
				"metadata",
				"--format",
				"{{playerName}}\t{{position}}\t{{status}}\t{{volume}}\t{{album}}\t{{artist}}\t{{title}}\t{{mpris:length}}\t{{mpris:artUrl}}"
			}, function(stdout, stderr, reason, exit_code)
				return send_metadata_signal(stdout)
			end)
		end
	})
end
local make_control_signal_listeners
make_control_signal_listeners = function()
	awesome.connect_signal("playerctl::play", function()
		return awful.spawn({
			"playerctl",
			"play"
		})
	end)
	awesome.connect_signal("playerctl::pause", function()
		return awful.spawn({
			"playerctl",
			"pause"
		})
	end)
	awesome.connect_signal("playerctl::play-pause", function()
		return awful.spawn({
			"playerctl",
			"play-pause"
		})
	end)
	awesome.connect_signal("playerctl::stop", function()
		return awful.spawn({
			"playerctl",
			"stop"
		})
	end)
	awesome.connect_signal("playerctl::next", function()
		return awful.spawn({
			"playerctl",
			"next"
		})
	end)
	awesome.connect_signal("playerctl::previous", function()
		return awful.spawn({
			"playerctl",
			"previous"
		})
	end)
	return awesome.connect_signal("playerctl::volume", function()
		return awful.spawn({
			"playerctl",
			"volume"
		})
	end)
end
local make_player_list_signal_listener
make_player_list_signal_listener = function()
	return gears.timer({
		timeout = 1,
		autostart = true,
		call_now = true,
		callback = function()
			return awesome.emit_signal("playerctl::available_players", Playerctl.list_players())
		end
	})
end
local _previous_player_list = { }
awesome.connect_signal("playerctl::available_players", function(player_list)
	for index, player in ipairs(player_list) do
		if _previous_player_list[index] ~= player then
			return
		end
	end
	_previous_player_list = player_list
	local active_player
	do
		local _obj_0 = Playerctl.list_players()
		if _obj_0 ~= nil then
			do
				local _obj_1 = _obj_0[1]
				if _obj_1 ~= nil then
					active_player = _obj_1.name
				end
			end
		end
	end
	return awesome.emit_signal("playerctl::active_player", Playerctl.list_players())
end)
make_metadata_update_signal_listener()
make_control_signal_listeners()
__PLAYERCTL_SIGNALS_ALREADY_CREATED = true
