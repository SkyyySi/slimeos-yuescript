-- [yue]: ./slimeos/lib/playerctl_cli/init.yue
if __PLAYERCTL_SIGNALS_ALREADY_CREATED then -- 1
	return function() end -- 2
end -- 1
local require = require -- 4
local os = os -- 5
local getmetatable = getmetatable -- 6
local setmetatable = setmetatable -- 7
local type = type -- 8
local tostring = tostring -- 9
local tonumber = tonumber -- 10
local pairs = pairs -- 11
local ipairs = ipairs -- 12
local print = print -- 13
local awesome = awesome -- 15
local awful = require("awful") -- 17
local gears = require("gears") -- 18
local util = require("slimeos.lib.util") -- 19
local lgi = require("lgi") -- 21
local cairo, Playerctl = lgi.cairo, lgi.Playerctl -- 22
local cache_dir = "" -- 24
local XDG_CACHE_HOME = os.getenv("XDG_CACHE_HOME") -- 25
local HOME = os.getenv("HOME") -- 26
if XDG_CACHE_HOME and (XDG_CACHE_HOME ~= "") then -- 28
	cache_dir = XDG_CACHE_HOME .. "/awesome" -- 29
else -- 31
	cache_dir = HOME .. "/.cache/awesome" -- 31
end -- 28
awful.spawn({ -- 33
	"mkdir", -- 33
	"-p", -- 33
	cache_dir -- 33
}) -- 33
local playerctl_fmt = "{{album}}\t{{mpris:artUrl}}\t{{artist}}\t{{mpris:length}}\t{{playerName}}\t{{position}}\t{{status}}\t{{title}}\t{{volume}}" -- 35
local art_path = cache_dir .. "/coverart" -- 39
local converted_art_path = art_path .. ".png" -- 40
local safe_art_path = util.string.shell_escape(art_path) -- 41
local art_script_fmt = "curl -o '" .. tostring(safe_art_path) .. "' -fsSL -- '%s'\n\nffmpeg -y -i '" .. tostring(safe_art_path) .. "' -vf " .. [["crop=w='min(min(iw\,ih)\,500)':h='min(min(iw\,ih)\,500)',scale=500:500,setsar=1"]] .. " -vframes 1 '" .. tostring(safe_art_path) .. ".png'" -- 42
local download_cover_art -- 44
do -- 44
	local previous_cover_art_url -- 45
	download_cover_art = function(url, callback) -- 47
		if url == previous_cover_art_url then -- 48
			callback(converted_art_path) -- 49
			return -- 50
		end -- 48
		previous_cover_art_url = url -- 52
		local safe_url = util.string.shell_escape(url) -- 54
		return awful.spawn.easy_async({ -- 56
			"curl", -- 56
			"-o", -- 56
			art_path, -- 56
			"-fsSL", -- 56
			"--", -- 56
			url -- 56
		}, function(stdout, stderr, reason, exit_code) -- 56
			if exit_code > 0 then -- 57
				print("\027[31;1mAn error occoured while downloading the cover art:\027[0m\n -> " .. tostring(stderr)) -- 58
				callback(converted_art_path) -- 59
				return -- 60
			end -- 57
			stdout, stderr, reason, exit_code = nil, nil, nil, nil -- 62
			return awful.spawn.easy_async({ -- 64
				"ffmpeg", -- 64
				"-y", -- 64
				"-i", -- 64
				art_path, -- 64
				"-vf", -- 64
				[[crop=w='min(min(iw\,ih)\,500)':h='min(min(iw\,ih)\,500)',scale=500:500,setsar=1]], -- 64
				"-vframes", -- 64
				"1", -- 64
				converted_art_path -- 64
			}, function(stdout, stderr, reason, exit_code) -- 64
				if exit_code > 0 then -- 65
					print("\027[31;1mAn error occoured while converting the cover art:\027[0m\n -> " .. tostring(stderr)) -- 66
				end -- 65
				return callback(converted_art_path) -- 68
			end) -- 69
		end) -- 70
	end -- 47
