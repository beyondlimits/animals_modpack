-------------------------------------------------------------------------------
-- Mob Framework Settings Mod by Sapier
-- 
-- You may copy, use, modify or do nearly anything except removing this
-- copyright notice. 
-- And of course you are NOT allow to pretend you have written it.
--
--! @file path.lua
--! @brief path support for mobf
--! @copyright Sapier
--! @author Sapier
--! @date 2013-02-20
--
-- Contact sapier a t gmx net
-------------------------------------------------------------------------------


function gridat(grid,pos)
	mobf_assert_backtrace(grid ~= nil)
	mobf_assert_backtrace(pos ~= nil)
	mobf_assert_backtrace(pos.x ~= nil)
	mobf_assert_backtrace(pos.z ~= nil)
	
	if grid[pos.x] == nil then
		return nil
	end
	
	return grid[pos.x][pos.z]
end

function realpos(data,ipos)
	
	return  {
		x= data.limits.x.min + ipos.x,
		z= data.limits.z.min + ipos.z,
		y= ipos.y
		}
end

function getipos(data,pos)
	--todo check pos to be within limits

	return {
		x= pos.x - data.limits.x.min,
		z= pos.z - data.limits.z.min,
		y= pos.y
	}
end

function remdir(_table,dir)

	for i=1,#_table,1 do
		if path_samepos(_table[i],dir) then
			table.remove(_table,i)
			return
		end
	end
end

function v2add(v1,v2)
	return {
			x= v1.x + v2.x,
			z= v1.z + v2.z
			}
end

function v2inv(v)
	return {
		x = v.x * -1,
		z = v.z * -1
		}
end
-------------------------------------------------------------------------------
-- name: path_samepos(pos1,pos2)
--
--! @brief check if two positions are identical ignoring y value
--
--! @param pos1 first position
--! @param pos2 second position
--
--! @return true/false
-------------------------------------------------------------------------------
function path_samepos(pos1,pos2)

	if pos1 == nil or
		pos2 == nil then
		return false
	end

	if pos1.x == pos2.x and
		pos1.z == pos2.z then
		return true
	end	
	return false
end

-------------------------------------------------------------------------------
-- name: get_cost(g_pos,dir)
--
--! @brief access weight of a movement in direction
--
--! @param g_pos position to start movement
--! @param dir direction to move to
--
--! @return cost of movement or nil
-------------------------------------------------------------------------------
function get_cost(g_pos,dir)
	mobf_assert_backtrace(dir ~= nil)
	mobf_assert_backtrace(g_pos ~= nil)

	if dir.x > 0 then
		return g_pos.xp_weight
	end
	
	if dir.x < 0 then
		return g_pos.xm_weight
	end
	
	if dir.z > 0 then
		return g_pos.zp_weight
	end
	
	if dir.z < 0 then
		return g_pos.zm_weight
	end
	
	return nil
end


