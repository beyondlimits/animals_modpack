-------------------------------------------------------------------------------
-- Mob Framework Mod by Sapier
-- 
-- You may copy, use, modify or do nearly anything except removing this
-- copyright notice. 
-- And of course you are NOT allow to pretend you have written it.
--
--! @file willow.lua
--! @brief spawn algorithm willow
--! @copyright Sapier
--! @author Sapier
--! @date 2012-08-09
--
--! @addtogroup spawn_algorithms
--! @{
-- Contact sapier a t gmx net
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- name: mobf_spawn_on_willow(mob_name,mob_transform,spawning_data,environment)
--
--! @brief find a place on willow to spawn a mob
--
--! @param mob_name name of mob
--! @param mob_transform secondary name of mob
--! @param spawning_data spawning configuration
--! @param environment environment of mob
-------------------------------------------------------------------------------
function mobf_spawn_on_willow(mob_name,mob_transform,spawning_data,environment) 
	minetest.log(LOGLEVEL_WARNING,"MOBF: using deprecated abm based spawn algorithm \"spawn_on_willow\" most likely causing lag in server!\t Use spawn_on_willow_mapgen instead!")
	minetest.log(LOGLEVEL_INFO,"MOBF:\tregistering willow spawn abm callback for mob "..mob_name)
	
	local media = nil
	
	if environment ~= nil and
		environment.media ~= nil then
		media = environment.media	
	end

	minetest.register_abm({
			nodenames = { "default:dirt_with_grass" },
			neighbors = media,
			interval = 7200,
			chance = math.floor(1/spawning_data.rate),
			action = function(pos, node, active_object_count, active_object_count_wider)
				local starttime = mobf_get_time_ms()
				local pos_above = {
					x = pos.x,
					y = pos.y + 1,
					z = pos.z
				}

				--never try to spawn an mob at pos (0,0,0) it's initial entity spawnpos and
				--used to find bugs in initial spawnpoint setting code
				if mobf_pos_is_zero(pos) then
					mobf_warn_long_fct(starttime,"mobf_spawn_on_willow")
					return
				end

				--check if there s enough space above to place mob
				if mobf_air_above(pos,spawning_data.height) ~= true then
					mobf_warn_long_fct(starttime,"mobf_spawn_on_willow")
					return
				end

				local node_above = minetest.env:get_node(pos_above)

				if mob_name == nil then
					minetest.log(LOGLEVEL_ERROR,"MOBF: BUG!!! mob name not available")
				else
					--print("Try to spawn mob: "..mob_name)
					if node_above.name == "air" then
						--print("Find mobs of same type around:"..mob_name.. " pop dens: ".. population_density)
					   if mobf_mob_around(mob_name,mob_transform,pos,spawning_data.density,true) == 0 then
							local newobject = minetest.env:add_entity(pos_above,mob_name)

							local newentity = mobf_find_entity(newobject)
							
							if newentity == nil then
								minetest.log(LOGLEVEL_ERROR,"MOBF: BUG!!! no "..mob_name.." has been created!")
							end
							minetest.log(LOGLEVEL_INFO,"MOBF: Spawning "..mob_name.." on willow at position "..printpos(pos))
						end
					end
				end
				mobf_warn_long_fct(starttime,"mobf_spawn_on_willow")
			end,
		})
end

function mobf_spawn_on_willow_mapgen(mob_name,mob_transform,spawning_data,environment)

	minetest.log(LOGLEVEL_INFO,"MOBF:\tregistering willow mapgen spawn mapgen callback for mob "..mob_name)
	
	--add mob on map generation
	minetest.register_on_generated(function(minp, maxp, seed)
	local starttime = mobf_get_time_ms()
	
    local min_x = MIN(minp.x,maxp.x)
    local min_y = MIN(minp.y,maxp.x)
    local min_z = MIN(minp.z,maxp.z)
    
    local max_x = MAX(minp.x,maxp.x)
    local max_y = MAX(minp.y,maxp.y)
    local max_z = MAX(minp.z,maxp.z)
    
    
    local xdivs = math.floor(((max_x - min_x) / spawning_data.density) +1)
    local zdivs = math.floor(((max_z - min_z) / spawning_data.density) +1)
    
    dbg_mobf.spawning_lvl3(min_x .. " " .. max_x .. " # " .. min_z .. " " .. max_z)
    dbg_mobf.spawning_lvl3("Generating in " .. xdivs .. " | " .. zdivs .. " chunks")
    
    for i = 0, xdivs do
    for j = 0, zdivs do
    local x_center = min_x + 0.5 * spawning_data.density + spawning_data.density * i
    local z_center = min_z + 0.5 * spawning_data.density + spawning_data.density * i
    local surface_center = mobf_get_surface(x_center,z_center,min_y,max_y)
    
    local centerpos = {x=x_center,y=surface_center,z=z_center}
        
    --check if there is already a mob of same type within area growing tree within area
    if surface_center  and 
    	mobf_mob_around(mob_name,mob_transform,centerpos,spawning_data.density,true) == 0 then
    	dbg_mobf.spawning_lvl3("no " .. mob_name .. " within range of " .. spawning_data.density .. " around " ..printpos(centerpos))
        for i= 0, 5 do
            local x_try = math.random(spawning_data.density/-2,spawning_data.density/2)
            local z_try = math.random(spawning_data.density/-2,spawning_data.density/2)
            
            local pos = { x= x_center + x_try,
                           z= z_center + z_try }
            
            local surface = mobf_get_surface(pos.x,pos.z,min_y,max_y)
            
            if surface then
            	pos.y=surface
            	--check if there s enough space above to place mob
				if mobf_air_above(pos,spawning_data.height) then
					dbg_mobf.spawning_lvl3("enough air above " ..printpos(centerpos) .. " minimum is: " .. spawning_data.height )
                    local spawnpos = {x=pos.x,y=surface+1,z=pos.z}
                    local newobject = minetest.env:add_entity(spawnpos,mob_name)
                    
                    if newobject then
						local newentity = mobf_find_entity(newobject)
						
						if newentity == nil then
							dbg_mobf.spawning_lvl3("BUG!!! no "..mob_name.." has been created!")
							minetest.log(LOGLEVEL_ERROR,"MOBF: BUG!!! no "..mob_name.." has been created!")
						else
							dbg_mobf.spawning_lvl3("Spawning "..mob_name.." on willow at position "..printpos(spawnpos))
							minetest.log(LOGLEVEL_INFO,"MOBF: Spawning "..mob_name.." on willow at position "..printpos(spawnpos))
						end
					else
						dbg_mobf.spawning_lvl3("BUG!!! no "..mob_name.." object has been created!")
						minetest.log(LOGLEVEL_ERROR,"MOBF: BUG!!! no "..mob_name.." object has been created!")
					end
					
					break
				end -- air_above
            end -- surface
        end --for -> 5
    end --mob around
    end -- for z divs
    end -- for x divs
    dbg_mobf.spawning_lvl3("magen ended")
    end) --register mapgen
 end --end spawn algo
--!@}

spawning.register_spawn_algorithm("willow", mobf_spawn_on_willow)
spawning.register_spawn_algorithm("willow_mapgen", mobf_spawn_on_willow_mapgen)