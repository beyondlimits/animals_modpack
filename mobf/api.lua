-------------------------------------------------------------------------------
-- Mob Framework Mod by Sapier
-- 
-- You may copy, use, modify or do nearly anything except removing this
-- copyright notice. 
-- And of course you are NOT allow to pretend you have written it.
--
--! @file api.lua
--! @brief api functions to be used by other mods
--! @copyright Sapier
--! @author Sapier
--! @date 2012-12-27
--
-- Contact sapier a t gmx net
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- name: mobf_register_on_death_callback(callback)
--
--! @brief get version of mob framework
--! @ingroup framework_mob
--
--! @param callback callback to register
--! @return true/false
-------------------------------------------------------------------------------
function mobf_register_on_death_callback(callback)
	return fighting.register_on_death_callback(callback)
end

-------------------------------------------------------------------------------
-- name: mobf_get_mob_definition(mobname)
--
--! @brief get COPY of mob definition
--! @ingroup framework_mob
--
--! @return mobf version
-------------------------------------------------------------------------------
function mobf_get_mob_definition(mobname)

	if mobf_registred_mob_data[mobname] ~= nil then
		local copy = minetest.serialize(mobf_registred_mob_data[mobname])
		return minetest.deserialize(copy)
	end
	return nil
end

-------------------------------------------------------------------------------
-- name: mobf_get_version()
--
--! @brief get version of mob framework
--! @ingroup framework_mob
--
--! @return mobf version
-------------------------------------------------------------------------------
function mobf_get_version()
	return mobf_version
end

------------------------------------------------------------------------------
-- name: mobf_add_mob(mob)
--
--! @brief register a mob within mob framework
--! @ingroup framework_mob
--
--! @param mob a mob declaration
-------------------------------------------------------------------------------
function mobf_add_mob(mob)

	if mob.name == nil or
		mob.modname == nil then
		minetest.log(LOGLEVEL_ERROR,"MOBF: name and modname are mandatory for ALL mobs!")
		return false
	end
	
	
	if mobf_contains(mobf_registred_mob,mob.modname.. ":"..mob.name) then
		
		local balacklisted = minetest.registered_entities[mob.modname.. ":"..mob.name]
		
		--remove unknown animal objects
		if minetest.setting_getbool("mobf_delete_disabled_mobs") then
			if minetest.registered_entities[mob.modname.. ":"..mob.name] == nil then
			
				minetest.register_entity(mob.modname.. ":"..mob.name,
					{
					 	on_activate = function(self,staticdata)
					 		self.object:remove()
					 	end
					 })
					 
				if mob.states ~= nil then
					for s = 1, #mob.states , 1 do
						minetest.register_entity(":".. mob_state.get_entity_name(mob,mob.states[s]),
						{
						 	on_activate = function(self,staticdata)
						 		self.object:remove()
						 	end
						 })
					end
				end
			end
		end
		
		if blacklisted == nil then
			minetest.log(LOGLEVEL_INFO,"MOBF: " .. mob.modname.. ":"..mob.name .. " was blacklisted")
		else
			minetest.log(LOGLEVEL_ERROR,"MOBF: " .. mob.modname.. ":"..mob.name .. " already known not registering mob with same name!")
		end
		return false
	end
	
	--if a random drop is specified for this mob register it
	if mob.random_drop ~= nil then
		random_drop.register(mob.random_drop)
	end
	
	--create default entity
	minetest.log(LOGLEVEL_INFO,"MOBF: adding: " .. mob.name)
	local graphic_to_set = mobf.prepare_graphic_info(mob.graphics,mob.graphics_3d,mob.modname,"_"..mob.name)
	mobf.register_entity(":".. mob.modname .. ":"..mob.name, graphic_to_set, mob)
	
	mob_state.prepare_states(mob)

	mobf.register_mob_item(mob.name,mob.modname,mob.generic.description)
	
	--check if a movement pattern was specified
	if mobf_movement_patterns[mob.movement.pattern] == nil then
		minetest.log(LOGLEVEL_WARNING,"MOBF: no movement pattern specified!")
	end

	if not minetest.setting_getbool("mobf_disable_animal_spawning") then
		--register spawn callback to world
		if environment_list[mob.generic.envid] ~= nil then
			local secondary_name = ""		
			if mob.harvest ~= nil then
				secondary_name = mob.harvest.transforms_to
			end
			
			dbg_mobf.mobf_core_lvl3("MOBGF: Environment to use:" , mob.generic.envid)
			
			mobf_spawn_algorithms[mob.spawning.algorithm](mob.modname..":"..mob.name,
																secondary_name,
																mob.spawning,
																environment_list[mob.generic.envid])
																
			if minetest.setting_getbool("mobf_animal_spawning_secondary") then
				if mob.spawning.algorithm_secondary ~= nil then
					mobf_spawn_algorithms[mob.spawning.algorithm_secondary](mob.modname..":"..mob.name,
																secondary_name,
																mob.spawning,
																environment_list[mob.generic.envid])
				end
			end
		else
			minetest.log(LOGLEVEL_ERROR,"MOBF: specified mob >" .. mob.name .. "< without environment!")
		end
	else
		dbg_mobf.mobf_core_lvl3("MOBF: MOB spawning disabled!")
	end

	--register mob name to internal data structures
	table.insert(mobf_registred_mob,mob.modname.. ":"..mob.name)
	mobf_registred_mob_data[mob.modname.. ":"..mob.name] = mob;
	
	return true
end

------------------------------------------------------------------------------
-- name: mobf_is_known_mob(name)
--
--! @brief check if mob of name is known
--! @ingroup framework_mob
--
--! @param name name to check if it's a mob
--! @return true/false
-------------------------------------------------------------------------------
function mobf_is_known_mob(name)
	for i,val in ipairs(mobf_registred_mob) do
		if name == val then
			return true
		end
	end

	return false
end

------------------------------------------------------------------------------
-- name: mobf_register_environment(name,environment)
--
--! @brief register an environment to mob framework
--! @ingroup framework_mob
--
--! @param name of environment
--! @param environment specification
--! @return true/false
-------------------------------------------------------------------------------
function mobf_register_environment(name,environment)
	return environment.register(name,environment)
end

------------------------------------------------------------------------------
-- name: mobf_probab_movgen_register_pattern(pattern)
--
--! @brief register an movement pattern for probabilistic movement gen
--! @ingroup framework_mob
--
--! @param pattern to register (see pattern specification)
--! @return true/false
-------------------------------------------------------------------------------
function mobf_probab_movgen_register_pattern(pattern)
	return movement_gen.register_pattern(pattern)
end
