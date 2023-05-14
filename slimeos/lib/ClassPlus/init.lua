local pairs  = pairs
local ipairs = ipairs
local getmetatable = getmetatable
local setmetatable = setmetatable
local tostring = tostring
local rawget = rawget
local rawset = rawset
local type = type

local export = {
	__meta = {
		__name = "ClassPlus"
	},
	__tostring = function(module)
		local memory_address = module.raw_tostring(module):match(".*: (0x%x*)")

		return ("<module '%s'%s>"):format(
			module.__name,
			(memory_address ~= nil) and " at " .. memory_address or ""
		)
	end
}
export.__index = export
export.__meta.__index = export.__meta
setmetatable(export, export.__meta)

export.metatable_events = {
	__index = true,
	__newindex = true,
	__mode = true,
	__call = true,
	__metatable = true,
	__tostring = true,
	__len = true,
	__pairs = true,
	__ipairs = true,
	__gc = true,
	__name = true,
	__close = true,
	__unm = true,
	__add = true,
	__sub = true,
	__mul = true,
	__div = true,
	__idiv = true,
	__mod = true,
	__pow = true,
	__concat = true,
	__band = true,
	__bor = true,
	__bxor = true,
	__bnot = true,
	__shl = true,
	__shr = true,
	__eq = true,
	__lt = true,
	__le = true,
}

function export.raw_tostring(obj)
	local mt = getmetatable(obj)

	if mt == nil then
		return tostring(obj)
	end

	setmetatable(obj, nil)

	local obj_str = tostring(obj)

	setmetatable(obj, mt)

	return obj_str
end


--- TODO: Update this; this doc header is out-of-date
--- Lookups in an object instance follow this schema:
---
--- 1. The instance
--- 2. The class' body  (`self.__class.__body`)
--- 3. The class itself (`self.__class`)
--- 4. Each parent class' body,  in order (`self.__class.__parents[].__body`)
--- 5. Each parent class itself, in order (`self.__class.__parents[]`)
--- 6. Each mixin, in order (`self.__class.__mixins[]`)
--- 7. The class body's `__get()`-method if it is defined
function export.body_getter(self, key)
	local mt    = getmetatable(self)
	local cls  = rawget(mt,  "__class")
	local body = rawget(cls, "__body")

	--local old_index = body.__old_index
	--if old_index then
	--	local value = old_index(self, key)
	--
	--	if value ~= nil then
	--		return value
	--	end
	--end

	--- Call the getter corrosponding to the key if it is defined
	if (type(key) == "string") and (not key:match("^get_")) and (not key:match("^_")) then
		local getter = self["get_" .. key]

		if getter ~= nil then
			local value = getter(self)

			if value ~= nil then
				return value
			end
		end
	end

	--- Lookup in the class body's `__get()`-method if it is defined
	do
		local get = body.__get

		if get ~= nil then
			local value = get(self, key)

			if value ~= nil then
				return value
			end
		end
	end

	--- Lookup in the class' body
	do
		local value = body[key]

		if value ~= nil then
			return value
		end
	end

	--- Lookup in the class itself
	do
		local value = rawget(cls, key)

		if value ~= nil then
			return value
		end
	end

	--- Lookup in each parent class' body
	for _, parent in ipairs(cls.__parents) do
		local parent_body = parent.__body

		if (parent_body ~= nil) and (parent_body[key] ~= nil) then
			return parent_body[key]
		end
	end

	--- Lookup in each parent class itself
	for _, parent in ipairs(cls.__parents) do
		local value = parent[key]

		if value ~= nil then
			return value
		end
	end

	--- Lookup in each mixin
	for _, parent in ipairs(cls.__parents) do
		local value = parent[key]

		if value ~= nil then
			return value
		end
	end
end

function export.body_setter(self, key, value)
	local mt    = getmetatable(self)
	local cls  = rawget(mt,  "__class")
	local body = rawget(cls, "__body")

	--- Call the setter corrosponding to the key if it is defined
	if (type(key) == "string") and (not key:match("^set_")) and (not key:match("^_")) then
		local setter = self["set_" .. key]

		if setter ~= nil then
			setter(self, value)
			return
		end
	end

	--- Lookup in the class body's `__set()`-method if it is defined
	do
		local set = body.__set

		if set ~= nil then
			set(self, key, value)
			return
		end
	end
end

