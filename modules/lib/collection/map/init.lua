local object = require("modules.lib.object")
local util = require("modules.lib.util")
local quote_key
quote_key = function(key)
	if type(key) == "string" and key:match("^[a-zA-Z_][a-zA-Z0-9_]*$") then
		return key
	end
	return "[" .. tostring(util.pretty_print(key)) .. "]"
end
local map
do
	local _class_0
	local _parent_0 = object
	local _base_0 = {
		__tostring = function(self)
			if next(self) == nil then
				return "{}"
			end
			local out = "{ "
			for k, v in pairs(self) do
				if next(self, k) == nil then
					out = out .. tostring(quote_key(k)) .. ": " .. tostring(util.pretty_print(v)) .. " }"
				else
					out = out .. tostring(quote_key(k)) .. ": " .. tostring(util.pretty_print(v)) .. ", "
				end
			end
			return out
		end
	}
	for _key_0, _val_0 in pairs(_parent_0.__base) do
		if _base_0[_key_0] == nil and _key_0:match("^__") and not (_key_0 == "__index" and _val_0 == _parent_0.__base) then
			_base_0[_key_0] = _val_0
		end
	end
	if _base_0.__index == nil then
		_base_0.__index = _base_0
	end
	setmetatable(_base_0, _parent_0.__base)
	_class_0 = setmetatable({
		__init = function(self, items)
			if items == nil then
				items = { }
			end
			for k, v in pairs(items) do
				self[k] = v
			end
		end,
		__base = _base_0,
		__name = "map",
		__parent = _parent_0
	}, {
		__index = function(cls, name)
			local val = rawget(_base_0, name)
			if val == nil then
				local parent = rawget(cls, "__parent")
				if parent then
					return parent[name]
				end
			else
				return val
			end
		end,
		__call = function(cls, ...)
			local _self_0 = setmetatable({ }, _base_0)
			cls.__init(_self_0, ...)
			return _self_0
		end
	})
	_base_0.__class = _class_0
	if _parent_0.__inherited then
		_parent_0.__inherited(_parent_0, _class_0)
	end
	map = _class_0
	return _class_0
end
