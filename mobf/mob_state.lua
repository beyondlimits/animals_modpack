-------------------------------------------------------------------------------
-- Mob Framework Mod by Sapier
-- 
-- You may copy, use, modify or do nearly anything except removing this
-- copyright notice. 
-- And of course you are NOT allow to pretend you have written it.
--
--! @file mob_state.lua
--! @brief component mob state transition handling
--! @copyright Sapier
--! @author Sapier
--! @date 2012-08-09
--
--
--! @defgroup mob_state functions for state handling and changeing
--! @brief a component to do basic changes to mob on state change
--! @ingroup framework_int
--! @{ 
--
-- Contact sapier a t gmx net
-------------------------------------------------------------------------------


mob_state = {}

-------------------------------------------------------------------------------
-- name: initialize(entity,now)
--
--! @brief initialize state dynamic data
--! @ingroup mob_state
--
--! @param entity elemet to initialize state data
--! @param now current time
-------------------------------------------------------------------------------
function mob_state.initialize(entity,now)

	dbg_mobf.mob_state_lvl3("MOBF: " .. entity.data.name .. " initializing state dynamic data")
	
	local state = {
		current = "default",
		time_to_next_change = 30,
		locked = false,
		enabled = false,
	}
	
	local sum_chances = 0
	local state_count = 0
	
	if entity.data.states ~= nil then
		for s = 1, #entity.data.states , 1 do
			sum_chances = sum_chances + entity.data.states[s].chance
		
			if entity.data.states[s].name ~= "combat" then
				state_count = state_count +1
			end
		end
	end
	
	--sanity check for state chances
	if sum_chances > 1 then
		minetest.log(LOGLEVEL_WARNING,"MOBF: Warning sum of state chances for mob " .. entity.data.name .. " > 1")
	end
	
	--only enable state changeing if there is at least one state
	if state_count > 0 then
		state.enabled = true
	end

	entity.dynamic_data.state = state
end


-------------------------------------------------------------------------------
-- name: get_entity_name(mob,state)
--
--! @brief get entity name for a state
--! @ingroup mob_state
--
--! @param mob generic data
--! @param state selected state data
--!
--! @return name to use for entity
-------------------------------------------------------------------------------
function mob_state.get_entity_name(mob,state)
	return mob.modname .. ":"..mob.name .. "__" .. state.name
end

-------------------------------------------------------------------------------
-- name: get_state_by_name(entity,name)
--
--! @brief get a state by its name
--! @ingroup mob_state
--
--! @param entity elemet to look for state data
--! @param name of state
--!
--! @return state data or nil
-------------------------------------------------------------------------------
function mob_state.get_state_by_name(entity,name)

	for i=1, #entity.data.states, 1 do
		if entity.data.states[i].name == name then
			return entity.data.states[i]
		end
	end
	
	return nil
end

-------------------------------------------------------------------------------
-- name: lock(entity,value)
--
--! @brief disable random state changes for a mob
--! @ingroup mob_state
--
--! @param entity elemet to lock
--! @param value to set
-------------------------------------------------------------------------------
function mob_state.lock(entity,value)
	if value ~= false and value ~= true then
		return
	end
	if entity.dynamic_data.state == nil then
		dbg_mobf.mob_state_lvl1("MOBF: unable to lock state for: " .. entity.data.name .. " no state dynamic data present")
		return 
	end
		
	entity.dynamic_data.state.locked = value
end


-------------------------------------------------------------------------------
-- name: callback(entity,now,dstep)
--
--! @brief callback handling state changes
--! @ingroup mob_state
--
--! @param entity elemet to look for state data
--! @param now current time
--! @param dstep time passed since last call
-------------------------------------------------------------------------------
function mob_state.callback(entity,now,dstep)

	if entity.dynamic_data.state == nil then
		minetest.log(LOGLEVEL_ERRROR,"MOBF BUG: " .. entity.data.name .. " mob state callback without mob dynamic data!")
		mob_state.initialize(entity,now)
		entity.dynamic_data.current_movement_gen = getMovementGen(entity.data.movement.default_gen)
		entity.dynamic_data.current_movement_gen.init_dynamic_data(entity,mobf_get_current_time())
		entity = spawning.replace_entity(entity,entity.data.modname .. ":"..entity.data.name,true)
		return 
	end
	--abort state change if current state is locked
	if entity.dynamic_data.state.locked or 
		entity.dynamic_data.state.enabled == false then
		dbg_mobf.mob_state_lvl3("MOBF: " .. entity.data.name .. " state locked or no custom states definded ")
		return
	end
	
	entity.dynamic_data.state.time_to_next_change = entity.dynamic_data.state.time_to_next_change -dstep
	
	--do only change if last state timed out
	if entity.dynamic_data.state.time_to_next_change < 0 then
	
		dbg_mobf.mob_state_lvl2("MOBF: " .. entity.data.name .. " time to change state ")
	
		local rand = math.random()
		
		local maxvalue = 0
		
		local state_table = {}
		
		--fill table with available states
		for i=1, #entity.data.states, 1 do
			if entity.data.states[i].custom_preconhandler == nil or
				entity.data.states[i].custom_preconhandler() then
				table.insert(state_table,entity.data.states[i])
			end
		end
		
		--try to get a random state to change to
		for i=1, #state_table, 1 do
			
			local rand_state = math.random(#state_table)
			local current_chance = 0
			
			if type (state_table[rand_state].chance) == "function" then
				current_chance = state_table[rand_state].chance(entity,now,dstep)
			else
				if state_table[rand_state].chance ~= nil then
					current_chance = state_table[rand_state].chance
				end
			end
			
			if math.random() < current_chance then
				mob_state.change_state(entity,state_table[rand_state])
				return
			end
		end
		
		--switch to default state
		mob_state.change_state(entity,nil)
	else
		dbg_mobf.mob_state_lvl3("MOBF: " .. entity.data.name .. " is not ready for state change ")
	end
end

-------------------------------------------------------------------------------
-- name: switch_entity(entity,state)
--
--! @brief helper function to swich an entity based on new state
--! @ingroup mob_state
--
--! @param entity to replace
--! @param state to take new entity
--!
--! @return the new entity or nil
-------------------------------------------------------------------------------
function mob_state.switch_entity(entity,state)
	--switch entity
	local state_has_model = false
	
	if minetest.setting_getbool("mobf_disable_3d_mode") then
		if state.graphics ~= nil then
			state_has_model = true
		end
	else
		if state.graphics_3d ~= nil then
			state_has_model = true
		end
	end
	
	local newentity = nil
	
	if state_has_model then
		newentity = spawning.replace_entity(entity,mob_state.get_entity_name(entity.data,state),true)
	else
		newentity = spawning.replace_entity(entity,entity.data.modname .. ":"..entity.data.name,true)
	end	
	
	if newentity ~= nil then
		entity = newentity
	end

	return entity
end

-------------------------------------------------------------------------------
-- name: switch_switch_movgenentity(entity,state)
--
--! @brief helper function to swich a movement based on new state
--! @ingroup mob_state
--
--! @param entity to change movement gen
--! @param state to take new entity
-------------------------------------------------------------------------------
function mob_state.switch_movgen(entity,state)
	local mov_to_set = nil
	
	--determine new movement gen
	if state.movgen ~= nil then
		mov_to_set = getMovementGen(state.movgen)
	else
		mov_to_set = getMovementGen(entity.data.movement.default_gen)
	end
	
	--check if new mov gen differs from old one
	if mov_to_set ~= nil and
		mov_to_set ~= entity.dynamic_data.current_movement_gen then
		entity.dynamic_data.current_movement_gen = mov_to_set
		
		--TODO initialize new movement gen
		entity.dynamic_data.current_movement_gen.init_dynamic_data(entity,mobf_get_current_time())
	end
end


-------------------------------------------------------------------------------
-- name: change_state(entity,state)
--
--! @brief change state for an entity
--! @ingroup mob_state
--
--! @param entity to change state
--! @param state to change to
--!
--! @return the new entity or nil
-------------------------------------------------------------------------------
function mob_state.change_state(entity,state)

	dbg_mobf.mob_state_lvl3("MOBF: " .. entity.data.name .. " state change called " .. dump(state))
	--check if time precondition handler tells us to stop state change
	--if not mob_state.precon_time(state) then
	--	return
	--end
	
	--check if custom precondition handler tells us to stop state change
	if state ~= nil and
		type(state.custom_preconhandler) == "function" then
		if not state.custom_preconhandler(entity,state) then
			dbg_mobf.mob_state_lvl2("MOBF: " .. entity.data.name .. " custom precondition handler didn't meet ")
			return nil
		end
	end
	
	--switch to default state if no state given
	if state == nil then
		dbg_mobf.mob_state_lvl2("MOBF: " .. entity.data.name .. " invalid state switch, switching to default instead of: " .. dump(state))
		if entity.dynamic_data.state.current ~= "default" then
			local newentity = spawning.replace_entity(entity,entity.data.modname .. ":"..entity.data.name,true)
			
			if newentity ~= nil then
				entity = newentity
			end
			
			entity.dynamic_data.current_movement_gen = getMovementGen(entity.data.movement.default_gen)
			entity.dynamic_data.current_movement_gen.init_dynamic_data(entity,mobf_get_current_time())
			
			entity.dynamic_data.state.current = "default"
		end
		
		entity.dynamic_data.state.time_to_next_change = 30
		graphics.set_animation(entity,"stand")
		return nil
	end
	
	local entityname = entity.data.name
	local statename = state.name
	dbg_mobf.mob_state_lvl3("MOBF: " .. entityname .. " switching state to " .. statename)
	
	if entity.dynamic_data.state == nil then
		mobf_bug_warning(LOGLEVEL_WARNING,"MOBF BUG!!! mob_state no state dynamic data")
		return nil
	end

	if entity.dynamic_data.state.current ~= state.name then
		dbg_mobf.mob_state_lvl2("MOBF: " .. entity.data.name .. " different states now really changeing")
		entity = mob_state.switch_entity(entity,state)
		mob_state.switch_movgen(entity,state)
		
		entity.dynamic_data.state.time_to_next_change = mob_state.getTimeToNextState(state.typical_state_time)
		entity.dynamic_data.state.current = state.name
		
		graphics.set_animation(entity,state.animation)
		return entity
	else
		dbg_mobf.mob_state_lvl2("MOBF: " .. entity.data.name .. " switching to same state as before")
		entity.dynamic_data.state.time_to_next_change = mob_state.getTimeToNextState(state.typical_state_time)
	end
	
	return nil
end


-------------------------------------------------------------------------------
-- name: getTimeToNextState(typical_state_time)
--
--! @brief helper function to calculate a gauss distributed random value
--! @ingroup mob_state
--
--! @param typical_state_time center of gauss
--!
--! @return a random value around typical_state_time
-------------------------------------------------------------------------------
function mob_state.getTimeToNextState(typical_state_time)

	local u1 = 2 * math.random() -1
	local u2 = 2 * math.random() -1
	
	local q = u1*u1 + u2*u2
	
	local maxtries = 0
	
	while (q == 0 or q >= 1) and maxtries < 10 do
		u1 = math.random()
		u2 = math.random() * -1
		q = u1*u1 + u2*u2
		
		maxtries = maxtries +1
	end
	
	--abort random generation
	if maxtries >= 10 then
		return typical_state_time
	end

	local p = math.sqrt( (-2*math.log(q))/q )
	
	--calculate normalized state time with maximum error or half typical time up and down
	if math.random() < 0.5 then
		return typical_state_time + ( u1*p * (typical_state_time/2))
	else
		return typical_state_time + ( u2*p * (typical_state_time/2))
	end
end