local _module_0 = { }
local yue = require("yue")
local Object = require("modules.lib.Object")
local Exception
do
	local _class_0
	local _parent_0 = Object
	local _base_0 = {
		default_message = "An error occurred",
		print_traceback = function(self)
			return yue.traceback("\x1b[31;1m" .. tostring(self.__class.__name) .. "\x1b[39m: " .. tostring(self.message) .. "\x1b[0m")
		end,
		raise = function(self)
			return error(self:print_traceback())
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
		__init = function(self, args)
			if args == nil then
				args = { }
			end
			do
				local _exp_0 = args.message
				if _exp_0 ~= nil then
					self.message = _exp_0
				else
					self.message = self.__class.default_message
				end
			end
		end,
		__base = _base_0,
		__name = "Exception",
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
	Exception = _class_0
end
_module_0["Exception"] = Exception
local TypeException
do
	local _class_0
	local _parent_0 = Exception
	local _base_0 = {
		default_message = "Incorrect type",
		assert = function(self, value, wanted_type)
			local actual_type = type(value)
			if actual_type ~= wanted_type then
				return self.__class({
					message = tostring(self.__class.default_message) .. " (expected a " .. tostring(wanted_type) .. ", got a " .. tostring(actual_type) .. ")"
				}):raise()
			end
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
		__init = function(self, ...)
			return _class_0.__parent.__init(self, ...)
		end,
		__base = _base_0,
		__name = "TypeException",
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
	TypeException = _class_0
end
_module_0["TypeException"] = TypeException
local ArgumentTypeException
do
	local _class_0
	local _parent_0 = TypeException
	local _base_0 = {
		default_message = "Incorrect argument type",
		assert = function(self, argument, wanted_type, index)
			local actual_type = type(value)
			if actual_type ~= wanted_type then
				return self.__class({
					message = tostring(self.__class.default_message) .. " of argument #" .. tostring(index) .. " (expected a " .. tostring(wanted_type) .. ", got a " .. tostring(actual_type) .. ")"
				}):raise()
			end
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
		__init = function(self, ...)
			return _class_0.__parent.__init(self, ...)
		end,
		__base = _base_0,
		__name = "ArgumentTypeException",
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
	ArgumentTypeException = _class_0
end
_module_0["ArgumentTypeException"] = ArgumentTypeException
return _module_0
