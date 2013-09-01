-------------------------------------------------------------------------------
-- Mob Framework Mod by Sapier
-- 
-- You may copy, use, modify or do nearly anything except removing this
-- copyright notice. 
-- And of course you are NOT allow to pretend you have written it.
--
--! @file init.lua
--! @brief chicken implementation
--! @copyright Sapier
--! @author Sapier
--! @date 2013-01-27
--
-- Contact sapier a t gmx net
-------------------------------------------------------------------------------
minetest.log("action","MOD: animal_chicken mod loading ...")
local version = "0.0.19"

local chicken_groups = {
						not_in_creative_inventory=1
					}

local selectionbox_chicken = {-0.25, -0.15, -0.25, 0.2, 0.25, 0.25}
local selectionbox_rooster = {-0.25, -0.20, -0.25, 0.2, 0.25, 0.25}
local selectionbox_chick = {-0.1, -0.125, -0.1, 0.1, 0.15, 0.1}

local modpath = minetest.get_modpath("animal_chicken")

function chicken_drop()
	local result = {}
	if math.random() < 0.05 then
		table.insert(result,"animalmaterials:feather 2")
	else
		table.insert(result,"animalmaterials:feather 1")
	end
	
	table.insert(result,"animalmaterials:meat_chicken 1")
	
	return result
end

