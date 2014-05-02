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
-- name: init()
-- @function [parent=#spawning] init
--
--! @brief initialize spawning data
--! @memberof spawning
--
-------------------------------------------------------------------------------
function spawning.init()
	--read from file
	local world_path = minetest.get_worldpath()

	local file,error = io.open(world_path .. "/mobf_spawning_data","r")

	if file ~= nil then
		local data_raw = file:read("*a")
		file:close()

		if data_raw ~= nil then
			spawning.mob_spawn_data = minetest.deserialize(data_raw)
		end
	end

	if spawning.mob_spawn_data == nil then
		spawning.mob_spawn_data = {}
	end

	--register spawndata persistent storer to globalstep
	minetest.after(300,spawning.preserve_spawn_data,true)

	--register cleanup handler
	minetest.register_on_shutdown(function(dstep) spawning.preserve_spawn_data(false) end)
end

-------------------------------------------------------------------------------
-- name: preserve_spawn_data()
-- @function [parent=#spawning] preserve_spawn_data
--
--! @brief save data on regular base
--! @memberof spawning
--
--! @param force
-------------------------------------------------------------------------------
function spawning.preserve_spawn_data(cyclic)

	local world_path = minetest.get_worldpath()
	local file,error = io.open(world_path .. "/mobf_spawning_data","w")

	if error ~= nil then
		minetest.log(LOGLEVEL_ERROR,"MOBF: failed to spawning preserve file")
	end
	mobf_assert_backtrace(file ~= nil)

	local serialized_data = minetest.serialize(spawning.mob_spawn_data)

	file:write(serialized_data)

	if cyclic then
		minetest.after(300,spawning.preserve_spawn_data,cyclic)
	end
end

-------------------------------------------------------------------------------
-- name: total_offline_mobs()
-- @function [parent=#spawning] total_offline_mobs
--
--! @brief count total number of offline mobs
--! @memberof spawning
--
--! @return number of mobs
-------------------------------------------------------------------------------
function spawning.total_offline_mobs()
	local count = 0
	for key,value in pairs(spawning.mob_spawn_data) do
		for hash,v in pairs(value) do
			count = count +1
		end
	end

	return count
end

-------------------------------------------------------------------------------
-- name: count_deactivated_mobs(name,pos,range)
-- @function [parent=#spawning] count_deactivated_mobs
--
--! @brief count number of mobs of specific type within a certain range
--! @memberof spawning
--
--! @param name name of mob to count
--! @param pos to check distance to
--! @param range to check
--
--! @return number of mobs
-------------------------------------------------------------------------------
function spawning.count_deactivated_mobs(name,pos,range)
	local count = 0
	if spawning.mob_spawn_data[name] ~= nil then
		for hash,v in pairs(spawning.mob_spawn_data[name]) do
			local mobpos = mobf_hash_to_pos(hash)
			local distance = vector.distance(pos,mobpos)
			if distance < range then
				count = count +1
			end
		end
	end
	return count
end

-------------------------------------------------------------------------------
-- name: deactivate_mob(entity)
-- @function [parent=#spawning] deactivate_mob
--
--! @brief add mob to deactivated list
--! @memberof spawning
--
--! @param entity to deactivate
-------------------------------------------------------------------------------
function spawning.deactivate_mob(name,pos)
	if spawning.mob_spawn_data[name] == nil then
		spawning.mob_spawn_data[name] = {}
	end

	local rounded_pos = vector.round(pos)
	local hash = minetest.hash_node_position(rounded_pos)
	--assert (mobf_pos_is_same(mobf_hash_to_pos(hash),rounded_pos))
	spawning.mob_spawn_data[name][hash] = true
end

-------------------------------------------------------------------------------
-- name: activate_mob(name,pos)
-- @function [parent=#spawning] preserve_spawn_data
--
--! @brief save data on regular base
--! @memberof spawning
--
--! @param force
-------------------------------------------------------------------------------
function spawning.activate_mob(name,pos)
	if spawning.mob_spawn_data[name] ~= nil then
		local rounded_pos = vector.round(pos)
		local hash = minetest.hash_node_position(rounded_pos)
		--assert(mobf_pos_is_same(mobf_hash_to_pos(hash),rounded_pos))
		spawning.mob_spawn_data[name][hash] = nil
	end
end


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

	local player_spawned = false

	if entity.dynamic_data.spawning ~= nil and
		entity.dynamic_data.spawning.player_spawned then
		player_spawned = true
	end

	local data = {
		player_spawned     = player_spawned,
		ts_dense_check     = now,
		spawnpoint         = entity.object:getpos(),
		original_spawntime = now,
		spawner            = nil,
		density            = spawning.population_density_get_min(entity),
	}

	entity.removed = false
	entity.dynamic_data.spawning = data
end

-------------------------------------------------------------------------------
-- name: population_density_check(mob)
-- @function [parent=#spawning] population_density_check
--
--! @brief check and fix if there are too many mobs within a specific range
--! @memberof spawning
--
--! @param entity mob to check
--! @param now current time
-------------------------------------------------------------------------------
function spawning.population_density_check(entity,now)

	if entity == nil or
		entity.dynamic_data == nil or
		entity.dynamic_data.spawning == nil then
		mobf_bug_warning(LOGLEVEL_ERROR,"MOBF BUG!!! " .. entity.data.name ..
			" pop dense check called for entity with missing spawn data entity=" ..
			tostring(entity))
		return false
	end


	--only check every 5 seconds
	if entity.dynamic_data.spawning.ts_dense_check + 5 > now then
		return true
	end

	-- don't check if mob is player spawned
	if entity.dynamic_data.spawning.player_spawned == true then
		dbg_mobf.spawning_lvl1("MOBF: mob is player spawned skipping pop dense check")
		return true
	end

	--don't do population check while fighting
	if entity.dynamic_data.combat ~= nil and
		entity.dynamic_data.combat.target ~= nil and
		entity.dynamic_data.combat.target ~= "" then
		dbg_mobf.spawning_lvl1(
			"MOBF: fighting right now skipping pop dense check: " ..
			dump(entity.dynamic_data.combat.target))
		return true
	end

	entity.dynamic_data.spawning.ts_dense_check = now

	local entitypos = mobf_round_pos(entity.object:getpos())

	--mob either not initialized completely or a bug
	if mobf_pos_is_zero(entitypos) then
		dbg_mobf.spawning_lvl1("MOBF: can't do a sane check")
		return true
	end

	local secondary_name = ""
	if entity.data.harvest ~= nil then
		secondary_name = entity.data.harvest.transform_to
	end

	local check_density = entity.dynamic_data.spawning.density

	if entity.data.generic.population_density ~= nil then
		check_density = entity.data.generic.population_density
	end

	mobf_assert_backtrace(check_density ~= nil)

	local mob_count = mobf_mob_around(entity.data.modname..":"..entity.data.name,
										secondary_name,
										entitypos,
										entity.dynamic_data.spawning.density,
										true)
	if  mob_count > 5 then
		dbg_mobf.spawning_lvl1("MOBF: " .. entity.data.name ..
			mob_count .. " mobs of same type around")
		entity.removed = true
		minetest.log(LOGLEVEL_INFO,"MOBF: Too many ".. mob_count .. " "..
			entity.data.name.." at one place dying: " ..
			tostring(entity.dynamic_data.spawning.player_spawned))
		spawning.remove(entity, "population density check")
		return false
	else
		dbg_mobf.spawning_lvl2("MOBF: " ..  entity.data.name ..
			" density ok only "..mob_count.." mobs around")
		return true
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

	--set marker to true to make sure activate handler knows it's replacing right now
	spawning.replacing_NOW = true
	local newobject = minetest.add_entity(pos,name)
	spawning.replacing_NOW = false
	local newentity = mobf_find_entity(newobject)

	if newentity ~= nil then
		if newentity.dynamic_data ~= nil then
			dbg_mobf.spawning_lvl2("MOBF: replace_entity: " ..  name)
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
-- name: lifecycle_callback()
-- @function [parent=#spawning] lifecycle_callback
--
--! @brief check mob lifecycle_callback
--! @memberof spawning
--
--! @return true/false still alive dead
-------------------------------------------------------------------------------
function spawning.lifecycle_callback(entity,now)

	if entity.dynamic_data.spawning.original_spawntime ~= nil then
		if entity.data.spawning ~= nil and
			entity.data.spawning.lifetime ~= nil then

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
-- name: spawn_and_check(name,pos,text)
-- @function [parent=#spawning] spawn_and_check
--
--! @brief spawn an entity and check for presence
--! @memberof spawning
--! @param name name of entity
--! @param pos position to spawn mob at
--! @param text message used for log messages
--
--! @return spawned mob entity
-------------------------------------------------------------------------------
function spawning.spawn_and_check(name,pos,text)
	mobf_assert_validpos(pos)
	mobf_assert_backtrace(name ~= nil)

	local newobject = minetest.add_entity(pos,name)

	if newobject then
		local newentity = mobf_find_entity(newobject)

		if newentity == nil then
			dbg_mobf.spawning_lvl3("MOBF BUG!!! no " .. name ..
				" entity has been created by " .. text .. "!")
			mobf_bug_warning(LOGLEVEL_ERROR,"BUG!!! no " .. name ..
				" entity has been created by " .. text .. "!")
		else
			dbg_mobf.spawning_lvl2("MOBF: spawning "..name ..
				" entity by " .. text .. " at position ".. printpos(pos))
			minetest.log(LOGLEVEL_INFO,"MOBF: spawning "..name ..
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
-- name: register_cleanup_spawner(spawnername)
-- @function [parent=#spawning] register_cleanup_spawner
--
--! @brief register an entity to cleanup spawners
--! @memberof spawning
--
--! @param mobname mobname to create cleanup
-------------------------------------------------------------------------------
function spawning.register_cleanup_spawner(spawnername)
	dbg_mobf.mobf_core_lvl2("MOBF: registering spawner cleanup " .. spawnername)
	minetest.register_entity(spawnername,
		{
			on_activate = function(self,staticdata)
				self.object:remove()
			end
		})
end

------------------------------------------------------------------------------
-- name: population_density_get_min(entity)
-- @function [parent=#spawning] population_density_get_min
--
--! @brief get minimum density for this mob
--! @memberof spawning
--
--! @param entity the mob itself
--
--! @return minimum density over all spawners defined for this mob
-------------------------------------------------------------------------------
function spawning.population_density_get_min(entity)
	if entity.data.spawning == nil then
		return entity.data.generic.population_density
	end
	-- legacy code
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
-- name: collisionbox_get_max(entity)
-- @function [parent=#spawning] collisionbox_get_max
--
--! @brief get maximum extent of mob
--! @memberof spawning
--
--! @param mob mob specification
--
--! @return a collisionbox covering all state collisionboxes
-------------------------------------------------------------------------------
function spawning.collisionbox_get_max(mob)

	--use 1 block as minimum for spawning
	local retval = {-0.5,-0.5,-0.5,0.5,0.5,0.5}

	--check all states if there's some collisionbox that requires more room
	for i=1,#mob.states,1 do
		if mob.states[i] ~= nil and
			mob.states[i].graphics_3d ~= nil and
			type(mob.states[i].graphics_3d.collisionbox) == "table" then
				retval[1] = MIN(retval[1],mob.states[i].graphics_3d.collisionbox[1])
				retval[2] = MIN(retval[2],mob.states[i].graphics_3d.collisionbox[2])
				retval[3] = MIN(retval[3],mob.states[i].graphics_3d.collisionbox[3])
				retval[4] = MAX(retval[4],mob.states[i].graphics_3d.collisionbox[4])
				retval[5] = MAX(retval[5],mob.states[i].graphics_3d.collisionbox[5])
				retval[6] = MAX(retval[6],mob.states[i].graphics_3d.collisionbox[6])
			end
	end

	return retval
end

------------------------------------------------------------------------------
-- name: pos_quality(spawning_data,pos)
-- @function [parent=#spawning] pos_quality
--
--! @brief build a entity like datastructure to be passed to pos_quality check
--! @memberof spawning
--
--! @param spawning_data to check quality for
--! @param pos position to check quality at
--
--! @return a possition quality element
-------------------------------------------------------------------------------
function spawning.pos_quality(spawning_data,pos)
	local dummyentity = {}

	dummyentity.collisionbox = spawning_data.collisionbox
	dummyentity.environment = spawning_data.environment

	--TODO find a way to pass this information!
	dummyentity.data = {}
	dummyentity.data.movement = {}
	dummyentity.data.movement.canfly = false

	return environment.pos_quality(pos,dummyentity)
end

------------------------------------------------------------------------------
-- name: position_in_use(pos,spawndata)
-- @function [parent=#spawning] position_in_use
--
--! @brief check if there already is a mob at a specific position
--! @memberof spawning
--
--! @param pos position to check
--! @param spawndata data for this mob
--
--! @return true == mob present false == no mob
-------------------------------------------------------------------------------
function spawning.position_in_use(pos,spawndata)
	local mobcount = mobf_mob_around(
						spawndata.name,
						spawndata.name_secondary,
						pos,
						1.5,true)
	if mobcount > 0 then
		dbg_mobf.spawning_lvl2("MOBF: mob at same pos")
		return true
	end

	return false
end

------------------------------------------------------------------------------
-- name: population_density_limit(pos,spawndata)
-- @function [parent=#spawning] population_density_limit
--
--! @brief check if population density limit is reached
--! @memberof spawning
--
--! @param pos position to check
--! @param spawndata data for this mob
--
--! @return true == mob present false == no mob
-------------------------------------------------------------------------------
function spawning.population_density_limit(pos,spawndata)
	mobf_assert_backtrace(spawndata ~= nil)
	mobf_assert_validpos(pos)
	mobf_assert_backtrace(spawndata.name ~= nil)
	mobf_assert_backtrace(spawndata.density ~= nil)
	local mobcount = mobf_mob_around(
						spawndata.name,
						spawndata.name_secondary,
						pos,
						spawndata.density,true)
	if mobcount > 0 then
		dbg_mobf.spawning_lvl2("MOBF: not spawning within pop density")
		return true
	end

	return false
end

-------------------------------------------------------------------------------
-- name: spawner_get_water_pos(pos,max_depth,min_y,max_y)
--
--! @brief find a position at x/z within some y limitations
--
--! @param pos position do spawn
--! @param min_depth min-y depth to spawn
--! @param max_depth max-y depth to spawn
--! @param min_y minimum y value of generated chunk
--! @param max_y maximum y value of generated chunk
-------------------------------------------------------------------------------
function spawning.spawner_get_water_pos(pos,min_depth,max_depth,min_y,max_y)
	--get information about current position
	local upper_pos = {x=pos.x,y=max_y,z=pos.z}

	mobf_assert_backtrace(type(min_depth) == "number")
	mobf_assert_backtrace(type(max_depth) == "number")

	if max_depth > max_y then
		dbg_mobf.spawning_lvl3("MOBF: get_water_pos to deep")
		return nil
	end

	if min_depth < min_y then
		dbg_mobf.spawning_lvl3("MOBF: get_water_pos to high")
		return nil
	end

	local ground_distance = mobf_ground_distance(upper_pos,
							{ "default:water_flowing",
								"default:water_source",
								"air" },max_y - min_y)
	local ground_level = max_y - ground_distance +1

	local ground_pos = {x=pos.x,y=ground_level,z=pos.z }
	local water_depth = mobf_air_distance(ground_pos)

	local surfacenode = minetest.get_node(ground_pos)



	if surfacenode == nil then
		dbg_mobf.spawning_lvl3("MOBF: invalid ground node")
		return nil
	end

	if surfacenode.name ~= "default:water_flowing" and
		surfacenode.name ~= "default:water_source" then
		--mobf_print("MOBF: WD:" .. water_depth .. " GD: " .. ground_distance)
		--mobf_print("MOBF: MAXD:" .. max_depth .. " " .. min_y .. "<->" .. max_y)
		dbg_mobf.spawning_lvl3("MOBF: " .. surfacenode.name .. " isn't open water: " .. printpos(ground_pos))
		--if ground_pos.y > 0 then
		--	for i=min_y,max_y,1 do
		--		local node = minetest.get_node({x=pos.x,y=i,z=pos.z})
		--		print("i=" .. i .. " : " .. node.name)
		--	end
		--end
		return nil
	end

	if water_depth <= 0 then
		dbg_mobf.spawning_lvl3("MOBF: water not found! GP: " .. ground_level .. " WD: " .. water_depth)
		--TODO spawn in caves?
		return nil
	end

	local water_surface_pos = {x=pos.x,y=ground_level + water_depth,z=pos.z}

	--dbg_mobf.spawning_lvl2
	dbg_mobf.spawning_lvl3("MOBF: mobf_spawner_get_water_pos GL: " ..
				ground_level ..
				" WDPT: " .. water_depth ..
				" WSP: " .. printpos(water_surface_pos))
	if MAX(ground_level,max_depth) > water_surface_pos.y then
		mobf_print("MOBF: WD:" .. water_depth .. " GD: " .. ground_distance)
		mobf_print("MOBF: MAXD:" .. max_depth .. " " .. min_y .. "<->" .. max_y)
		mobf_print("MOBF: mobf_spawner_get_water_pos GL: " ..
				ground_level ..
				" WDPT: " .. water_depth ..
				" WSP: " .. printpos(water_surface_pos))
		--this can happen if there are air bubbles within water
		--mobf_assert_backtrace(MAX(ground_level,max_depth) < water_surface_pos.y)
		return nil
	end

	--check if there is any chance to find a suitable pos
	if MAX(ground_level,max_depth) >= MIN(water_surface_pos.y,min_depth) then
		return nil
	end

	pos.y = math.floor(
				math.random(
					MAX(ground_level,max_depth),
					MIN(water_surface_pos.y,min_depth)
					)
				 + 0.5)
	return pos
end

-------------------------------------------------------------------------------
-- name: check_activation_overlap(entity,pos,preserved_data)
--
--! @brief check if a activating entity is spawned within some other entity
--
--! @param entity entity to check
--! @param position spawned at
--! @return true
-------------------------------------------------------------------------------
function spawning.check_activation_overlap(entity,pos,preserved_data)

	local cleaned_objectcount = mobf_objects_around(pos,0.25,{ "mobf:lifebar" })

	--honor replaced marker
	if (entity.replaced ~= true and cleaned_objectcount > 1) or
		cleaned_objectcount > 2 then

		------------------------------
		-- debug output only
		-- ---------------------------
		local spawner = "unknown"
		if preserved_data ~= nil and
			preserved_data.spawner ~= nil then
			spawner = preserved_data.spawner

			mobf_bug_warning(LOGLEVEL_WARNING,
				"MOBF: trying to activate mob \"" ..entity.data.name ..
				" at " .. printpos(pos) .. " (" .. tostring(entity)
				.. ")"..
				"\" within something else!" ..
				" originaly spawned by: " .. spawner ..
				" --> removing")

			objectlist = minetest.get_objects_inside_radius(pos,0.25)

			for i=1,#objectlist,1 do
				local luaentity = objectlist[i]:get_luaentity()
				if luaentity ~= nil then
					if luaentity.data ~= nil and
						luaentity.data.name ~= nil then
						dbg_mobf.mobf_core_helper_lvl3(
							i .. " LE: " .. luaentity.name .. " (" .. tostring(luaentity) .. ") " ..
						luaentity.data.name .. " " ..
						printpos(objectlist[i]:getpos()))
					else
						dbg_mobf.mobf_core_helper_lvl3(
							i .. " LE: " .. luaentity.name .. " (" .. tostring(luaentity) .. ") " ..
							dump(luaentity))
					end
				else
					dbg_mobf.mobf_core_helper_lvl3(
						i .. " " .. tostring(objectlist[i]) ..
						printpos(objectlist[i]:getpos()))
				end
			end
			------------------------------
			-- end debug output
			-- ---------------------------
			return false
		end
	end
	return true
end

--------------------------------------------------------------------------------
-- LEGACY CODE BELOW subject to be removed!
--------------------------------------------------------------------------------

--include legacy spawning functions
dofile (mobf_modpath .. "/spawning_legacy.lua")

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
dofile (mobf_modpath .. "/spawn_algorithms/deep_water.lua")
