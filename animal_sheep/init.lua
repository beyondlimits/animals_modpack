-------------------------------------------------------------------------------
-- Mob Framework Mod by Sapier
-- 
-- You may copy, use, modify or do nearly anything except removing this
-- copyright notice. 
-- And of course you are NOT allow to pretend you have written it.
--
--! @file init.lua
--! @brief sheep implementation
--! @copyright Sapier
--! @author Sapier
--! @date 2013-01-27
--
-- Contact sapier a t gmx net
-------------------------------------------------------------------------------
minetest.log("action","MOD: animal_sheep mod loading ...")

local version = "0.0.22"

local sheep_groups = {
						sheerable=1,
						wool=1,
						not_in_creative_inventory=1
					}

local selectionbox_sheep = {-0.65, -0.8, -0.65, 0.65, 0.45, 0.65}
local selectionbox_lamb = {-0.65*0.6, -0.8*0.6, -0.65*0.6, 0.65*0.6, 0.45*0.6, 0.65*0.65}

sheep_prototype = {
		name="sheep",
		modname="animal_sheep",
	
		generic = {
					description="Sheep",
					base_health=10,
					kill_result="animalmaterials:meat_lamb 2",
					armor_groups= {
						fleshy=3,
					},
					groups = sheep_groups,
					envid="meadow",
				},
		movement =  {
					min_accel=0.05,
					max_accel=0.1,
					max_speed=0.5,
					min_speed=0.1,
					pattern="stop_and_go",
					canfly=false,
					},
		harvest = {	
					tool="animalmaterials:scissors",
					max_tool_usage=10,
					tool_consumed=false,
					result="wool:white 1", 
					transforms_to="animal_sheep:sheep_naked__default",
					min_delay=-1,
					},
		catching = {
					tool="animalmaterials:lasso",
					consumed=true,
					},
		spawning = {
					rate=0.002,
					density=50,
					algorithm="willow_mapgen",
					algorithm_secondary="willow",
					height=2
					},
		sound = {
					random = {
								name="Mudchute_sheep_1",
								min_delta = 30,
								chance = 0.5,
								gain = 0.5,
								max_hear_distance = 10,
								},
					harvest = {
								name="animal_sheep_harvest",
								gain = 0.8,
								max_hear_distance = 5
								},
					},
		animation = {
				walk = {
					start_frame = 0,
					end_frame   = 60,
					},
				stand = {
					start_frame = 61,
					end_frame   = 120,
					},
				eating = {
					start_frame = 121,
					end_frame   = 180,
					},
				sleep = {
					start_frame = 181,
					end_frame   = 240,
					},
			},
		states = {
				{
					name = "default",
					movgen = "none",
					typical_state_time = 30,
					chance = 0,
					animation = "stand",
					graphics = { 
						sprite_scale={x=4,y=4},
						sprite_div = {x=6,y=1},
						visible_height = 1.5,
						},
					graphics_3d = {
						visual = "mesh",
						mesh = "animal_sheep_sheep.b3d",
						textures = {"animal_sheep_mesh.png"},
						collisionbox = selectionbox_sheep,
						visual_size= {x=1,y=1,z=1},
						},
				},
				{ 
					name = "sleeping",
					--TODO replace by check for night
					custom_preconhandler = nil,
					movgen = "none",
					typical_state_time = 300,
					chance = 0.10,
					animation = "sleep",
				},
				{ 
					name = "eating",
					custom_preconhandler = nil,
					movgen = "none",
					typical_state_time = 20,
					chance = 0.25,
					animation = "eating"
				},
				{ 
					name = "walking",
					custom_preconhandler = nil,
					movgen = "probab_mov_gen",
					typical_state_time = 180,
					chance = 0.50,
					animation = "walk"
				},
			}
		}
		
