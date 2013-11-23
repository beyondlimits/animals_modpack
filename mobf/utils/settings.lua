-------------------------------------------------------------------------------
-- Mob Framework Mod by Sapier
--
-- You may copy, use, modify or do nearly anything except removing this
-- copyright notice.
-- And of course you are NOT allow to pretend you have written it.
--
--! @file settings.lua
--! @brief generic functions used in many different places
--! @copyright Sapier
--! @author Sapier
--! @date 2013-02-04
--!
-- Contact sapier a t gmx net
-------------------------------------------------------------------------------

--! @defgroup gen_func Generic functions
--! @brief functions for various tasks
--! @ingroup framework_int
--! @{

-------------------------------------------------------------------------------
-- name: mobf_init_world_specific_settings(name,value)
--
--! @brief check if world specific settings are supported by core if not do in lua
--
-------------------------------------------------------------------------------
function mobf_init_world_specific_settings()
	local mobf_world_settings_data = nil

	if minetest.world_setting_set == nil or
		type(minetest.world_setting_set) ~= "function" then

		local mobf_world_path = minetest.get_worldpath()

		--initialy read settings file
		mobf_world_settings_data = nil
		local file,error = io.open(mobf_world_path .. "/mobf_settings.conf","r")

		if error ~= nil then
			minetest.log(LOGLEVEL_WARNING,"MOBF: failed to open world specific config file")
			mobf_world_settings_data = {}
		else
			local data_raw = file:read("*a")

			data_raw=data_raw:gsub("\n","")
			mobf_world_settings_data = minetest.deserialize(data_raw)
			file:close()
		end

		--set world settings function
		minetest.world_setting_set = function(name,value)
			mobf_world_settings_data[name] = value

			local file,error = io.open(mobf_world_path .. "/mobf_settings.conf","w")

			if error ~= nil then
				minetest.log(LOGLEVEL_ERROR,"MOBF: failed to open world specific config file")
			end
			mobf_assert_backtrace(file ~= nil)

			local serialized_data = minetest.serialize(mobf_world_settings_data)

			local prefix=""
			local lastwasnewline = false
			local commahandled = false
			local got_non_space_char = false

			for i = 1, #serialized_data do
				local c = serialized_data:sub(i,i)

				if (c == "{") then
					if not lastwasnewline then
						file:write("\n")
					end
					file:write(prefix .. c .. "\n")
					prefix = prefix .. "    "
					lastwasnewline = true
					got_non_space_char = false
				elseif (c == "}") then
					if not lastwasnewline then
						file:write("\n")
					end
					prefix = prefix:sub(1,#prefix-4)
					local nextchar = serialized_data:sub(i+1,i+1)
					if nextchar == "," then
						file:write(prefix .. c ..nextchar .. "\n")
						commahandled = true
					else
						file:write(prefix .. c .. "\n")
					end
					got_non_space_char = false
					lastwasnewline = true
				elseif (c == ",") then
					if not commahandled then
						file:write(c .. "\n")
					end
					commahandled = false
					lastwasnewline = true
					got_non_space_char = false
				elseif (c == " ") then
					if got_non_space_char then
						file:write(c)
					end
				else
					if lastwasnewline then
						file:write(prefix)
					end
					file:write(c)
					lastwasnewline = false
					got_non_space_char = true
				end
			end
			file:write("\n")
			file:close()
		end

		minetest.world_setting_get = function(name)
			mobf_assert_backtrace(mobf_world_settings_data ~= nil)

			return mobf_world_settings_data[name]
		end
	end
end

-------------------------------------------------------------------------------
-- name: mobf_set_world_setting(name,value)
--
--! @brief save a setting dedicated to a single world only
--
--! @param name key to use for storage
--! @param value to save
-------------------------------------------------------------------------------
function mobf_set_world_setting(name,value)
	minetest.world_setting_set(name,value)
end

-------------------------------------------------------------------------------
-- name: mobf_get_world_setting(name,value)
--
--! @brief read a setting dedicated to a single world only
--
--! @param name key to use for storage
-------------------------------------------------------------------------------
function mobf_get_world_setting(name)
	return minetest.world_setting_get(name)
end

mobf_init_world_specific_settings()

--!@}