-------------------------------------------------------------------------------
-- Mob Framework Mod by Sapier
-- 
-- You may copy, use, modify or do nearly anything except removing this
-- copyright notice. 
-- And of course you are NOT allow to pretend you have written it.
--
--! @file init.lua
--! @brief ostrich implementation
--! @copyright Sapier
--! @author Sapier
--! @date 2013-01-27
--
-- Contact sapier a t gmx net
-------------------------------------------------------------------------------
minetest.log("action","MOD: mob_ostrich mod loading ...")
local version = "0.0.8"

local ostrich_groups = {
						not_in_creative_inventory=1
					}

local selectionbox_ostrich = {-0.5, -0.9, -0.5, 0.5, 0.6, 0.5}

function ostrich_drop()
	local result = {}
	if math.random() < 0.05 then
		table.insert(result,"animalmaterials:feather 2")
	else
		table.insert(result,"animalmaterials:feather 1")
	end
	
	table.insert(result,"animalmaterials:meat_ostrich 2")
	
	return result
end

ostrich_f_prototype = {
		name="ostrich_f",
		modname="mob_ostrich",
		
		factions = {
			member = {
				"animals",
				"grassland_animals"
				}
			},
	
		generic = {
					description="Ostrich (f)",
					base_health=10,
					kill_result=ostrich_drop,
					armor_groups= {
						fleshy=90,
					},
					groups = ostrich_groups,
					envid = "meadow",
					stepheight=1.1,
				},
		movement =  {
					min_accel=0.05,
					max_accel=0.3,
					max_speed=1.0,
					min_speed=0.1,
					pattern="stop_and_go",
					canfly = false,
					},
		catching = {
					tool="animalmaterials:lasso",
					consumed=true,
					},
		random_drop = {
 					result="animalmaterials:egg_big",
 					min_delay=300,
 					chance=0.1
 					},
		spawning = {
					primary_algorithms = {
						{
						rate=0.001,
						density=600,
						algorithm="willow_mapgen",
						height=2
						},
					},
					secondary_algorithms = {
						{
						rate=0.001,
						density=600,
						algorithm="willow",
						height=2
						},
					}
				},
		ride = {
					walkspeed  = 7.8,
					sneakspeed = 0.8,
					jumpspeed  = 58,
					attacheoffset = { x=0,y=2,z=0},
					texturemod = "^mob_ostrich_ostrich_saddle_mesh.png",
					walk_anim = "walk"
			},
		animation = {
				walk = {
					start_frame = 41,
					end_frame   = 81,
					basevelocity = 0.28,
					},
				stand = {
					start_frame = 1,
					end_frame   = 40,
					},
			},
		states = {
				{ 
				name = "default",
				movgen = "none",
				chance = 0,
				animation = "stand",
				graphics_3d = {
					visual = "mesh",
					mesh = "mob_ostrich_ostrich.b3d",
					textures = {"mob_ostrich_ostrich_mesh.png"},
					collisionbox = selectionbox_ostrich,
					visual_size= {x=0.95,y=0.95,z=0.95},
					},
				typical_state_time = 30,
				},
				{ 
				name = "walking",
				movgen = "probab_mov_gen",
				chance = 0.50,
				animation = "walk",
				typical_state_time = 180,
				},
			},
		}
		
ostrich_m_prototype = {   
		name="ostrich_m",
		modname="mob_ostrich",
		
		factions = {
			member = {
				"animals",
				"grassland_animals"
				}
			},

		generic = {
					description="Ostrich (m)",
					base_health=11,
					kill_result=ostrich_drop,
					armor_groups= {
						fleshy=90,
					},
					groups = ostrich_groups,
					envid = "meadow",
					stepheight=1.1,
				},
		movement =  {
					min_accel=0.05,
					max_accel=0.3,
					max_speed=1.0,
					min_speed=0.1,
					pattern="stop_and_go",
					canfly = false,
					},
		catching = {
					tool="animalmaterials:lasso",
					consumed=true,
					},
		spawning = {
					primary_algorithms = {
						{
						rate=0.001,
						density=600,
						algorithm="willow_mapgen",
						height=2
						}
					}
				},
		ride = {
					walkspeed  = 8,
					sneakspeed = 1,
					jumpspeed  = 60,
					attacheoffset = { x=0,y=2,z=0},
					texturemod = "^mob_ostrich_ostrich_saddle_mesh.png",
					walk_anim = "walk"
				},
		animation = {
				walk = {
					start_frame = 41,
					end_frame   = 81,
					basevelocity = 0.28,
					},
				stand = {
					start_frame = 1,
					end_frame   = 40,
					},
			},
		states = {
				{ 
					name = "default",
					movgen = "none",
					chance = 0,
					animation = "stand",
					graphics_3d = {
						visual = "mesh",
						mesh = "mob_ostrich_ostrich.b3d",
						textures = {"mob_ostrich_ostrich_mesh.png"},
						collisionbox = selectionbox_ostrich,
						visual_size= {x=1,y=1,z=1},
						},
					typical_state_time = 30,
				},
				{ 
					name = "walking",
					movgen = "probab_mov_gen",
					chance = 0.25,
					animation = "walk",
					typical_state_time = 180,
				},
				
				{ 
					name = "default",
					movgen = "none",
					chance = 0,
					animation = "stand",
					graphics_3d = {
						visual = "mesh",
						mesh = "mob_ostrich_ostrich.b3d",
						textures = {"mob_ostrich_ostrich_mesh.png"},
						collisionbox = selectionbox_ostrich,
						visual_size= {x=1,y=1,z=1},
						},
					typical_state_time = 30,
				},
			},
		}

--register with animals mod
minetest.log("action","\tadding mob "..ostrich_m_prototype.name)
mobf_add_mob(ostrich_m_prototype)
minetest.log("action","\tadding mob "..ostrich_f_prototype.name)
mobf_add_mob(ostrich_f_prototype)

minetest.log("action","MOD: mob_ostrich mod            version " .. version .. " loaded")