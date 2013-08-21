-------------------------------------------------------------------------------
-- Mob Framework Mod by Sapier
-- 
-- You may copy, use, modify or do nearly anything except removing this
-- copyright notice. 
-- And of course you are NOT allow to pretend you have written it.
--
--! @file factions.lua
--! @brief contains factions adaption of mobf
--! @copyright Sapier
--! @author Sapier
--! @date 2013-08-21
--!
-- Contact sapier a t gmx net
-------------------------------------------------------------------------------

mobf_assert_backtrace(mobf_factions == nil)
mobf_factions = {}


-------------------------------------------------------------------------------
-- name: init()
--
--! @brief initialize mobf factions support
--! @memberof mobf_factions
--
-------------------------------------------------------------------------------
function mobf_factions.init()
	if  minetest.get_modpath("factions")then
		mobf_rtd.factions_available = true
	end
end


-------------------------------------------------------------------------------
-- name: setupmob(factionsdata)
--
--! @brief creat factions a mob may be member of
--! @memberof mobf_factions
--
--! @param factions data of mob
--
-------------------------------------------------------------------------------
function mobf_factions.setupmob(factionsdata)
	if mobf_rtd.factions_available and factionsdata ~= nil and
		factionsdata.member ~= nil then
		
		for i=1,#factionsdata.member,1 do
			if not factions.exists(factionsdata.member[i]) then
				factions.add_faction(factionsdata.member[i])
			end
		end
	end
end

-------------------------------------------------------------------------------
-- name: setupentity(entity)
--
--! @brief add a mob to it's factons
--! @memberof mobf_factions
--
--! @param entity to be added to it's factions
--
-------------------------------------------------------------------------------
function mobf_factions.setupentity(entity)
	if mobf_rtd.factions_available and entity.data.factions ~= nil and
		entity.data.factions.member ~= nil then
		
		for i=1,#entity.data.factions.member,1 do
			factions.member_add(entity.data.factions.member[i],entity)
		end
	end
end