---@class Object
---@field __new fun(cls: Object, super: fun(self: Object), ...): Object Creates an initial object and returns it.
---@field __init fun(self: Object, super: fun(self: Object), ...) Initializes an object as created and returned by `__new`.
---@field __body table<string, any> The body of the class
---@field __name string The name of the class
---@field __parents Object[] A list of parent classes
---@field __mixins Object[]|table[] A list of mixins
export.Object = {
	__body     = {
		__tostring = function(self)
			local memory_address = export.raw_tostring(self):match(".*: (0x%x*)")

			return ("<instance of '%s'%s>"):format(
				self.__class.__name,
				memory_address ~= nil and " at " .. memory_address or ""
			)
		end
	},
	__init     = function(self, ...) end,
	__new      = function(cls, ...)
		return setmetatable({}, cls.__body)
	end,
	__name     = "Object",
	__parents  = {},
	__mixins   = {},
	__index    = function(self, key)
		do
			local in_class = rawget(self, "__class")[key]

			if in_class ~= nil then
				return in_class
			end
		end

		-- This should be made redundant by __class.__meta.__index
		--do
		--	local in_body = self.__body[key]
		--
		--	if in_body ~= nil then
		--		return in_body
		--	end
		--end

		--for _, parent in ipairs(self.__class.__parents) do
		--	local in_body = parent.__body[key]
		--
		--	if in_body ~= nil then
		--		return in_body
		--	end
		--end

		return getmetatable(self)[key]
	end,
	__meta = setmetatable({
		__call     = function(cls, ...)
			local self = cls.__new(cls, ...)
			cls.__init(self, ...)
			return self
		end,
		__tostring = function(cls)
			local memory_address = export.raw_tostring(cls):match(".*: (0x%x*)")

			return ("<class '%s'%s>"):format(
				cls.__name,
				memory_address ~= nil and " at " .. memory_address or ""
			)
		end,
		__index    = function(cls, key)
			local body = rawget(cls, "__body")

			do
				local value = body[key]

				if value ~= nil then
					return value
				end
			end

			for _, parent in ipairs(rawget(cls, "__parents")) do
				local value = parent[key]

				if value ~= nil then
					return value
				end
			end
			--[[
			do
				local body = rawget(cls, "__body")

				if body ~= nil then
					local in_body = rawget(cls, "__body")[key]

					if in_body ~= nil then
						return in_body
					end
				end
			end

			do
				local parents = rawget(cls, "__parents")

				if parents == nil then
					return
				end

				for _, parent in ipairs(parents) do
					local body = rawget(parent, "__body")

					if body ~= nil then
						local in_body = body[key]

						if in_body ~= nil then
							return in_body
						end
					end
				end
			end
			--]]
		end,
		__meta_name = "ClassPlus"
	}, {
		__tostring = function(metacls)
			local memory_address = export.raw_tostring(metacls):match(".*: (0x%x*)")

			return ("<metaclass '%s'%s>"):format(
				metacls.__meta_name,
				memory_address ~= nil and " at " .. memory_address or ""
			)
		end,
	}),
}

export.Object.__class = export.Object
export.Object.__index = function(cls, key)
	return cls.Object[key]
end

setmetatable(export.Object, export.Object.__meta)

function export.super(base)
	local parents = base.__parents

	for _, parent in ipairs(parents) do
		if parent ~= nil then
			return parent
		end
	end
end

--[[ To be removed: Superceded by `export.super()`
function export.super_new(base, cls, ...)
	local parent = export.super(base)

	if parent == nil then
		return
	end

	local parent_new = parent.__new

	if parent_new == nil then
		return
	end

	return parent_new(cls, ...)
end

function export.super_init(base, self, ...)
	local parent = export.super(base)

	if parent == nil then
		return
	end

	local parent_init = parent.__init

	if parent_init == nil then
		return
	end

	parent_init(self, ...)
end
--]]

--- Reminder:
--- Mixins  are mixed into the *body* of a class
--- Parents are mixed into the class *itself*

function export.__meta.__call(module, args)
	--- {{{ Creation of a new class
	---@type Object
	local class = {}

	class.__body  = args.body or {}
	if class.__body.set_bg then
		print("From ClassPlus for " .. tostring(args.name) .. ": " .. tostring(args.body.set_bg))
	end
	class.__body.__class = class
	class.__body.__index = module.body_getter
	class.__body.__newindex = module.body_setter
	--- }}}

	--- {{{ Inheritance
	--- The body of the class, containing methods and shared varaibles. Please remember:
	--- if a variable in a body is mutable (i.e. if it is a table), that table won't
	--- be copied by value. All instances will share the same table, which means that
	--- modifiying it in one instnace also modifies it in all other instances as
	--- well as in the class itself.

	--- The parents that the class will inherit from.
	class.__parents = args.parents or { module.Object }

	--- Inherit fields from the parent class blueprints.
	for _, parent in ipairs(class.__parents) do
		for k, v in pairs(parent) do
			if (class[k] == nil) and (not k:match("^__")) then
				class[k] = v
			end
		end

		if parent.__body == nil then
			goto continue
		end

		for k, v in pairs(parent.__body) do
			if k:match("^__") and (class.__body[k] == nil) then
				class.__body[k] = v
			end
		end

		::continue::
	end
	--- }}}

	--- {{{ Essential fields
	function class.__init(self, ...)
		if args.init ~= nil then
			args.init(self, ...)
			return
		end

		module.super(class).__init(self, ...)
	end

	function class.__new(cls, ...)
		if args.new ~= nil then
			return args.new(cls, ...)
		end

		local sup = module.super(class)

		do
			local new = sup.__new

			if new ~= nil then
				return new(cls, ...)
			end
		end

		do
			local mt = getmetatable(sup)

			if not mt then
				return setmetatable({}, cls.__body)
			end

			local new = sup

			if new == nil then
				return setmetatable({}, cls.__body)
			end

			return new(cls, ...)
		end
	end

	class.__name  = args.name or module.Object.__name
	--- }}}

	--- {{{ Mixin inheritance
	class.__mixins = args.mixins or module.Object.__mixins

	for _, mixin in ipairs(class.__mixins) do
		for k, v in pairs(mixin) do
			if (k ~= "__index") and (k ~= "__newindex") and (class.__body[k] == nil) then
				class.__body[k] = v
			end
		end
	end
	--- }}}

	--- {{{ Metaclass inheritance
	--- A table of metatable fields. These will be copied into the class blueprint.
	class.__meta = args.metaclass
	if class.__meta == nil then
		for _, parent in ipairs(class.__parents) do
			if parent.__meta ~= nil then
				class.__meta = parent.__meta
				goto break_loop
			end
		end

		::break_loop::
	end

	-- To be removed because: This is wrong.
	-- --- Meta fields need to be directly inserted into the class. You'll rarely,
	-- --- if ever, need this. The only use case for this is if you want to set
	-- --- metatable events for not just class instances, but also the class blueprint
	-- --- itself, which is something you should probably avoid if you can.
	-- for k, v in pairs(class.__meta) do
	-- 	class[k] = v
	-- end

	setmetatable(class, class.__meta)
	--- }}}

	return class
end

return export
