-------------------------------------------------------------------------------
-- Mob Framework Mod by Sapier
-- 
-- You may copy, use, modify or do nearly anything except removing this
-- copyright notice. 
-- And of course you are NOT allow to pretend you have written it.
--
--! @file spawning.lua
--! @brief component containing spawning features
--! @copyright Sapier
--! @author Sapier
--! @date 2012-08-09
--

--! @defgroup spawning Spawn mechanisms
--! @brief all functions and variables required for automatic mob spawning 
--! @ingroup framework_int
--! @{
--
--! @defgroup spawn_algorithms Spawn algorithms 
--! @brief spawn algorithms provided by mob framework (can be extended by mods)
--
-- Contact sapier a t gmx net
-------------------------------------------------------------------------------
mobf_assert_backtrace(spawning == nil)
--! @class spawning
--! @brief spawning features
spawning = {}

--!@}

mobf_assert_backtrace(mobf_spawn_algorithms == nil)
--! @brief registry for spawn algorithms
--! @memberof spawning
--! @private
mobf_spawn_algorithms = {}


-------------------------------------------------------------------------------
-- name: remove_uninitialized(entity,staticdata)
-- @function [parent=#spawning] remove_uninitialized
--
--! @brief remove a spawn point based uppon staticdata supplied
--! @memberof spawning
--
--! @param entity to remove
--! @param staticdata of mob
-------------------------------------------------------------------------------
function spawning.remove_uninitialized(entity, staticdata)
	--entity may be known in spawnlist
	if staticdata ~= nil then
		local permanent_data = mobf_deserialize_permanent_entity_data(staticdata)
		if (permanent_data.spawnpoint ~= nil) then
		
			--prepare information required to remove entity
			entity.dynamic_data = {}
			entity.dynamic_data.spawning = {}
			entity.dynamic_data.spawning.spawnpoint = permanent_data.spawnpoint
			entity.dynamic_data.spawning.player_spawned = permanent_data.playerspawned
			entity.dynamic_data.spawning.spawner = permanent_data.spawner

			spawning.remove(entity,"remove uninitialized")
		end
	else
		dbg_mobf.spawning_lvl1("MOBF: remove uninitialized entity=" .. tostring(entity))
		--directly remove it can't be known to spawnlist
		entity.object:remove()
	end	
end

-------------------------------------------------------------------------------
-- name: remove(entity)
-- @function [parent=#spawning] remove
--
--! @brief remove a mob
--! @memberof spawning
--
--! @param entity mob to remove
--! @param reason text to log as reason for removal
-------------------------------------------------------------------------------
function spawning.remove(entity,reason)
	local pos = entity.object:getpos()
	dbg_mobf.spawning_lvl3("MOBF: --> remove " .. printpos(pos))
	if entity ~= nil then
		entity.removed = true
		dbg_mobf.spawning_lvl1("MOBF: remove entity=" .. tostring(entity))
		if minetest.world_setting_get("mobf_log_removed_entities") then
			if reason == nil then
				reason = "unknown"
			end
			minetest.log(LOGLEVEL_NOTICE,"MOBF: removing " .. entity.data.name ..
				" at " .. printpos(pos) .. " due to: " .. reason)
		end
		mob_preserve.handle_remove(entity,reason)
		if entity.lifebar ~= nil then
			mobf_lifebar.del(entity.lifebar)
		end
		entity.object:remove()
	else
		minetest.log(LOGLEVEL_ERROR,"Trying to delete an an non existant mob")
	end
	
	dbg_mobf.spawning_lvl3("MOBF: <-- remove")
end

-------------------------------------------------------------------------------
-- name: init_dynamic_data(entity)
-- @function [parent=#spawning] init_dynamic_data
--
--! @brief initialize dynamic data required for spawning
--! @memberof spawning
--
--! @param entity mob to initialize dynamic data
--! @param now current time
-------------------------------------------------------------------------------
function spawning.init_dynamic_data(entity,now)

	local data = {
		player_spawned     = false,
		ts_dense_check     = now,
		spawnpoint         = entity.object:getpos(),
		original_spawntime = now,
		spawner            = nil,
		density            = spawning.get_min_density(entity),
	}
	
	entity.removed = false
	entity.dynamic_data.spawning = data
end



-------------------------------------------------------------------------------
-- name: check_population_density(mob)
-- @function [parent=#spawning] check_population_density
--
--! @brief check and fix if there are too many mobs within a specific range
--! @memberof spawning
--
--! @param entity mob to check
--! @param now current time
-------------------------------------------------------------------------------
function spawning.check_population_density(entity,now)
	
	if entity == nil or
		entity.dynamic_data == nil or
		entity.dynamic_data.spawning == nil then
		mobf_bug_warning(LOGLEVEL_ERROR,"MOBF BUG!!! " .. entity.data.name .. 
			" pop dense check called for entity with missing spawn data entity=" .. 
			tostring(entity))
		return
	end


	-- don't check if mob is player spawned
	if entity.dynamic_data.spawning.player_spawned == true then
		dbg_mobf.spawning_lvl1("MOBF: mob is player spawned skipping pop dense check")
		return
	end


	--don't do population check while fighting
	if entity.dynamic_data.combat ~= nil and
		entity.dynamic_data.combat.target ~= "" then
		return
	end


	--only check every 15 seconds
	if entity.dynamic_data.spawning.ts_dense_check + 15 > now then
		return	
	end

	entity.dynamic_data.spawning.ts_dense_check = now

	local entitypos = mobf_round_pos(entity.object:getpos())

	--mob either not initialized completely or a bug
	if mobf_pos_is_zero(entitypos) then
		return
	end
	
	local secondary_name = ""
	if entity.data.harvest ~= nil then
		secondary_name = entity.data.harvest.transform_to
	end

	mobf_assert_backtrace(entity.dynamic_data.spawning.density ~= nil)

	local mob_count = mobf_mob_around(entity.data.modname..":"..entity.data.name,
										secondary_name,
										entitypos,
										entity.dynamic_data.spawning.density,
										true)
	if  mob_count > 5 then
		entity.removed = true
		minetest.log(LOGLEVEL_WARNING,"MOBF: Too many ".. mob_count .. " ".. 
			entity.data.name.." at one place dying: " ..
			tostring(entity.dynamic_data.spawning.player_spawned))
		spawning.remove(entity, "population density check")
	else
		dbg_mobf.spawning_lvl3("Density ok only "..mob_count.." mobs around")
	end
end


-------------------------------------------------------------------------------
-- name: replace_entity(pos,name,spawnpos,health)
-- @function [parent=#spawning] replace_entity
--
--! @brief replace mob at a specific position by a new one
--! @memberof spawning
--
--! @param entity mob to replace
--! @param name of the mob to add
--! @param preserve preserve original spawntime
--! @return entity added or nil on error
-------------------------------------------------------------------------------
function spawning.replace_entity(entity,name,preserve)
	dbg_mobf.spawning_lvl3("MOBF: --> replace_entity("
		.. entity.data.name .. "|" .. name .. ")")
	
	if minetest.registered_entities[name] == nil then
		minetest.log(LOGLEVEL_ERROR,"MOBF: replace_entity: Bug no "
			..name.." is registred")
		return nil
	end
	
	-- avoid switching to same entity
	if entity.name == name then
		minetest.log(LOGLEVEL_INFO,"MOBF: not replacing " .. name .. 
			" by entity of same type!")
		return nil
	end
	

	-- get data to be transfered to new entity
	local pos             = mobf.get_basepos(entity)
	local health          = entity.object:get_hp()
	local temporary_dynamic_data = entity.dynamic_data
	local entity_orientation = entity.object:getyaw()
	
	if preserve == nil or preserve == false then
		temporary_dynamic_data.spawning.original_spawntime = mobf_get_current_time()
	end
	
	--calculate new y pos
	if minetest.registered_entities[name].collisionbox ~= nil then
		pos.y = pos.y - minetest.registered_entities[name].collisionbox[2]
	end
	

	--delete current mob
	dbg_mobf.spawning_lvl2("MOBF: replace_entity: removing " ..  entity.data.name)
	
	--unlink dynamic data (this should work but doesn't due to other bugs)
	entity.dynamic_data = nil
	
	--removing is done after exiting lua!
	spawning.remove(entity,"replaced")

	local newobject = minetest.add_entity(pos,name)
	local newentity = mobf_find_entity(newobject)

	if newentity ~= nil then
		if newentity.dynamic_data ~= nil then
			dbg_mobf.spawning_lvl2("MOBF: replace_entity: " ..  name .. 
							" added at " .. 
							printpos(newentity.dynamic_data.spawning.spawnpoint))
			newentity.dynamic_data = temporary_dynamic_data
			newentity.object:set_hp(health)
			newentity.object:setyaw(entity_orientation)
		else
			minetest.log(LOGLEVEL_ERROR,
				"MOBF: replace_entity: dynamic data not set for "..name..
				" maybe delayed activation?")
			newentity.dyndata_delayed = {
				data = temporary_dynamic_data,
				health = health,
				orientation = entity_orientation
			}
		end
	else
		minetest.log(LOGLEVEL_ERROR,
			"MOBF: replace_entity 4 : Bug no "..name.." has been created")
	end
	dbg_mobf.spawning_lvl3("MOBF: <-- replace_entity")
	return newentity
end

------------------------------------------------------------------------------
-- name: lifecycle()
-- @function [parent=#spawning] lifecycle
--
--! @brief check mob lifecycle
--! @memberof spawning
--
--! @return true/false still alive dead
-------------------------------------------------------------------------------
function spawning.lifecycle(entity,now)

	if entity.dynamic_data.spawning.original_spawntime ~= nil then
		if entity.data.spawning.lifetime ~= nil then
		
			local lifetime = entity.data.spawning.lifetime
			
			local current_age = now - entity.dynamic_data.spawning.original_spawntime
		
			if current_age > 0 and 
				current_age > lifetime then
				dbg_mobf.spawning_lvl1("MOBF: removing animal due to limited lifetime")
				spawning.remove(entity," limited mob lifetime")
				return false
			end
		end
	else
		entity.dynamic_data.spawning.original_spawntime = now
	end

	return true
end

------------------------------------------------------------------------------
-- name: register_spawn_algorithm()
-- @function [parent=#spawning] register_spawn_algorithm
--
--! @brief print current spawn statistics
--! @memberof spawning
--
--! @return true/false successfully added spawn algorithm
-------------------------------------------------------------------------------
function spawning.register_spawn_algorithm(name, spawnfunc, cleanupfunc)

	if (mobf_spawn_algorithms[name] ~= nil) then
		return false
	end
	
	local new_algorithm = {}
	
	new_algorithm.register_spawn	= spawnfunc
	new_algorithm.register_cleanup 	= cleanupfunc 
		
	mobf_spawn_algorithms[name] = new_algorithm

	return true
end

------------------------------------------------------------------------------
-- name: spawn_and_check(name,suffix,pos)
-- @function [parent=#spawning] spawn_and_check
--
--! @brief spawn an entity and check for presence
--! @memberof spawning
--
--! @return spawned mob entity
-------------------------------------------------------------------------------
function spawning.spawn_and_check(name,suffix,pos,text)
	mobf_assert_backtrace(pos ~= nil)
	mobf_assert_backtrace(pos.y ~= nil)
	mobf_assert_backtrace(name ~= nil)
	mobf_assert_backtrace(suffix ~= nil)
	local newobject = minetest.add_entity(pos,name .. suffix)
	
	if newobject then
		local newentity = mobf_find_entity(newobject)
		
		if newentity == nil then
			dbg_mobf.spawning_lvl3("MOBF BUG!!! no " .. name.. suffix ..
				" entity has been created by " .. text .. "!")
			mobf_bug_warning(LOGLEVEL_ERROR,"BUG!!! no " .. name.. suffix ..
				" entity has been created by " .. text .. "!")
		else
			dbg_mobf.spawning_lvl2("MOBF: spawning "..name.. suffix ..
				" entity by " .. text .. " at position ".. printpos(pos))
			minetest.log(LOGLEVEL_INFO,"MOBF: spawning "..name.. suffix .. 
				" entity by " .. text .. " at position ".. printpos(pos))
			return newentity
		end
	else
		dbg_mobf.spawning_lvl3("MOBF BUG!!! no "..name..
			" object has been created by " .. text .. "!")
		mobf_bug_warning(LOGLEVEL_ERROR,"MOBF BUG!!! no "..name..
			" object has been created by " .. text .. "!")
	end
	
	return nil
end


------------------------------------------------------------------------------
-- name: get_center(min,max,current_step,interval)
-- @function [parent=#spawning] get_center
--
--! @brief calculate center and deltas
--! @memberof spawning
--
--! @return center,delta
-------------------------------------------------------------------------------
function spawning.get_center(min,max,current_step,interval)

	dbg_mobf.spawning_lvl3("MOBF: get_center params: " .. min .. " " .. max .. 
		" " .. current_step .. " " .. interval )
	local abs_min = min + interval * (current_step-1)
	local abs_max = abs_min + interval
	
	if abs_max > max then
		abs_max = max
	end
	
	local delta = (abs_max - abs_min) / 2 
	
	return (abs_min + delta),delta
end

------------------------------------------------------------------------------
-- name: divide_mapgen_entity(minp,maxp,density,name,spawnfunc)
-- @function [parent=#spawning] divide_mapgen_entity
--
--! @brief divide mapblock into 2d chunks and call spawnfunc with randomized parameters for each
--! @memberof spawning
--! @param minp minimum 3d point of map block
--! @param maxp maximum 3d point of map block
--! @param spawndata spawndata
--! @param name name of entity to spawn
--! @param spawnfunc function to use for spawning
--! @param maxtries maximum number of tries to place a spawner
--
-------------------------------------------------------------------------------
function spawning.divide_mapgen_entity(minp,maxp,spawndata,name,spawnfunc,maxtries)
	local density = spawndata.density
	
	dbg_mobf.spawning_lvl3("MOBF: divide_mapgen params: ")
	dbg_mobf.spawning_lvl3("MOBF:	" .. dump(spawndata.density))
	dbg_mobf.spawning_lvl3("MOBF:	" .. dump(name))
	dbg_mobf.spawning_lvl3("MOBF:	" .. dump(spawnfunc))
	
	if maxtries == nil then
		maxtries = 2
	end
	
	local divs = 0
	local attempts = 0
	local spawned = 0
	
	local min_x = MIN(minp.x,maxp.x)
	local min_y = MIN(minp.y,maxp.y)
	local min_z = MIN(minp.z,maxp.z)
	
	local max_x = MAX(minp.x,maxp.x)
	local max_y = MAX(minp.y,maxp.y)
	local max_z = MAX(minp.z,maxp.z)
	
	
	local xdivs = math.floor(((max_x - min_x) / spawndata.density) +1)
	local zdivs = math.floor(((max_z - min_z) / spawndata.density) +1)
	
	dbg_mobf.spawning_lvl3("MOBF: X: " .. min_x .. "-->" .. max_x) 
	dbg_mobf.spawning_lvl3("MOBF: Z: " .. min_z .. "-->" .. max_z)
	dbg_mobf.spawning_lvl3("MOBF: Y: " .. min_y .. "-->" .. max_y)
	dbg_mobf.spawning_lvl3("MOBF: generating in " .. xdivs .. " | " .. zdivs .. " chunks")
	
	for i = 1, xdivs,1 do
	for j = 1, zdivs,1 do
	
		local x_center,x_delta = spawning.get_center(min_x,max_x,i,spawndata.density)
		local z_center,z_delta = spawning.get_center(min_z,max_z,j,spawndata.density)
		
		local surface_center = mobf_get_surface(x_center,z_center,min_y,max_y)
		
		local centerpos = {x=x_center,y=surface_center,z=z_center}
		
		if surface_center  == nil then
			dbg_mobf.spawning_lvl2(
				"MOBF: didn't find surface for " ..printpos(centerpos))
			centerpos.y = min_y + ((max_y-min_y)/2)
		end
		
		dbg_mobf.spawning_lvl3("MOBF: center is set to " ..
			"(" .. x_center .. "," .. z_center .. ")"
			.."  --> (".. x_delta .."," .. z_delta .. ")")
		
		--check if there is already a mob of same type within area
		local mobs_around = mobf_spawner_around(name,centerpos,spawndata.density)
		if mobs_around == 0 then
			dbg_mobf.spawning_lvl3("no " .. name .. " within range of " .. 
				spawndata.density .. " around " ..printpos(centerpos))
			
			for i = 0, maxtries, 1 do
				attempts = attempts +1
				local x_try = math.random(-x_delta,x_delta)
				local z_try = math.random(-z_delta,z_delta)
				
				local pos = { x= x_center + x_try,
								z= z_center + z_try }
				
				--do place spawners in center of block
				pos.x = math.floor(pos.x + 0.5)
				pos.z = math.floor(pos.z + 0.5)
				
				if spawnfunc(name,pos,min_y,max_y,spawndata) then
					spawned = spawned +1
					break
				end
			end --for -> maxtries
		end --mob around
		
		divs = divs +1
	end -- for z divs
	end -- for x divs
	local max_available_tries = divs * maxtries
	dbg_mobf.spawning_lvl3("MOBF: divide_mapgen I " ..
			"(" .. divs .. "|" .. attempts .. "|" .. spawned .. "|" .. max_available_tries .. ")")
	mobf_rtd.total_spawned = mobf_rtd.total_spawned + spawned
	return spawned
end

------------------------------------------------------------------------------
-- name: divide_mapgen(minp,maxp,density,name,spawnfunc)
-- @function [parent=#spawning] divide_mapgen
--
--! @brief divide mapblock into 2d chunks and call spawnfunc with randomized parameters for each
--! @memberof spawning
--! @param minp minimum 3d point of map block
--! @param maxp maximum 3d point of map block
--! @param sp_data spawning data or density (auto detected)
--! @param name name of entity to spawn
--! @param secondary_name secondary name of entity
--! @param spawnfunc function to use for spawning
--! @param surfacefunc use this function to detect surface
--! @param maxtries maximum number of tries to place a entity
--
-------------------------------------------------------------------------------
function spawning.divide_mapgen(minp,maxp,sp_data,name,secondary_name,spawnfunc,surfacefunc,maxtries)
	dbg_mobf.spawning_lvl3("MOBF: divide_mapgen params: ")
	dbg_mobf.spawning_lvl3("MOBF:	" .. dump(density))
	dbg_mobf.spawning_lvl3("MOBF:	" .. dump(name))
	dbg_mobf.spawning_lvl3("MOBF:	" .. dump(spawnfunc))
	
	if maxtries == nil then
		maxtries = 2
	end
	
	local density = sp_data
	local spawning_data = nil
	if type(sp_data) == "table" then
		density = sp_data.density
		spawning_data = sp_data
	end
	
	local divs = 0
	local attempts = 0
	local spawned = 0

	local starttime = mobf_get_time_ms()
	
	local min_x = MIN(minp.x,maxp.x)
	local min_y = MIN(minp.y,maxp.y)
	local min_z = MIN(minp.z,maxp.z)
	
	local max_x = MAX(minp.x,maxp.x)
	local max_y = MAX(minp.y,maxp.y)
	local max_z = MAX(minp.z,maxp.z)
	
	
	local xdivs = math.floor(((max_x - min_x) / density) +1)
	local zdivs = math.floor(((max_z - min_z) / density) +1)
	
	dbg_mobf.spawning_lvl3("MOBF: X: " .. min_x .. "-->" .. max_x) 
	dbg_mobf.spawning_lvl3("MOBF: Z: " .. min_z .. "-->" .. max_z)
	dbg_mobf.spawning_lvl3("MOBF: Y: " .. min_y .. "-->" .. max_y)
	dbg_mobf.spawning_lvl3("MOBF: generating in " .. xdivs .. " | " .. zdivs .. " chunks")
	
	for i = 1, xdivs,1 do
	for j = 1, zdivs,1 do
		local starttime = mobf_get_time_ms()
		local x_center,x_delta = spawning.get_center(min_x,max_x,i,density)
		local z_center,z_delta = spawning.get_center(min_z,max_z,j,density)
		
		local surface_center = surfacefunc(x_center,z_center,min_y,max_y)
		mobf_warn_long_fct(starttime,"surface_detection","user_2")
		
		local centerpos = {x=x_center,y=surface_center,z=z_center}
		
		if surface_center  == nil then
			dbg_mobf.spawning_lvl2(
				"MOBF: didn't find surface for " ..printpos(centerpos))
			centerpos.y = min_y + ((max_y-min_y)/2)
		end
		
		dbg_mobf.spawning_lvl3("MOBF: center is (" .. x_center .. "," .. z_center .. ") --> (".. x_delta .."," .. z_delta .. ")")
		
		for i = 0, maxtries, 1 do
			attempts = attempts +1
			local x_try = math.random(-x_delta,x_delta)
			local z_try = math.random(-z_delta,z_delta)
			
			local pos = { x= x_center + x_try,
							z= z_center + z_try }
							
			pos.y = surfacefunc(pos.x,pos.z,min_y,max_y)
			local mobs_around = -1
			
			if pos.y ~= nil then
				mobs_around = mobf_mob_around(name,secondary_name,pos,density,true)
			end
			
			if pos.y ~= 0 and mobs_around == 0 then
				dbg_mobf.spawning_lvl3("MOBF: no " .. name .. " within range of " .. density .. " around " ..printpos(centerpos))

				if spawnfunc(name,pos,min_y,max_y,spawning_data) then
					spawned = spawned +1
					break
				end
			end -- mobs_around
		end --for -> 5

		divs = divs +1
	end -- for z divs
	end -- for x divs
	local max_available_tries = divs * maxtries
	dbg_mobf.spawning_lvl2("MOBF: divide_mapgen II " ..
			"(" .. divs .. "|" .. attempts .. "|" .. spawned .. "|" .. max_available_tries .. ")")
	mobf_rtd.total_spawned = mobf_rtd.total_spawned + spawned
	return spawned
end

------------------------------------------------------------------------------
-- name: register_spawner_entity(mobname,secondary_mobname,spawndata,environment,spawnfunc)
-- @function [parent=#spawning] register_spawner_entity
--
--! @brief register a spawner entity
--! @memberof spawning
--
--! @param mobname name of mob
--! @param secondary_mobname secondary name of mob
--! @param spawndata spawning information to use
--! @param environment what environment is good for mob
--! @param spawnfunc function to call for spawning
--! @param suffix to add
--
--! @return
-------------------------------------------------------------------------------
function spawning.register_spawner_entity(mobname,secondary_mobname,spawndata,environment,spawnfunc,suffix)
	if suffix == nil then
		suffix = ""
	end
	minetest.register_entity(mobname .. "_spawner" .. suffix,
		 {
			physical        = false,
			collisionbox    = { 0.0,0.0,0.0,0.0,0.0,0.0},
			visual          = "sprite",
			textures        = { "invisible.png^[makealpha:128,0,0^[makealpha:128,128,0" },
			mobf_spawner    = true,
			
			
			on_step = function(self,dtime)
				local starttime = mobf_get_time_ms()
				self.spawner_time_passed = self.spawner_time_passed -dtime

				--self.spawner_time_passed has to be handled by spawnfunc!
				if self.spawner_time_passed < 0 then
					local starttime = mobf_get_time_ms()
					
					local mobcount = mobf_mob_around(self.spawner_mob_name,
										self.spawner_mob_transform,
										self.object:getpos(),
										1.5,true)
					
					--check if mob is already at spawner pos
					if mobcount == 0 then
						spawnfunc(self)
					else
						dbg_mobf.spawning_lvl3("MOBF: not spawning " .. self.spawner_mob_name .. " due to mob being to near " .. mobcount)
					end
				end
				mobf_warn_long_fct(starttime,"spawner_entity_onstep","spawn_onstep")
			end,
			
			on_activate = function(self,staticdata)
				local starttime = mobf_get_time_ms()
				if self.spawner_mob_transform == nil then
					self.spawner_mob_transform = ""
				end
				--TODO honor time since deactivation
				self.spawner_time_passed     = 1
				mobf_warn_long_fct(starttime,"spawner_entity_activate","spawn_onstep")
			end,
			
			spawner_mob_name        = mobname,
			spawner_mob_transform   = secondary_mobname,
			spawner_time_passed     = 1,
			spawner_mob_env         = environment,
			spawner_mob_spawndata   = spawndata,
		})

end

------------------------------------------------------------------------------
-- name: register_cleanup_spawner(mobname)
-- @function [parent=#spawning] register_cleanup_spawner
--
--! @brief register an entity to cleanup spawners
--! @memberof spawning
--
--! @param mobname mobname to create cleanup
-------------------------------------------------------------------------------
function spawning.register_cleanup_spawner(mobname)
	minetest.register_entity(mobname .. "_spawner",
		{
			on_activate = function(self,staticdata)
				self.object:remove()
			end
		})
end


------------------------------------------------------------------------------
-- name: setup_algorithm(mob)
-- @function [parent=#spawning] setup_algorithm
--
--! @brief set up a specific algorithm for a mob
--! @memberof spawning
--
--! @param primary_name name of mob
--! @param secondary_name name of mob (when harvested)
--! @param parameters spawning parameters
--! @param envid identifyer for environment of mob
-------------------------------------------------------------------------------
function spawning.setup_algorithm(primary_name,secondary_name,parameters,envid)
	
	if type(parameters) == "table" then

		if mobf_spawn_algorithms[parameters.algorithm] ~= nil and
			type(mobf_spawn_algorithms[parameters.algorithm].register_spawn) == "function" then
			dbg_mobf.spawning_lvl2("MOBF: algorithm: " .. parameters.algorithm)
			dbg_mobf.spawning_lvl2("MOBF: " .. dump(primary_name) .. " " ..
				dump(secondary_name) .. " " .. dump(parameters) .. " " ..
				dump(envid))
			mobf_spawn_algorithms[parameters.algorithm].register_spawn(
								primary_name,
								secondary_name,
								parameters,
								environment_list[envid])
		end
	end
end

------------------------------------------------------------------------------
-- name: get_min_density(entity)
-- @function [parent=#spawning] get_min_density
--
--! @brief get minimum density for this mob
--! @memberof spawning
--
--! @param entity the mob itself
--
--! @return minimum density over all spawners defined for this mob
-------------------------------------------------------------------------------
function spawning.get_min_density(entity)
	if type(entity.data.spawning.primary_algorithms) == "table" then
		local density = nil
		for i=1 , #entity.data.spawning.primary_algorithms , 1 do
			if density == nil or
				entity.data.spawning.primary_algorithms[i].density < density then
				
				density = entity.data.spawning.primary_algorithms[i].density
			end
		end
		return density
	else
		return entity.data.spawning.density
	end
end

------------------------------------------------------------------------------
-- name: register_mob(mob)
-- @function [parent=#spawning] register_mob
--
--! @brief initialize spawn algorithms for a mob
--! @memberof spawning
--
--! @param mob definition
-------------------------------------------------------------------------------
function spawning.register_mob(mob)
	--spawn mechanism handling
	if not minetest.world_setting_get("mobf_disable_animal_spawning") then
		--register spawn callback to world
		if environment_list[mob.generic.envid] ~= nil then
			local secondary_name = ""		
			if mob.harvest ~= nil then
				secondary_name = mob.harvest.transforms_to
			end
			
			dbg_mobf.spawning_lvl3("MOBF: Environment to use: " .. tostring(mob.generic.envid))
			
			if mob.spawning.algorithm == nil then
				dbg_mobf.spawning_lvl2("MOBF: Register spawning algorithms")
				if type(mob.spawning.primary_algorithms) == "table" then
					for i=1 , #mob.spawning.primary_algorithms , 1 do
						spawning.setup_algorithm(
								mob.modname..":"..mob.name,
								secondary_name,
								mob.spawning.primary_algorithms[i],
								mob.generic.envid)
					end
				else
					dbg_mobf.spawning_lvl2("MOBF: " .. mob.name 
						.. " no primary spawn algorithm defined! ")
				end
			
				if minetest.world_setting_get("mobf_animal_spawning_secondary") then
					if type(mob.spawning.secondary_algorithms) == "table" then
						for i=1 , #mob.spawning.secondary_algorithms , 1 do
							spawning.setup_algorithm(
									mob.modname..":"..mob.name,
									secondary_name,
									mob.spawning.secondary_algorithms[i],
									mob.generic.envid)
						end
					end
				end
			else
				minetest.log(LOGLEVEL_WARNING,"MOBF: legacy spawning declaration"
						.. " for mob: " .. mob.name
						.. "!!! plz update to new way of defining spawn"
						.. " algorithms")
				if mobf_spawn_algorithms[mob.spawning.algorithm] ~= nil and
					type(mobf_spawn_algorithms[mob.spawning.algorithm].register_spawn) == "function" then
					mobf_spawn_algorithms[mob.spawning.algorithm].register_spawn(mob.modname..":"..mob.name,
																		secondary_name,
																		mob.spawning,
																		environment_list[mob.generic.envid])
				else
					dbg_mobf.spawning_lvl2("MOBF: " .. mob.name 
						.. " no primary spawn algorithm defined: " 
						.. tostring(mob.spawning.algorithm))
				end
				
				if minetest.world_setting_get("mobf_animal_spawning_secondary") then
					if mob.spawning.algorithm_secondary ~= nil and 
						type(mobf_spawn_algorithms[mob.spawning.algorithm_secondary].register_spawn) == "function" then
						mobf_spawn_algorithms[mob.spawning.algorithm_secondary].register_spawn(mob.modname..":"..mob.name,
																	secondary_name,
																	mob.spawning,
																	environment_list[mob.generic.envid])
					end
				end
			end
		else
			minetest.log(LOGLEVEL_ERROR,"MOBF: specified mob >" .. mob.name 
				.. "< without environment!")
		end
	else
		dbg_mobf.spawning_lvl3("MOBF: MOB spawning disabled!")
	end
end

------------------------------------------------------------------------------
-- name: divide_mapgen_jobfunc(mob)
-- @function [parent=#spawning] divide_mapgen_jobfunc
--
--! @brief job wrapper function for divide mapgen
--! @memberof spawning
--
--! @param data job data
-------------------------------------------------------------------------------
function spawning.divide_mapgen_jobfunc(data)
	local spawned = spawning.divide_mapgen(
			data.minp,
			data.maxp,
			data.spawning_data,
			data.mob_name,
			data.mob_transform,
			data.spawnfunc,
			data.surfacefunc,
			5
			)
	if data.func ~= nil then
		data.maxtries = data.maxtries -5
		data.spawned = data.spawned + spawned
		local stopspawning = 3
		if data.stopspawning ~= nil then
			stopspawning = data.stopspawning
		end
		if data.spawned < stopspawning and
			data.maxtries > 0 then
			--requeue job
			mobf_job_queue.add_job({callback=data.func,data=data})
		end
	end
end

------------------------------------------------------------------------------
-- name: divide_mapgen_jobfunc(mob)
-- @function [parent=#spawning] divide_mapgen_jobfunc
--
--! @brief job wrapper function for divide mapgen
--! @memberof spawning
--
--! @param data job data
-------------------------------------------------------------------------------
function spawning.divide_mapgen_entity_jobfunc(data)
	local spawned = spawning.divide_mapgen_entity(
			data.minp,
			data.maxp,
			data.spawning_data,
			data.mob_name,
			data.spawnfunc,
			1
			)
	data.maxtries = data.maxtries -1
	
	if data.spawned == nil then
		data.spawned = 0
	end
	
	if data.func ~= nil then
		mobf_assert_backtrace(spawned ~= nil)
		data.spawned = data.spawned + spawned
		local stopspawning = 3
		if data.stopspawning ~= nil then
			stopspawning = data.stopspawning
		end
		if data.spawned < stopspawning and
			data.maxtries > 0 then
			--requeue job
			mobf_job_queue.add_job({callback=data.func,data=data})
		end
	else
		mobf_assert_backtrace(data.maxtries <= 0)
	end
end

--include spawn algorithms
dofile (mobf_modpath .. "/spawn_algorithms/at_night.lua")
dofile (mobf_modpath .. "/spawn_algorithms/forrest.lua")
dofile (mobf_modpath .. "/spawn_algorithms/in_shallow_water.lua")
dofile (mobf_modpath .. "/spawn_algorithms/shadows.lua")
dofile (mobf_modpath .. "/spawn_algorithms/willow.lua")
dofile (mobf_modpath .. "/spawn_algorithms/big_willow.lua")
dofile (mobf_modpath .. "/spawn_algorithms/in_air1.lua")
dofile (mobf_modpath .. "/spawn_algorithms/none.lua")
dofile (mobf_modpath .. "/spawn_algorithms/deep_large_caves.lua")