chicken_prototype = {
		name="chicken",
		modname="animal_chicken",
		
		factions = {
			member = {
				"animals",
				"grassland_animals"
				}
			},
	
		generic = {
					description="Chicken",
					base_health=5,
					kill_result=chicken_drop,
					armor_groups= {
						fleshy=90,
					},
					groups = chicken_groups,
					envid = "meadow"
				},
		movement =  {
					min_accel=0.05,
					max_accel=0.1,
					max_speed=0.3,
					min_speed=0.1,
					pattern="stop_and_go",
					canfly = false,
					},
		catching = {
					tool="animalmaterials:lasso",
					consumed=true,
					},
		random_drop = {
 					result="animalmaterials:egg",
 					min_delay=60,
 					chance=0.2
 					},
		spawning = {
					primary_algorithms = {
						{
						rate=0.001,
						density=75,
						algorithm="willow_mapgen",
						height=1
						},
					}
				},
		sound = {
					random_drop = {
						name="animal_chicken_eggdrop",
						gain = 0.05,
						max_hear_distance = 5,
						},
					random = {
						name= {
							"animal_chicken_random_chicken_1",
							"animal_chicken_random_chicken_2",
							"animal_chicken_random_chicken_3",
							"animal_chicken_random_chicken_4",
							"animal_chicken_random_chicken_5",
							},
						min_delta = 60,
						chance = 0.5,
						gain = 1,
						max_hear_distance = 5,
					},
			},
		animation = {
				walk = {
					start_frame = 41,
					end_frame   = 81,
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
					mesh = "animal_chicken.b3d",
					textures = {"animal_chicken_chicken_mesh.png"},
					collisionbox = selectionbox_chicken,
					visual_size= {x=1,y=1,z=1},
					},
				graphics = {
					sprite_scale={x=1,y=1},
					sprite_div = {x=6,y=1},
					visible_height = 1,
					visible_width = 1,
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
		
rooster_prototype = {   
		name="rooster",
		modname="animal_chicken",
		
		factions = {
			member = {
				"animals",
				"grassland_animals"
				}
			},

		generic = {
					description="Rooster",
					base_health=5,
					kill_result=chicken_drop,
					armor_groups= {
						fleshy=90,
					},
					groups = chicken_groups,
					envid = "meadow"
				},
		movement =  {
					min_accel=0.05,
					max_accel=0.1,
					max_speed=0.3,
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
							density=75,
							algorithm="willow_mapgen",
							height=1
						}
					},
				secondary_algorithms = {
						{
						rate=0.001,
						density=75,
						algorithm="willow",
						height=2
						},
					}
				},
		sound = {
					random = {
						name="animal_chicken_random_rooster",
						min_delta = 1200,
						chance = 0.5,
						gain = 1,
						max_hear_distance = 5,
					},
			},
		animation = {
				walk = {
					start_frame = 41,
					end_frame   = 81,
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
					mesh = "animal_rooster.b3d",
					textures = {"animal_chicken_chicken_mesh.png"},
					collisionbox = selectionbox_rooster,
					visual_size= {x=1,y=1,z=1},
					},
				graphics = {
					sprite_scale={x=1,y=1},
					sprite_div = {x=6,y=1},
					visible_height = 1,
					visible_width = 1,
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
			},
		}

chick_m_prototype = {
		name="chick_m",
		modname="animal_chicken",
		
		factions = {
			member = {
				"animals",
				"grassland_animals"
				}
			},
		
		generic = {
				description="Chick - male",
				base_health=5,
				kill_result="animalmaterials:feather 1",
				armor_groups= {
					fleshy=90,
				},
				groups = chicken_groups,
				envid = "meadow"
				},
		movement =  {
				min_accel=0.02,
				max_accel=0.05,
				max_speed=0.2,
				min_speed=0.05,
				pattern="stop_and_go",
				canfly = false,
				},
		catching = {
				tool="animalmaterials:lasso",
				consumed=true,
				},
		auto_transform = {
				result="animal_chicken:rooster__default",
				delay=600,
				},
		spawning = {
					primary_algorithms = {
						{
						rate=0.001,
						density=75,
						algorithm="none",
						height=1
						},
					}
				},
		animation = {
				walk = {
					start_frame = 1,
					end_frame   = 40,
					},
				stand = {
					start_frame = 41,
					end_frame   = 81,
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
					mesh = "animal_chick.b3d",
					textures = {"animal_chicken_chick_mesh.png"},
					collisionbox = selectionbox_chick,
					visual_size= {x=1,y=1,z=1},
					},
				graphics = {
					sprite_scale={x=1,y=1},
					sprite_div = {x=6,y=1},
					visible_height = 1,
					visible_width = 1,
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

chick_f_prototype = {   
		name="chick_f",
		modname="animal_chicken",
		
		factions = {
			member = {
				"animals",
				"grassland_animals"
				}
			},
		
		generic = {
				description="Chick - female",
				base_health=5,
				kill_result="animalmaterials:feather 1",
				armor_groups= {
					fleshy=90,
				},
				groups = chicken_groups,
				envid = "meadow"
				},
		movement =  {
				min_accel=0.02,
				max_accel=0.05,
				max_speed=0.2,
				min_speed=0.05,
				pattern="stop_and_go",
				canfly = false,
				},
		catching = {
				tool="animalmaterials:lasso",
				consumed=true,
				},
		auto_transform = {
				result="animal_chicken:chicken__default",
				delay=600,
				},
		spawning = {
					primary_algorithms = {
						{
						rate=0.001,
						density=75,
						algorithm="none",
						height=1
						},
					}
				},
		animation = {
				walk = {
					start_frame = 1,
					end_frame   = 40,
					},
				stand = {
					start_frame = 41,
					end_frame   = 81,
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
					mesh = "animal_chick.b3d",
					textures = {"animal_chicken_chick_mesh.png"},
					collisionbox = selectionbox_chick,
					visual_size= {x=1,y=1,z=1},
					},
				graphics = {
					sprite_scale={x=1,y=1},
					sprite_div = {x=6,y=1},
					visible_height = 1,
					visible_width = 1,
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


--register with animals mod
minetest.log("action","\tadding animal "..chicken_prototype.name)
mobf_add_mob(chicken_prototype)
minetest.log("action","\tadding animal "..chick_m_prototype.name)
mobf_add_mob(chick_m_prototype)
minetest.log("action","\tadding animal "..chick_f_prototype.name)
mobf_add_mob(chick_f_prototype)
minetest.log("action","\tadding animal "..rooster_prototype.name)
mobf_add_mob(rooster_prototype)
minetest.log("action","MOD: animal_chicken mod         version " .. version .. " loaded")