end -- 70
local is_playing_status_parser -- 72
is_playing_status_parser = function(status_string) -- 72
	local status = false -- 73
	if status_string == "Playing" then -- 75
		status = true -- 76
	end -- 75
	awesome.emit_signal("playerctl::metadata::playing", status) -- 78
	return status -- 80
end -- 72
local PlayerctlMetadata, PlayerctlMetadata_mt = { -- 83
	__name = "PlayerctlMetadata" -- 83
}, { -- 85
	fields = { -- 86
		"album", -- 86
		"art_cairo", -- 87
		"art_path", -- 88
		"art_url", -- 89
		"artist", -- 90
		"length", -- 91
		"player_name", -- 92
		"position", -- 93
		"status", -- 94
		"title", -- 95
		"volume" -- 96
	} -- 85
} -- 82
PlayerctlMetadata.__index = PlayerctlMetadata -- 99
PlayerctlMetadata_mt.__index = PlayerctlMetadata_mt -- 100
setmetatable(PlayerctlMetadata, PlayerctlMetadata_mt) -- 101
PlayerctlMetadata.same_song_as = function(self, other) -- 103
	if not other then -- 104
		return false -- 105
	end -- 104
	if self.artist ~= other.artist then -- 107
		return false -- 108
	end -- 107
	if self.title ~= other.title then -- 110
		return false -- 111
	end -- 110
	return true -- 113
end -- 103
do -- 115
	local quote -- 116
	quote = function(value) -- 116
		local tv = type(value) -- 117
		if tv == "string" then -- 119
			return '"' .. value .. '"' -- 120
		elseif tv == "number" then -- 121
			return ("%.02f"):format(value) -- 122
		else -- 124
			return tostring(value) -- 124
		end -- 119
	end -- 116
	PlayerctlMetadata.__tostring = function(self) -- 126
		local outs -- 127
		local first -- 128
		first = true -- 128
		for k, v in pairs(self) do -- 130
			if first then -- 131
				first = false -- 132
				outs = self.__name .. " {\n    " .. k .. ": " .. quote(v) -- 133
			else -- 135
				outs = outs .. "\n    " .. k .. ": " .. quote(v) -- 135
			end -- 131
		end -- 135
		return outs .. "\n}" -- 137
	end -- 126
end -- 137
PlayerctlMetadata_mt.__call = function(cls, o) -- 139
	return setmetatable(o or { }, cls) -- 140
end -- 139
local old_metadata = { } -- 142
local send_metadata_signal -- 143
send_metadata_signal = function(line) -- 143
	if (not line) or (line == "") then -- 144
		return -- 145
	end -- 144
	local tmp = util.string.split(line, "\t") -- 147
	local metadata = PlayerctlMetadata({ -- 150
		album = tmp[1], -- 150
		art_url = util.string.strip(tmp[2]), -- 151
		artist = tmp[3], -- 152
		length = tonumber(tmp[4]) or 100, -- 153
		player_name = tmp[5], -- 154
		position = tonumber(tmp[6]) or 0, -- 155
		playing = is_playing_status_parser(tmp[7]), -- 156
		title = tmp[8], -- 157
		volume = tonumber(tmp[9]) or 0 -- 158
	}) -- 149
	metadata.completion = metadata.position / (metadata.length / 100) -- 161
	if (not metadata.art_url) or (metadata.art_url == "") or (metadata.art_url == old_metadata.art_url) then -- 163
		metadata.art_path = old_metadata.art_path -- 164
		metadata.art_cairo = old_metadata.art_cairo -- 165
		awesome.emit_signal("playerctl::metadata", metadata) -- 167
		old_metadata = metadata -- 168
		return -- 169
	end -- 163
	return download_cover_art(metadata.art_url, function() -- 171
		metadata.art_path = converted_art_path -- 172
		metadata.art_cairo = cairo.ImageSurface.create_from_png(metadata.art_path) -- 173
		awesome.emit_signal("playerctl::metadata", metadata) -- 174
		old_metadata = metadata -- 175
	end) -- 176
