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
			mobf_world_settings_data = minetest.deserialize(file:read("*a"))
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
			
			file:write(minetest.serialize(mobf_world_settings_data))
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