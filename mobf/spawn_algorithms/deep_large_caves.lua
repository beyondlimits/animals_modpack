-------------------------------------------------------------------------------
-- Mob Framework Mod by Sapier
-- 
-- You may copy, use, modify or do nearly anything except removing this
-- copyright notice. 
-- And of course you are NOT allow to pretend you have written it.
--
--! @file deep_large_caves.lua
--! @brief spawn algorithm to spawn in deep large caves
--! @copyright Sapier
--! @author Sapier
--! @date 2012-08-09
--
--! @addtogroup spawn_algorithms
--! @{
-- Contact sapier a t gmx net
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- name: mobf_spawn_in_deep_large_caves(mob_name,mob_transform,spawning_data,environment)
--
--! @brief find a place with low light to spawn an mob
--
--! @param mob_name name of mob
--! @param mob_transform secondary name of mob
--! @param spawning_data spawning configuration
--! @param environment environment of mob
-------------------------------------------------------------------------------

function mobf_spawn_in_deep_large_caves(mob_name,mob_transform,spawning_data,environment) 

	minetest.log(LOGLEVEL_INFO,"MOBF:\tregistering shadow spawn abm callback for mob "..mob_name)
	
	local media = nil
	
	if environment ~= nil and
		environment.media ~= nil then
		media = environment.media	
	end

	minetest.register_abm({
			nodenames = { "default:stone" },
			neighbors = media,
			interval = 60,
			chance = math.floor(1/spawning_data.rate),
			action = function(pos, node, active_object_count, active_object_count_wider)
				local starttime = mobf_get_time_ms()
				local pos_above = {
					x = pos.x,
					y = pos.y + 1,
					z = pos.z
				}
				
				if pos.y > spawning_data.min_depth then
					dbg_mobf.spawning_lvl3("MOBF: min depth requirement not met")
					mobf_warn_long_fct(starttime,"mobf_spawn_in_deep_large_caves")
					return
				end

				--never try to spawn an mob at pos (0,0,0) it's initial entity spawnpos and
				--used to find bugs in initial spawnpoint setting code
				if mobf_pos_is_zero(pos) then
					dbg_mobf.spawning_lvl1("MOBF: not spawning due to 0 pos")
					mobf_warn_long_fct(starttime,"mobf_spawn_in_deep_large_caves")
					return
				end

				--check if there s enough space above to place mob
				if mobf_air_above(pos,spawning_data.height) ~= true then
					dbg_mobf.spawning_lvl3("MOBF: height requirement not met")
					mobf_warn_long_fct(starttime,"mobf_spawn_in_deep_large_caves")
					return
				end

				local node_above = minetest.get_node(pos_above)

				if mob_name == nil then
					minetest.log(LOGLEVEL_ERROR,"MOBF: Bug!!! mob name not available")
				else
					dbg_mobf.spawning_lvl3("MOBF: trying to spawn " .. mob_name)
					if mobf_mob_around(mob_name,mob_transform,pos,spawning_data.density,true) == 0 then
						local newobject = minetest.add_entity(pos_above,mob_name .. "__default")

						local newentity = mobf_find_entity(newobject)

						if newentity == nil then
							minetest.log(LOGLEVEL_ERROR,"MOBF: unable to create mob " .. mob_name .. " at pos " .. printpos(pos))
						else
							minetest.log(LOGLEVEL_INFO,"MOBF: Spawning "..mob_name.." in shadows at position "..printpos(pos))
						end
					else
						dbg_mobf.spawning_lvl3("MOBF: too many mobs next to " ..printpos(pos))
					end
				end
			mobf_warn_long_fct(starttime,"mobf_spawn_in_deep_large_caves")
			end,
		})
end

-------------------------------------------------------------------------------
-- name: mobf_spawn_in_deep_large_caves(mob_name,mob_transform,spawning_data,environment)
--
--! @brief find a place in deep large caces to spawn
--
--! @param mob_name name of mob
--! @param mob_transform secondary name of mob
--! @param spawning_data spawning configuration
--! @param environment environment of mob
-------------------------------------------------------------------------------
function mobf_spawn_in_deep_large_caves_entity(mob_name,mob_transform,spawning_data,environment)

	spawning.register_spawner_entity(mob_name,mob_transform,spawning_data,environment,
		function(self)
			local pos = self.object:getpos()
			
			local newpos = pos
			
			local good = true
			local reason = ""
			
			local max_tries = 25
			
			for try=1,max_tries,1 do
				
				if newpos == nil then
					
					newpos = {}
					good = true
					
					local max_offset = 0.4*self.spawner_mob_spawndata.density
					
					dbg_mobf.spawning_lvl2("MOBF: trying to get new random value, max_offset:" ..max_offset)
					
					newpos.x = math.floor(pos.x + 
								math.random(0,max_offset) +
								0.5)
					newpos.z = math.floor(pos.z + 
								math.random(0,max_offset) +
								0.5)
					newpos.y = mobf_get_surface(newpos.x,newpos.z,pos.y-5, pos.y+5)
				end
			
				dbg_mobf.spawning_lvl3("MOBF: " .. dump(self.spawner_mob_env))
			
				if newpos.y ~= nil then
					--check if own position is good
					local pos_below = {x=newpos.x,y=newpos.y-1,z=newpos.z}
					local node_below = minetest.get_node(pos_below)
				
				
					if not mobf_contains({ "default:stone","default:gravel","default:dirt" },node_below.name) then
						reason = "wrong surface"
						good = false
					end
					
					--check if there s enough space above to place mob
					if mobf_air_above(pos_below,self.spawner_mob_spawndata.height) ~= true then
						reason = "ceiling to low"
						good = false
					end
				else
					good = false
					reason = "dlc: floor not found"
				end
				
				--this is first check
				if not good and try == 1 then
					dbg_mobf.spawning_lvl2("MOBF: deep large caves: not spawning for " 
					.. self.spawner_mob_name .. " somehow got to bad place: "..
					reason)
					--TODO try to move spawner to better place
				else
					--abort if we found a valid pos
					if good and try ~= 1 then
						try = max_tries +1
					else
						newpos = nil
					end
				end
			end
				
			if not good then
				dbg_mobf.spawning_lvl2("MOBF: DLC not spawning for " .. self.spawner_mob_name .. " somehow got to bad place")
				--TODO try to move spawner to better place
				
				self.spawner_time_passed = self.spawner_mob_spawndata.respawndelay
				self.spawner_last_result = dump(reason)
				return
			end
			
			if mobf_mob_around(self.spawner_mob_name,
							   self.spawner_mob_transform,
							   pos,
							   self.spawner_mob_spawndata.density,true) < 2 then

				if spawning.spawn_and_check(self.spawner_mob_name,
											"__default",
											newpos,
											"at_night_spawner_ent") then
					self.spawner_last_result = "dlc: successfull"
				else
					self.spawner_last_result = "dlc: spawning failed"
				end
				self.spawner_time_passed = self.spawner_mob_spawndata.respawndelay
			else
				self.spawner_time_passed = self.spawner_mob_spawndata.respawndelay
				dbg_mobf.spawning_lvl2("MOBF: not spawning " .. self.spawner_mob_name .. " there's a mob around")
				self.spawner_last_result = "dlc: mob around"
			end
		end)
		
	local spawnfunc = function(name,pos,min_y,max_y,spawning_data)
			if max_y > spawning_data.min_depth then
				return false
			end
		
			dbg_mobf.spawning_lvl3("MOBF: trying to create a spawner for " .. name .. " at " ..printpos(pos))
			local surface = mobf_get_surface(pos.x,pos.z,min_y,max_y)
			
			if surface then
				pos.y= surface -1
				
				local node = minetest.get_node(pos)
				
				if not mobf_contains({ "default:stone","default:gravel","default:dirt","default:sand" },node.name) then
					dbg_mobf.spawning_lvl3("MOBF: node ain't of correct type: " .. node.name)
					return false
				end
				
				local pos_above = {x=pos.x,y=pos.y+1,z=pos.z}
				local node_above = minetest.get_node(pos_above)
				if not mobf_contains({"air"},node_above.name) then
					dbg_mobf.spawning_lvl3("MOBF: node above ain't air but: " .. node_above.name)
					return false
				end
				
				spawning.spawn_and_check(name,"_spawner",pos_above,"deep_large_caves_spawner")
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
							maxtries      = 30,
							spawned       = 0,
							func          = spawning.divide_mapgen_entity_jobfunc
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

end
--!@}

spawning.register_spawn_algorithm("deep large caves", mobf_spawn_in_deep_large_caves)
spawning.register_spawn_algorithm("deep_large_caves_spawner", mobf_spawn_in_deep_large_caves_entity,spawning.register_cleanup_spawner)