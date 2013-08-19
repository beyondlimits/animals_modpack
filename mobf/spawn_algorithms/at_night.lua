-------------------------------------------------------------------------------
-- Mob Framework Mod by Sapier
-- 
-- You may copy, use, modify or do nearly anything except removing this
-- copyright notice. 
-- And of course you are NOT allow to pretend you have written it.
--
--! @file at_night.lua
--! @brief component containing spawning features
--! @copyright Sapier
--! @author Sapier
--! @date 2012-08-09
--
--! @addtogroup spawn_algorithms
--! @{
-- Contact sapier a t gmx net
-------------------------------------------------------------------------------

at_night_surfaces = { "default:stone","default:dirt_with_grass","default:dirt","default:desert_stone","default:desert_sand" }

-------------------------------------------------------------------------------
-- name: mobf_spawn_at_night(mob_name,mob_transform,spawning_data,environment)
--
--! @brief spawn only at night
--
--! @param mob_name name of mob
--! @param mob_transform secondary name of mob
--! @param spawning_data spawning configuration
--! @param environment environment of mob
-------------------------------------------------------------------------------
function mobf_spawn_at_night(mob_name,mob_transform,spawning_data,environment) 

	print("\tregistering night spawn abm callback for mob "..mob_name)
	
	local media = nil
	
	if environment ~= nil and
		environment.media ~= nil then
		media = environment.media	
	end

	minetest.register_abm({
			nodenames = at_night_surfaces,
			neighbors = media,
			interval = 20,
			chance = math.floor(1/spawning_data.rate),
			action = function(pos, node, active_object_count, active_object_count_wider)
				local gametime = minetest.get_timeofday()
				
				if gametime > 0.25 and
					gametime < 0.75 then
					mobf_warn_long_fct(starttime,"at_night_abm","abm")
					return
				end
			
				local starttime = mobf_get_time_ms()
				local pos_above = {
					x = pos.x,
					y = pos.y + 1,
					z = pos.z
				}

				--never try to spawn an mob at pos (0,0,0) it's initial entity spawnpos and
				--used to find bugs in initial spawnpoint setting code
				if mobf_pos_is_zero(pos) then
					mobf_warn_long_fct(starttime,"mobf_spawn_at_night")
					mobf_warn_long_fct(starttime,"at_night_abm","abm")
					return
				end

				--check if there s enough space above to place mob
				if mobf_air_above(pos,spawning_data.height) ~= true then
					mobf_warn_long_fct(starttime,"mobf_spawn_at_night")
					mobf_warn_long_fct(starttime,"at_night_abm","abm")
					return
				end
				
				local gametime = minetest.get_timeofday()
				
				if gametime > 0.25 and
					gametime < 0.75 then
					return
				end


				local node_above = minetest.get_node(pos_above)


				if mob_name == nil then
					minetest.log(LOGLEVEL_ERROR, "MOBF: Bug!!! mob name not available")
				else
					--print("Find mobs of same type around:"..mob_name.. " pop dens: ".. population_density)
					if mobf_mob_around(mob_name,mob_transform,pos,spawning_data.density,true) == 0 then
						if minetest.get_node_light(pos_above,0.5) == LIGHT_MAX +1 and 
							minetest.get_node_light(pos_above,0.0) < 7 and
							minetest.get_node_light(pos_above) < 6 then
							
							local entity = spawning.spawn_and_check(mob_name,"__default",pos_above,"at_night_spawner")
							
							if entity ~= nil and
								entity.dynamic_data ~= nil and
								entity.dynamic_data.spawning ~= nil then
								entity.dynamic_data.spawning.spawner = "at_night"
							end

							minetest.log(LOGLEVEL_INFO,"MOBF Spawning "..mob_name.." at night at position "..printpos(pos))
						end
					end
				end
				mobf_warn_long_fct(starttime,"mobf_spawn_at_night")
			end,
		})
end

-------------------------------------------------------------------------------
-- name: mobf_spawn_at_night_entity(mob_name,mob_transform,spawning_data,environment)
--
--! @brief find a place on surface to spawn at night
--
--! @param mob_name name of mob
--! @param mob_transform secondary name of mob
--! @param spawning_data spawning configuration
--! @param environment environment of mob
-------------------------------------------------------------------------------
function mobf_spawn_at_night_entity(mob_name,mob_transform,spawning_data,environment)
	minetest.log(LOGLEVEL_INFO,"MOBF:\tregistering at night mapgen spawn mapgen callback for mob "..mob_name)
	
	spawning.register_spawner_entity(mob_name,mob_transform,spawning_data,environment,
		function(self)
		
			--first check reasons to not spawn a mob right now
			local gametime = minetest.get_timeofday()
				
			if gametime > 0.20 and
				gametime < 0.75 then
				dbg_mobf.spawning_lvl3("MOBF: wrong time for at night spawner")
				self.spawner_last_result = "daytime"
				self.spawner_time_passed = self.spawner_mob_spawndata.respawndelay
				return
			end
			
			local pos = self.object:getpos()
			
			local newpos = {}
			local max_offset = 0.4*self.spawner_mob_spawndata.density
			
			newpos.x = math.floor(pos.x + 
						math.random(0,max_offset) +
						0.5)
			newpos.z = math.floor(pos.z + 
						math.random(0,max_offset) +
						0.5)
			newpos.y = mobf_get_surface(newpos.x,newpos.z,pos.y-5, pos.y+5)
			
			local good = true
			local reason = "unknown"
			
			dbg_mobf.spawning_lvl3("MOBF: " .. dump(self.spawner_mob_env))
			
			if newpos.y == nil then
				good = false
				reason = "no height found for random pos"
				newpos.y = 0
			end
			
			--check if own position is good
			local pos_below = {x=newpos.x,y=newpos.y-1,z=newpos.z}
			local node_below = minetest.get_node(pos_below)
			
			if good and not mobf_contains(at_night_surfaces,node_below.name) then
				reason = "wrong surface"
				good = false
			end
			
			--check if there s enough space above to place mob
			if good and mobf_air_above(pos_below,self.spawner_mob_spawndata.height) ~= true then
				reason = "to low"
				good = false
			end
			
			local light_day = minetest.get_node_light(newpos,0.5)
			local light_midnight = minetest.get_node_light(newpos,0.0)
			
			--check if area is in day/night cycle
			if good and (light_day ~= LIGHT_MAX +1 or
				light_midnight > 7) then
				reason = "wrong light: " .. light_day .. " " .. light_midnight
				good = false
			end
			
			local current_light = minetest.get_node_light(newpos)
			--check if current light is dark enough
			if not current_light or current_light > 6 then
				self.spawner_last_result = "at_night: to much light"
				good = false
			end
				
			if not good then
				dbg_mobf.spawning_lvl2("MOBF: not spawning at position not suitable" 
				.. self.spawner_mob_name .. " reason: " 
				.. reason)
				--Invalid position,
				--reduced delay to next retry
				self.spawner_time_passed = (self.spawner_mob_spawndata.respawndelay/4)
				self.spawner_last_result = "at_night:" .. dump(reason)
				return
			end

			dbg_mobf.spawning_lvl3("MOBF: at_night checking how many mobs around: " .. dump(self.spawner_mob_name))
			if mobf_mob_around(self.spawner_mob_name,
							   self.spawner_mob_transform,
							   pos,
							   self.spawner_mob_spawndata.density,true) < 2 then

				local entity = spawning.spawn_and_check(self.spawner_mob_name,"__default",newpos,"at_night_spawner_ent")
				if entity ~= nil and
					entity.dynamic_data ~= nil and
					entity.dynamic_data.spawning ~= nil then
					entity.dynamic_data.spawning.spawner = "at_night_mapgen"
					self.spawner_last_result = "at_night successfull"
				else
					self.spawner_last_result = "at_night failed to spawn"
				end
				self.spawner_time_passed = self.spawner_mob_spawndata.respawndelay
			else
				--too many mobs around full delay
				self.spawner_time_passed = self.spawner_mob_spawndata.respawndelay
				dbg_mobf.spawning_lvl2("MOBF: not spawning " .. self.spawner_mob_name .. " there's a mob around")
				self.spawner_last_result = "at_night: to much mobs around"
			end
		end,
		"_at_night")
		
	local spawnfunc = function(name,pos,min_y,max_y)
				dbg_mobf.spawning_lvl3("MOBF: trying to create a spawner for " .. name .. " at " ..printpos(pos))
				local surface = mobf_get_surface(pos.x,pos.z,min_y,max_y)
				
				if surface then
					pos.y= surface -1
					
					local node = minetest.get_node(pos)
					
					if not mobf_contains(at_night_surfaces,node.name) then
						dbg_mobf.spawning_lvl3("MOBF: node ain't of correct type: " .. node.name)
						return false
					end
					
					local pos_above = {x=pos.x,y=pos.y+1,z=pos.z}
					local node_above = minetest.get_node(pos_above)
					if not mobf_contains({"air"},node_above.name) then
						dbg_mobf.spawning_lvl3("MOBF: node above ain't air but: " .. node_above.name)
						return false
					end
					
					local light_day = minetest.get_node_light(pos_above,0.5)
					
					if light_day ~= (LIGHT_MAX +1) then
						dbg_mobf.spawning_lvl3("MOBF: node above ain't in sunlight")
						return false
					end
					
					dbg_mobf.spawning_lvl2("MOBF: adding spawner for mob: " .. name .. " " .. light_day)
					spawning.spawn_and_check(name,"_spawner_at_night",pos_above,"at_night_spawner")
					return true
				else
					dbg_mobf.spawning_lvl3("MOBF: didn't find surface for " .. name .. " spawner at " ..printpos(pos))
				end
				return false
			end
			
	if minetest.world_setting_get("mobf_delayed_spawning") then
		minetest.register_on_generated(function(minp, maxp, seed)
			local job = {
				callback = spawning.divide_mapgen_entity_jobfunc,
				data = {
					minp          = minp,
					maxp          = maxp,
					spawning_data = spawning_data,
					mob_name      = mob_name,
					spawnfunc     = spawnfunc,
					maxtries      = 5,
					func          = spawning.divide_mapgen_entity_jobfunc,
					}
				}
			mobf_job_queue.add_job(job)
		end)
	else	
		--add mob spawner on map generation
		minetest.register_on_generated(function(minp, maxp, seed)
			local starttime = mobf_get_time_ms()
			spawning.divide_mapgen_entity(minp,maxp,spawning_data,mob_name,spawnfunc)
			mobf_warn_long_fct(starttime,"on_mapgen " .. mob_name,"mapgen")
		end) --register mapgen
	end
 end --end spawn algo

--!@}

spawning.register_spawn_algorithm("at_night", mobf_spawn_at_night)
spawning.register_spawn_algorithm("at_night_spawner", mobf_spawn_at_night_entity,spawning.register_cleanup_spawner)