lamb_prototype = {
		name="lamb",
		modname="animal_sheep",
	
		generic = {
					description="Lamp",
					base_health=3,
					kill_result="animalmaterials:meat_lamb 1",
					armor_groups= {
						fleshy=3,
					},
					envid="meadow",
				},
		movement =  {
					canfly=false,
					min_accel=0.025,
					max_accel=0.05,
					max_speed=0.3,
					min_speed=0.05,
					pattern="stop_and_go"
					},
		harvest     = nil,
		catching = {
					tool="animalmaterials:lasso",
					consumed=true,
					},
		auto_transform = {
					result="animal_sheep:sheep__default",
					delay=1800
					},
		spawning = {
					rate=0,
					density=0,
					algorithm="none",
					height=1
					},
		sound = {
					random = {
								name="Mudchute_lamb_1",
								min_delta = 30,
								chance = 0.5,
								gain = 0.4,
								max_hear_distance = 10,
								},
					},
		animation = {
				walk = {
					start_frame = 0,
					end_frame   = 60,
					},
				stand = {
					start_frame = 61,
					end_frame   = 120,
					},
				eating = {
					start_frame = 121,
					end_frame   = 180,
					},
				sleep = {
					start_frame = 181,
					end_frame   = 240,
					},
			},
		states = {
				{
					name = "default",
					movgen = "none",
					typical_state_time = 30,
					chance = 0,
					animation = "stand",
					graphics = { 
						sprite_scale={x=4,y=4},
						sprite_div = {x=6,y=1},
						visible_height = 1.5,
						},
					graphics_3d = {
						visual = "mesh",
						mesh = "animal_sheep_sheep.b3d",
						textures = {"animal_sheep_mesh.png"},
						collisionbox = selectionbox_sheep,
						visual_size= {x=0.5,y=0.5,z=0.5},
						},
				},
				{ 
					name = "sleeping",
					--TODO replace by check for night
					custom_preconhandler = nil,
					movgen = "none",
					typical_state_time = 300,
					chance = 0.10,
					animation = "sleep",
				},
				{ 
					name = "eating",
					custom_preconhandler = nil,
					movgen = "none",
					typical_state_time = 20,
					chance = 0.25,
					animation = "eating"
				},
				{ 
					name = "walking",
					custom_preconhandler = nil,
					movgen = "probab_mov_gen",
					typical_state_time = 180,
					chance = 0.50,
					animation = "walk"
				},
			}
		}
	
sheep_naked_prototype = {
		name="sheep_naked",
		modname="animal_sheep", 
	
		generic = {
					description="Naked sheep",
					base_health=10,
					kill_result="animalmaterials:meat_lamb 2",
					armor_groups= {
						fleshy=3,
					},
					envid="meadow"
				},
		movement =  {
					canfly=false,
                    min_accel=0.05,
                    max_accel=0.1,
                    max_speed=0.5,
                    min_speed=0.1,
					pattern="stop_and_go"
					},		
		catching = {
					tool="animalmaterials:lasso",
					consumed=true,
					},
		auto_transform = {
					result="animal_sheep:sheep__default",
					delay=300
					},
		spawning = {
					rate=0,
					density=0,
					algorithm="none",
					height=2
					},
		sound = {
					random = {
								name="Mudchute_sheep_1",
								min_delta = 30,
								chance = 0.5,
								gain = 0.5,
								max_hear_distance = 10,
								},
					},
		animation = {
				walk = {
					start_frame = 0,
					end_frame   = 60,
					},
				stand = {
					start_frame = 61,
					end_frame   = 120,
					},
				eating = {
					start_frame = 121,
					end_frame   = 180,
					},
				sleep = {
					start_frame = 181,
					end_frame   = 240,
					},
			},
		states = {
				{
					name = "default",
					movgen = "none",
					typical_state_time = 30,
					chance = 0,
					animation = "stand",
					graphics = { 
						sprite_scale={x=4,y=4},
						sprite_div = {x=6,y=1},
						visible_height = 1.5,
						},
					graphics_3d = {
						visual = "mesh",
						mesh = "animal_sheep_sheep.b3d",
						textures = {"animal_sheep_naked_mesh.png"},
						collisionbox = selectionbox_sheep,
						visual_size= {x=1,y=1,z=1},
						},
				},
				{ 
					name = "sleeping",
					--TODO replace by check for night
					custom_preconhandler = nil,
					movgen = "none",
					typical_state_time = 300,
					chance = 0.10,
					animation = "sleep",
				},
				{ 
					name = "eating",
					custom_preconhandler = nil,
					movgen = "none",
					typical_state_time = 20,
					chance = 0.25,
					animation = "eating"
				},
				{ 
					name = "walking",
					custom_preconhandler = nil,
					movgen = "probab_mov_gen",
					typical_state_time = 180,
					chance = 0.50,
					animation = "walk"
				},
			}
		}	


minetest.register_craft({
	output = "animalmaterials:scissors 5",
	recipe = {
		{'', "default:steel_ingot",''},
		{'', "default:steel_ingot",''},
		{"default:stick",'',"default:stick"},
	}
})

minetest.log("action","\tadding animal "..sheep_prototype.name)
mobf_add_mob(sheep_prototype)
minetest.log("action","\tadding animal "..sheep_naked_prototype.name)
mobf_add_mob(sheep_naked_prototype)
minetest.log("action","\tadding animal "..lamb_prototype.name)
mobf_add_mob(lamb_prototype)

minetest.log("action","MOD: animal_sheep mod           version " .. version .. " loaded")