-------------------------------------------------------------------------------
-- name: find_shortest_path(pos1,pos2,maxdrop,maxjump,minheight,maxsurrounding)
--
--! @brief find shortest path from pos1 to pos2
--
--! @param pos1 startpos
--! @param pos2 endpos
--! @param maxdrop maximum height to drop down
--! @param maxjump maximum height to jump up
--! @param minheight minimum height to pass (UNUSED)
--! @param maxsurrounding maximum area around positions (not between) to consider
--! @param algo algorithm to use
--
--! @return path from pos1 -> pos2 or nil
-------------------------------------------------------------------------------
function find_path(pos1,pos2,maxdrop,maxjump,minheight,maxsurrounding,algo)
	
	local total_starttime = mobf_get_time_ms()

	--prepare context
	local data = create_context(pos1,pos2,maxdrop,maxjump,minheight,maxsurrounding)

	--build 2d weight map
	build_cost_map(data)
	mobf_warn_long_fct(total_starttime,"build weight map","pathfind")

	local path_starttime = mobf_get_time_ms()
	
	
	--debug_print_xp_weight(data)
	--debug_print_xm_weight(data)
	--debug_print_zp_weight(data)
	--debug_print_zm_weight(data)
	--debug_print_height(data)
	
	--mark start and end point
	print("MOBF: pathfinder v1 mark start and stop")
	gridat(data.grid,getipos(data,pos2)).istarget = true
	gridat(data.grid,getipos(data,pos1)).pathlength = 0
	
	local lengthfunc = nil
	
	--debug_print_area_paths(data)
	if algo == "short" then
		lengthfunc = update_all_lengths
	else
		lengthfunc = update_lengths_heuristic
	end
	
	print("MOBF: calculate path lenght")
	--mark all positions with their pathlenght and check if there is at least
	--one path to target
	if lengthfunc(data,getipos(data,pos1),nil,0,0) then
		mobf_warn_long_fct(path_starttime,"find path","pathfind")
		debug_print_area_paths(data)
		local fullpath = {}

		build_path(data,fullpath,getipos(data,pos2))
		
		debug_print_path(data)
		
		--remvoe all nodes wich are on a line of sight
		local optimized_path = {}
		
		local startpos = 1
		table.insert(optimized_path,gridat(data.grid,fullpath[1]).pos)
		for i=2,#fullpath, 1 do
			--print("MOBF: check for line of sight " .. 
			--	printpos(gridat(data.grid,fullpath[startpos]).pos) .. "-->" ..
			--	printpos(gridat(data.grid,fullpath[i]).pos))
			if not mobf_line_of_sight(
					gridat(data.grid,fullpath[startpos]).pos,
					gridat(data.grid,fullpath[i]).pos) then
				table.insert(optimized_path,gridat(data.grid,fullpath[i-1]).pos)
				startpos = i-1
			end
		end
		
		table.insert(optimized_path,gridat(data.grid,fullpath[#fullpath]).pos)
		mobf_warn_long_fct(total_starttime,"complete","pathfind")
		local endtime = mobf_get_time_ms()
		print("MOBF: took: " .. (endtime - total_starttime) .. " ms starttime: " .. total_starttime .. " endtime: " .. endtime)
		return optimized_path;
	end
	mobf_warn_long_fct(path_starttime,"find path","pathfind")
	mobf_warn_long_fct(total_starttime,"complete","pathfind")
	debug_print_area_paths(data)
	return nil
end

-------------------------------------------------------------------------------
-- name: create_context(pos1,pos2,maxdrop,maxjump,minheight,maxsurrounding)
--
--! @brief create a contect containing all data relevant for calculation
--
--! @param pos1 startpos
--! @param pos2 endpos
--! @param maxdrop maximum height to drop down
--! @param maxjump maximum height to jump up
--! @param minheight minimum height to pass (UNUSED)
--! @param maxsurrounding maximum area around positions (not between) to consider
--
--! @return context with all validated data or nil
-------------------------------------------------------------------------------
function create_context(pos1,pos2,maxdrop,maxjump,minheight,maxsurrounding)
	print("MOBF: create context")
	local data = {}
	
	data.min = {
			x = MIN(pos1.x,pos2.x),
			z = MIN(pos1.z,pos2.z)
			}
	data.max = {
			x = MAX(pos1.x,pos2.x),
			z = MAX(pos1.z,pos2.z)
			}
			
	data.limits = {
		x = {
			min = data.min.x - maxsurrounding,
			max = data.max.x + maxsurrounding
		},
		z = {
			min = data.min.z - maxsurrounding,
			max = data.max.z + maxsurrounding
		
		}
	}
	
	data.maxjump   = maxjump
	data.maxdrop   = maxdrop
	data.minheight = minheight
	data.miny      = MIN(pos1.y,pos2.y) - maxsurrounding
	data.maxy      = MAX(pos1.y,pos2.y) + maxsurrounding
	data.min_target_distance = nil
	
	data.source = pos1
	data.target = pos2

	return data
end

-------------------------------------------------------------------------------
-- name: build_cost_map(data)
--
--! @brief build map containing all movement costs
--
--! @param data data to operate on
--
-------------------------------------------------------------------------------
function build_cost_map(data)
	print("MOBF: calculate cost of movement for whole considered area")
	data.grid = {}
	
	for i=1, data.limits.x.max - data.limits.x.min, 1 do
		data.grid[i] = {}
	for j=1, data.limits.z.max - data.limits.z.min, 1 do
		local ipos = {x=i,z=j}
		local pos  = realpos(data,ipos)
		pos.y = mobf_get_surface(pos.x,pos.z, data.miny, data.maxy)
		
		--print("MOBF: pathfinder v1 calculating weights for " .. printpos(ipos) .. " " .. printpos(pos))
		
		local toadd = {
			pos = pos,
			pathlength     = -1,
		}
		
		data.grid[i][j] = toadd
		
		if pos.y ~= nil then
			--data.node = minetest.env:get_node(pos)
			toadd.xp_weight = calc_cost(data,ipos,{x= 1,z= 0})
			toadd.xm_weight = calc_cost(data,ipos,{x=-1,z= 0})
			toadd.zp_weight = calc_cost(data,ipos,{x= 0,z= 1})
			toadd.zm_weight = calc_cost(data,ipos,{x= 0,z=-1})
		end
		
		--print("\t xp  : " .. dump(data.grid[i][j].xp_weight))
		--print("\t xm  : " .. dump(data.grid[i][j].xm_weight))
		--print("\t zp  : " .. dump(data.grid[i][j].zp_weight))
		--print("\t zm  : " .. dump(data.grid[i][j].zm_weight))
		--print("\t path: " .. dump(gridat(data.grid,{x=i,z=j}).pathlength))
	end
	end
end
-------------------------------------------------------------------------------
-- name: calc_cost(data,ipos,dir)
--
--! @brief calculate weight for transition from ipos in direction dir
--
--! @param data data to operate on
--! @param ipos index position to set weight for
--! @param dir direction to move
--! @return weight of transition
-------------------------------------------------------------------------------
function calc_cost(data,ipos,dir)
	local g_pos = gridat(data.grid,ipos)
	
	local ipos2 =  {
				x= ipos.x + dir.x,
				z= ipos.z + dir.z
				}
				
	--not within checked area
	if ipos2.x <= 0 or
		ipos2.z <= 0 then
		--print("\t " .. printpos(dir) .. " out of area negative")
		return nil
	end
				
	local pos2 = realpos(data,ipos2)
	
	--not within checked area
	if pos2.x > data.limits.x.max or
		pos2.z > data.limits.z.max then
		--print("\t " .. printpos(dir) .. " out of area positive")
		return nil
	end
	
	local y_surface = nil
	local g_pos2 = gridat(data.grid,ipos2)
	if g_pos2 ~= nil then
		y_surface = g_pos2.pos.y
	else
		y_surface = mobf_get_surface(pos2.x,pos2.z, data.miny, data.maxy)
	end
	
	--print("\t " .. printpos(dir) .. " oldy = " .. g_pos.pos.y .. " new y = " .. dump(y_surface))
	
	if y_surface == nil then
		return nil
	end
	
	--not same level
	if g_pos.pos.y ~= y_surface then
		if g_pos.pos.y > y_surface then
			local diff = g_pos.pos.y - y_surface
			if diff > data.maxdrop then
				return nil
			end
			if diff > 1 then
				return 3
			end
			
			return 2
		else
			local diff = y_surface - g_pos.pos.y
			
			if diff > data.maxjump then
				return nil
			end
			
			return 2
		end
	end

	--same level
	return 1
end


-------------------------------------------------------------------------------
-- name:  build_path(data,shortestpath,ipos)
--
--! @brief build list containing shortest path
--
--! @param data data to operate on
--! @param list to store path
--! @param current pos
--
-------------------------------------------------------------------------------
function build_path(data,shortestpath,ipos)

		mobf_assert_backtrace(data ~= nil)
		mobf_assert_backtrace(shortestpath ~= nil)
	
		local g_pos = gridat(data.grid,ipos)
		g_pos.iselement = 1
		mobf_assert_backtrace(g_pos ~= nil)
		
		--abort if source has been reached
		if g_pos.pathlength == 0 then
			table.insert(shortestpath,ipos)
			return
		end
		
		mobf_assert_backtrace(g_pos.srcdir ~= nil)
		local newpos =  {
					x=ipos.x + g_pos.srcdir.x,
					z=ipos.z + g_pos.srcdir.z
				}

		build_path(data,shortestpath,newpos)
		table.insert(shortestpath,newpos)
end

-------------------------------------------------------------------------------
-- name: update_all_lengths(data,ipos,srcdir,cur_length)
--
--! @brief length for a new pos
--
--! @param data data to operate on
--! @param ipos index position to set weight for
--! @param dir direction to move
--! @return weight of transition
-------------------------------------------------------------------------------
function update_all_lengths(data,ipos,srcdir,cur_length,lvl)

	local g_pos = gridat(data.grid,ipos)

	lvl = lvl +1

	-- check if target reached
	if g_pos.istarget then 
		if g_pos.pathlength < 0 or
			g_pos.pathlength > cur_length then
		g_pos.pathlength = cur_length
		g_pos.srcdir = srcdir
		data.min_target_distance = cur_length
		end
		return true
	end
	
	local retval = false
	local directions = {}
	table.insert(directions,{x= 1,z= 0})
	table.insert(directions,{x=-1,z= 0})
	table.insert(directions,{x= 0,z= 1})
	table.insert(directions,{x= 0,z=-1})
	
	for i=1,#directions,1 do
		if not path_samepos(directions[i],srcdir) then
		
			local ipos2 = v2add(ipos,directions[i])
			local g_pos2 = gridat(data.grid,ipos2)
			
			--print("(" .. lvl .. ") MOBF: check for update " .. 
			--	printpos(ipos) .. "-->" .. printpos(ipos2) .. 
			--	" cur_length: " .. dump(cur_length))
			--found better way to g_pos2
			if g_pos2 ~= nil then
				local addonweight = get_cost(g_pos,directions[i])
				
				if addonweight ~= nil then
					local newlength = cur_length + addonweight
					
					if data.min_target_distance ~= nil and
						data.min_target_distance < newlength then
						return false
					end
					
					if g_pos2.pathlength < 0 or
						g_pos2.pathlength > newlength then
						--print("\t(" .. lvl .. ") updating " .. printpos(directions[i]) .. " weight: " .. dump(addonweight))
						g_pos2.pathlength = newlength
						g_pos2.srcdir     = v2inv(directions[i])
						--print("\t(" .. lvl .. ") set lenght at: " .. printpos(directions[i]) .. " to " .. dump(g_pos2.pathlength))
						
						if update_all_lengths(data,ipos2,v2inv(directions[i]),
											newlength,lvl) or retval == true then
							retval = true
						end
					else
						--print("\t(" .. lvl .. ") not updating " .. 
						--	printpos(directions[i]) .. 
						--	" oldlength: " .. dump(g_pos2.pathlength) ..
						--	" newlenght: " .. newpath)
					end
				else
					--print("\t(" .. lvl .. ") not updating " .. printpos(directions[i]) .. " weight: " .. dump(addonweight))
					--debug_print_g_pos(g_pos)
				end
			else
				--print("\t(" .. lvl .. ") not updating " .. printpos(directions[i]))
			end
		end
	end
	return retval
end

-------------------------------------------------------------------------------
-- name: update_lengths_heuristic(data,ipos,srcdir,cur_length)
--
--! @brief length for a new pos
--
--! @param data data to operate on
--! @param ipos index position to set weight for
--! @param dir direction to move
--! @return weight of transition
-------------------------------------------------------------------------------
function update_lengths_heuristic(data,ipos,srcdir,cur_length,lvl)
	local g_pos = gridat(data.grid,ipos)

	lvl = lvl +1

	-- check if target reached
	if g_pos.istarget then 
		if g_pos.pathlength < 0 or
			g_pos.pathlength > cur_length then
		g_pos.pathlength = cur_length
		g_pos.srcdir = srcdir
		data.min_target_distance = cur_length
		end
		return true
	end
	
	local retval = false
	local continue = true
	
	local directions = {}
	table.insert(directions,{x= 1,z= 0})
	table.insert(directions,{x=-1,z= 0})
	table.insert(directions,{x= 0,z= 1})
	table.insert(directions,{x= 0,z=-1})
	
	
	remdir(directions,srcdir)
	
	while retval == false and
			continue do
		
		local tocheck = get_dir_heuristic(data,g_pos,directions)
		
		if tocheck ~= nil then
		
			remdir(directions,tocheck)
			
			local ipos2 = v2add(ipos,tocheck)
			local g_pos2 = gridat(data.grid,ipos2)
			
			if g_pos2 ~= nil then
				local addonweight = get_cost(g_pos,tocheck)
				
				if addonweight ~= nil then
				
					local length_new = cur_length + addonweight
					
					if data.min_target_distance ~= nil and
						data.min_target_distance < length_new then
						return false
					end
					
					if g_pos2.pathlength < 0 or
						g_pos2.pathlength > length_new then
						--print("\t(" .. lvl .. ") updating " .. printpos(directions[i]) .. " weight: " .. dump(addonweight))
						g_pos2.pathlength = length_new
						g_pos2.srcdir     = v2inv(tocheck)
						--print("\t(" .. lvl .. ") set lenght at: " .. printpos(directions[i]) .. " to " .. dump(g_pos2.pathlength))
						
						retval = update_lengths_heuristic(data,ipos2,
											v2inv(tocheck),length_new,lvl)
					else
						--print("\t(" .. lvl .. ") not updating " .. 
						--	printpos(directions[i]) .. 
						--	" oldlength: " .. dump(g_pos2.pathlength) ..
						--	" newlenght: " .. newpath)
					end
				else
					--print("\t(" .. lvl .. ") not updating " .. printpos(directions[i]) .. " weight: " .. dump(addonweight))
					--debug_print_g_pos(g_pos)
				end
			else
				--print("\t(" .. lvl .. ") not updating " .. printpos(directions[i]))
			end
		else
			continue = false
		end
	end
	
	return retval
end

-------------------------------------------------------------------------------
-- name: get_manhattandistance2(pos1,pos2)
--
--! @brief calculate 2D manhattan distance between two points
--
--! @param pos1 source pos
--! @param pos2 destination pos
--
--! @return manhattan distance
-------------------------------------------------------------------------------
function get_manhattandistance2(pos1,pos2)

	min_x = MIN(pos1.x,pos2.x)
	max_x = MAX(pos1.x,pos2.x)
	min_z = MIN(pos1.z,pos2.z)
	max_z = MAX(pos1.z,pos2.z)

	return (max_x - min_x) + (max_z - min_z)
end

-------------------------------------------------------------------------------
-- name: get_dir_heuristic(data,g_pos,directions)
--
--! @brief length for a new pos
--
--! @param data data to operate on
--! @param g_pos source position
--! @param directions available not checked directions
--
--! @return direction to check or nil
-------------------------------------------------------------------------------
function get_dir_heuristic(data,g_pos,directions)

	local minscore = -1
	local retdir = nil
	local srcpos = g_pos.pos
	
	for i=1,#directions,1 do
		pos1 =  {
				x= srcpos.x + directions[i].x,
				z= srcpos.z + directions[i].z
			}
			
		local cur_manhattan = get_manhattandistance2(pos1,data.target)
		local cost          = get_cost(g_pos,directions[i])
		
		if cost ~= nil then
			local score = cost + cur_manhattan
			
			if minscore < 0 or
				score < minscore then
				
				minscore = score
				retdir = directions[i]
			end
		end
	end
	return retdir
end