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
-- name: mobf_set_world_setting(name,value)
--
--! @brief save a setting dedicated to a single world only
--
--! @param name key to use for storage
--! @param value to save
-------------------------------------------------------------------------------
function mobf_set_world_setting(name,value)

	--TODO replace by lua supported world settings storage
	local worldid = minetest.get_worldpath()
	local access_name = "mobf_" .. worldid .. "_ " .. name
	minetest.setting_set(access_name,value)
end

-------------------------------------------------------------------------------
-- name: mobf_get_world_setting(name,value)
--
--! @brief read a setting dedicated to a single world only
--
--! @param name key to use for storage
-------------------------------------------------------------------------------
function mobf_get_world_setting(name)

	--TODO replace by lua supported world settings storage
	local worldid = minetest.get_worldpath()	
	local access_name = "mobf_" .. worldid .. "_ " .. name
	return minetest.setting_get(access_name)
end


--!@}