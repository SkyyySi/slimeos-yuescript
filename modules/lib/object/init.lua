local object
do
	local _class_0
	local _base_0 = {
		__index = function(self, key)
			if not rawget(self, "__properties") then
				return rawget(self, key)
			end
			if type(key) == "string" then
				do
					local getter = rawget(self, "get_" .. key)
					if getter then
						return getter(self, key)
					end
				end
			end
			return rawget(self, key)
		end,
		__newindex = function(self, key, value)
			if not rawget(self, "__properties") then
				rawset(self, key, value)
				return
			end
			if type(key) == "string" then
				do
					local setter = rawget(self, "set_" .. key)
					if setter then
						setter(self, key, value)
						return
					end
				end
			end
			return rawset(self, key, value)
		end,
		__tostring = function(self)
			return "<'" .. tostring(self.__class.name) .. "' instance>"
		end
	}
	if _base_0.__index == nil then
		_base_0.__index = _base_0
	end
	_class_0 = setmetatable({
		__init = function(self, args)
			if args == nil then
				args = { }
			end
			self.__properties = args.__properties
		end,
		__base = _base_0,
		__name = "object"
	}, {
		__index = _base_0,
		__call = function(cls, ...)
			local _self_0 = setmetatable({ }, _base_0)
			cls.__init(_self_0, ...)
			return _self_0
		end
	})
	_base_0.__class = _class_0
	object = _class_0
	return _class_0
end
