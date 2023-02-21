local _module_0 = { }
local math = math
local String
String = function(args)
	if args == nil then
		args = { }
	end
	if args.max_length == nil then
		args.max_length = 30
	end
	if args.min_length == nil then
		args.min_length = args.max_length
	end
	if args.lowest_char == nil then
		args.lowest_char = 32
	end
	if args.highest_char == nil then
		args.highest_char = 127
	end
	if args.seed == nil then
		args.seed = 0
	end
	math.randomseed(os.clock())
	local str = ""
	local _list_0 = (function()
		local _accum_0 = { }
		local _len_0 = 1
		for i = 1, math.random(args.min_length, args.max_length) do
			_accum_0[_len_0] = string.char(math.random(args.lowest_char, args.highest_char))
			_len_0 = _len_0 + 1
		end
		return _accum_0
	end)()
	for _index_0 = 1, #_list_0 do
		local char = _list_0[_index_0]
		str = str .. char
	end
	return str
end
_module_0["String"] = String
local Number
Number = function(args)
	if args == nil then
		args = { }
	end
	if args.floor == nil then
		args.floor = 0
	end
	if args.cieling == nil then
		args.cieling = 100000
	end
	if args.use_decimals == nil then
		args.use_decimals = true
	end
	math.randomseed(os.clock())
	if args.use_decimals then
		return math.random() + math.random(args.floor, args.cieling)
	else
		return math.random(args.floor, args.cieling)
	end
end
_module_0["Number"] = Number
local Table
Table = function(args)
	if args == nil then
		args = { }
	end
	if args.keys == nil then
		args.keys = {
			"number",
			"string"
		}
	end
	if args.values == nil then
		args.values = {
			"number",
			"string"
		}
	end
	if args.length == nil then
		args.length = 30
	end
	if args.constructors == nil then
		args.constructors = { }
	end
	local _obj_0 = args.constructors
	if _obj_0.number == nil then
		_obj_0.number = function()
			return Number()
		end
	end
	local _obj_1 = args.constructors
	if _obj_1.string == nil then
		_obj_1.string = function()
			return String()
		end
	end
	math.randomseed(os.clock())
	local out = { }
	for i = 1, args.length do
		out[args.constructors[args.keys[math.random(1, #args.keys)]]()] = (function()
			math.randomseed(os.clock() + 0.1)
			return args.constructors[args.values[math.random(1, #args.values)]]()
		end)()
	end
	return out
end
_module_0["Table"] = Table
return _module_0
