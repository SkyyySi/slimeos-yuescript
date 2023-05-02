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
local print = print
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
local playerctl_fmt = "{{album}}\t{{mpris:artUrl}}\t{{artist}}\t{{mpris:length}}\t{{playerName}}\t{{position}}\t{{status}}\t{{title}}\t{{volume}}"
local art_path = cache_dir .. "/coverart"
local converted_art_path = art_path .. ".png"
local safe_art_path = util.string.shell_escape(art_path)
local art_script_fmt = "curl -o '" .. tostring(safe_art_path) .. "' -fsSL -- '%s'\n\nffmpeg -y -i '" .. tostring(safe_art_path) .. "' -vf " .. [["crop=w='min(min(iw\,ih)\,500)':h='min(min(iw\,ih)\,500)',scale=500:500,setsar=1"]] .. " -vframes 1 '" .. tostring(safe_art_path) .. ".png'"
local download_cover_art
do
	local previous_cover_art_url
	download_cover_art = function(url, callback)
		if url == previous_cover_art_url then
			callback(converted_art_path)
			return
		end
		previous_cover_art_url = url
		local safe_url = util.string.shell_escape(url)
		return awful.spawn.easy_async({
			"curl",
			"-o",
			art_path,
			"-fsSL",
			"--",
			url
		}, function(stdout, stderr, reason, exit_code)
			if exit_code > 0 then
				print("\027[31;1mAn error occoured while downloading the cover art:\027[0m\n -> " .. tostring(stderr))
				callback(converted_art_path)
				return
			end
			stdout, stderr, reason, exit_code = nil, nil, nil, nil
			return awful.spawn.easy_async({
				"ffmpeg",
				"-y",
				"-i",
				art_path,
				"-vf",
				[[crop=w='min(min(iw\,ih)\,500)':h='min(min(iw\,ih)\,500)',scale=500:500,setsar=1]],
				"-vframes",
				"1",
				converted_art_path
			}, function(stdout, stderr, reason, exit_code)
				if exit_code > 0 then
					print("\027[31;1mAn error occoured while converting the cover art:\027[0m\n -> " .. tostring(stderr))
				end
				return callback(converted_art_path)
			end)
		end)
	end
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
		album = tmp[1],
		art_url = util.string.strip(tmp[2]),
		artist = tmp[3],
		length = tonumber(tmp[4]) or 100,
		player_name = tmp[5],
		position = tonumber(tmp[6]) or 0,
		playing = is_playing_status_parser(tmp[7]),
		title = tmp[8],
		volume = tonumber(tmp[9]) or 0
	})
	metadata.completion = metadata.position / (metadata.length / 100)
	if (not metadata.art_url) or (metadata.art_url == "") or (metadata.art_url == old_metadata.art_url) then
		metadata.art_path = old_metadata.art_path
		metadata.art_cairo = old_metadata.art_cairo
		awesome.emit_signal("playerctl::metadata", metadata)
		old_metadata = metadata
		return
	end
	return download_cover_art(metadata.art_url, function()
		metadata.art_path = converted_art_path
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
				playerctl_fmt
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
			return awful.spawn.easy_async({
				"playerctl",
				"--list-all"
			}, function(stdout, stderr, reason, exit_code)
				if exit_code > 0 then
					return
				end
				return awesome.emit_signal("playerctl::available_players", util.string.split(stdout, "\n"))
			end)
		end
	})
end
local previous_active_player = { }
awesome.connect_signal("playerctl::available_players", function(player_list)
	local active_player = player_list[1]
	if (not active_player) or (active_player == previous_active_player) then
		return
	end
	previous_active_player = active_player
	return awesome.emit_signal("playerctl::active_player", active_player)
end)
make_metadata_update_signal_listener()
make_control_signal_listeners()
make_player_list_signal_listener()
__PLAYERCTL_SIGNALS_ALREADY_CREATED = true
