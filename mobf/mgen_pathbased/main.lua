-------------------------------------------------------------------------------
-- Mob Framework Mod by Sapier
-- 
-- You may copy, use, modify or do nearly anything except removing this
-- copyright notice. 
-- And of course you are NOT allow to pretend you have written it.
--
--! @file path_based_movement_gen.lua
--! @brief component containing a path based movement generator (NOT COMPLETED)
--! @copyright Sapier
--! @author Sapier
--! @date 2012-08-09
--
--! @defgroup mgen_path_based MGEN: Path based movement generator (NOT COMPLETED)
--! @ingroup framework_int
--! @{ 
-- Contact sapier a t gmx net
-------------------------------------------------------------------------------

--! @class p_mov_gen
--! @brief a movement generator evaluating a path to a target and following it
p_mov_gen = {}

--!@}

--! @brief movement generator identifier
--! @memberof p_mov_gen
p_mov_gen.name = "mgen_path"

-------------------------------------------------------------------------------
-- name: callback(entity,now)
--
--! @brief path based movement generator callback
--! @memberof p_mov_gen
--
-- param1: mob to do movement
-- param2: current time
-- retval: -
-------------------------------------------------------------------------------
function p_mov_gen.callback(entity,now,dstep)

	mobf_assert_backtrace(entity ~= nil)
	mobf_assert_backtrace(entity.dynamic_data ~= nil)
	mobf_assert_backtrace(entity.dynamic_data.p_movement ~= nil)
	
	if entity.dynamic_data.p_movement.eta ~= nil then
		if now < entity.dynamic_data.p_movement.eta then
			return
		end
	end
	
	local current_pos = entity.object:getpos()
	local handled = false
	
	if entity.dynamic_data.p_movement.path == nil then
		dbg_mobf.path_mov_lvl1("MOBF: pathmov without path??????")
		return
	end
	
	--check if target is reached
	if p_mov_gen.distance_to_next_point(entity,current_pos) 
						< entity.data.movement.max_distance then
		dbg_mobf.path_mov_lvl1("MOBF: pathmov next to next point switching target")
		local update_target = true
		
		--return to begining of path
		if entity.dynamic_data.p_movement.next_path_index 
				== #entity.dynamic_data.p_movement.path then
				
			if entity.data.patrol.cycle_path then
				entity.dynamic_data.p_movement.next_path_index = 0
			else
				dbg_mobf.path_mov_lvl1("MOBF: cycle not set not updating point")
				update_target = false
			end
		end
		
		if update_target then
			entity.dynamic_data.p_movement.next_path_index = 
				entity.dynamic_data.p_movement.next_path_index + 1
				
			entity.dynamic_data.movement.target = 
				entity.dynamic_data.p_movement.path
					[entity.dynamic_data.p_movement.next_path_index]
			
			dbg_mobf.path_mov_lvl1("MOBF: (1) setting new target to index: " ..
				entity.dynamic_data.p_movement.next_path_index .. " pos: " ..
				printpos(entity.dynamic_data.movement.target))
			handled = true
		end
	end
	
	if not handled and
		entity.dynamic_data.movement.target == nil then
		
		entity.dynamic_data.movement.target = 
				entity.dynamic_data.p_movement.path
					[entity.dynamic_data.p_movement.next_path_index]
				
		dbg_mobf.path_mov_lvl1("MOBF: (2) setting new target to index: " ..
				entity.dynamic_data.p_movement.next_path_index .. " pos: " ..
				printpos(entity.dynamic_data.movement.target))
	end
	
	mgen_follow.callback(entity,now)
end


-------------------------------------------------------------------------------
-- name: distance_to_next_point(entity)
--
--! @brief get distance to next target point (2d only)
--! @memberof p_mov_gen
--
--! @param entity to check
-- 
--! @retval distance
-------------------------------------------------------------------------------
function p_mov_gen.distance_to_next_point(entity,current_pos)
	local index = entity.dynamic_data.p_movement.next_path_index
	return mobf_calc_distance_2d(current_pos,
		entity.dynamic_data.p_movement.path[index])
end

-------------------------------------------------------------------------------
-- name: init_dynamic_data(entity,now)
--
--! @brief initialize dynamic data required by movement generator
--! @memberof p_mov_gen
--
--! @param entity to initialize
--! @param now current time
-------------------------------------------------------------------------------
function p_mov_gen.init_dynamic_data(entity,now,restored_data)

	local pos = entity.object:getpos()

	local data = {
			path                = nil,
			eta                 = nil,
			last_move_stop      = now,
			next_path_index     = 1,
			force_target        = nil,
			pathowner           = nil,
			pathname            = nil,
			}
	
	if restored_data ~= nil then
		dbg_mobf.path_mov_lvl3(
			"MOBF: path movement reading stored data: " .. dump(restored_data))
		if restored_data.pathowner ~= nil and
			restored_data.pathname ~= nil then
			data.pathowner = restored_data.pathowner
			data.pathname = restored_data.pathname
			
			data.path = mobf_path.getpoints(data.pathowner,data.pathname)
			dbg_mobf.path_mov_lvl3(
				"MOBF: path movement restored points: " .. dump(data.path))
		end
		
		if restored_data.pathindex ~= nil and
			restored_data.pathindex > 0 and
			data.path ~= nil and
			restored_data.pathindex < #data.path then
			data.next_path_index = restored_data.pathindex
		end
	end
	
	entity.dynamic_data.p_movement = data
	
	mgen_follow.init_dynamic_data(entity,now)
end

--register this movement generator
registerMovementGen(p_mov_gen.name,p_mov_gen)