end -- 143
local make_metadata_update_signal_listener -- 178
make_metadata_update_signal_listener = function() -- 178
	return gears.timer({ -- 180
		timeout = 1, -- 180
		autostart = true, -- 181
		call_now = true, -- 182
		callback = function() -- 183
			return awful.spawn.easy_async({ -- 185
				"playerctl", -- 185
				"metadata", -- 186
				"--format", -- 189
				playerctl_fmt -- 190
			}, function(stdout, stderr, reason, exit_code) -- 191
				return send_metadata_signal(stdout) -- 192
			end) -- 193
		end -- 183
	}) -- 194
end -- 178
local make_control_signal_listeners -- 196
make_control_signal_listeners = function() -- 196
	awesome.connect_signal("playerctl::play", function() -- 197
		return awful.spawn({ -- 197
			"playerctl", -- 197
			"play" -- 197
		}) -- 197
	end) -- 197
	awesome.connect_signal("playerctl::pause", function() -- 198
		return awful.spawn({ -- 198
			"playerctl", -- 198
			"pause" -- 198
		}) -- 198
	end) -- 198
	awesome.connect_signal("playerctl::play-pause", function() -- 199
		return awful.spawn({ -- 199
			"playerctl", -- 199
			"play-pause" -- 199
		}) -- 199
	end) -- 199
	awesome.connect_signal("playerctl::stop", function() -- 200
		return awful.spawn({ -- 200
			"playerctl", -- 200
			"stop" -- 200
		}) -- 200
	end) -- 200
	awesome.connect_signal("playerctl::next", function() -- 201
		return awful.spawn({ -- 201
			"playerctl", -- 201
			"next" -- 201
		}) -- 201
	end) -- 201
	awesome.connect_signal("playerctl::previous", function() -- 202
		return awful.spawn({ -- 202
			"playerctl", -- 202
			"previous" -- 202
		}) -- 202
	end) -- 202
	return awesome.connect_signal("playerctl::volume", function() -- 203
		return awful.spawn({ -- 203
			"playerctl", -- 203
			"volume" -- 203
		}) -- 203
	end) -- 203
end -- 196
local make_player_list_signal_listener -- 205
make_player_list_signal_listener = function() -- 205
	return gears.timer({ -- 207
		timeout = 1, -- 207
		autostart = true, -- 208
		call_now = true, -- 209
		callback = function() -- 210
			--awesome.emit_signal("playerctl::available_players", Playerctl.list_players())
			return awful.spawn.easy_async({ -- 212
				"playerctl", -- 212
				"--list-all" -- 212
			}, function(stdout, stderr, reason, exit_code) -- 212
				if exit_code > 0 then -- 213
					return -- 214
				end -- 213
				return awesome.emit_signal("playerctl::available_players", util.string.split(stdout, "\n")) -- 216
			end) -- 217
		end -- 210
	}) -- 218
end -- 205
local previous_active_player = { } -- 220
awesome.connect_signal("playerctl::available_players", function(player_list) -- 221
	--active_player = Playerctl.list_players()?[1]?.name
	local active_player = player_list[1] -- 223
	if (not active_player) or (active_player == previous_active_player) then -- 225
		return -- 226
	end -- 225
	previous_active_player = active_player -- 228
	return awesome.emit_signal("playerctl::active_player", active_player) -- 232
end) -- 221
make_metadata_update_signal_listener() -- 235
make_control_signal_listeners() -- 236
make_player_list_signal_listener() -- 237
__PLAYERCTL_SIGNALS_ALREADY_CREATED = true -- 239
