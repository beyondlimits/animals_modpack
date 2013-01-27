-------------------------------------------------------------------------------
-- Mob Framework Mod by Sapier
-- 
-- You may copy, use, modify or do nearly anything except removing this
-- copyright notice. 
-- And of course you are NOT allow to pretend you have written it.
--
--! @file init.lua
--! @brief clownfish implementation
--! @copyright Sapier
--! @author Sapier
--! @date 2013-01-27
--
-- Contact sapier a t gmx net
-------------------------------------------------------------------------------
minetest.log("action","MOD: animal_clownfish mod loading ...")

local version = "0.0.9"

local selectionbox_clownfish = {-0.5, -0.5, -0.5, 0.5, 0.5, 0.5}

local clownfish_groups = {
						not_in_creative_inventory=1
					}

function clownfish_drop()
	local result = {}
	table.insert(result,"animalmaterials:scale_golden 1")
	table.insert(result,"animalmaterials:fish_clownfish 1")
	
	return result
end

clownfish_prototype = {   
		name="clownfish",
		modname="animal_clownfish",
	
		generic = {
					description="Clownfish",
					base_health=5,
					kill_result=clownfish_drop,
					armor_groups= {
						fleshy=3,
					},
					groups = clownfish_groups,
					envid = "open_waters"
				},
		movement = {
					default_gen="probab_mov_gen",
					min_accel=0.2,
					max_accel=0.3,
					max_speed=1.5,
					pattern="swim_pattern2",
					canfly=true,
					},
		catching = {
					tool="animalmaterials:net",
					consumed=true,
					},
		spawning = {
					rate=0.02,
					density=350,
					algorithm="in_shallow_water_spawner",
					height=-1,
					respawndelay = 60,
					},
		animation = {
				swim = {
					start_frame = 81,
					end_frame   = 155,
					},
				stand = {
					start_frame = 1,
					end_frame   = 80,
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
						mesh = "animal_clownfish.b3d",
						textures = {"animal_clownfish_mesh.png"},
						collisionbox = selectionbox_clownfish,
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
					name = "swiming",
					movgen = "probab_mov_gen",
					chance = 0.9,
					animation = "swim",
					typical_state_time = 180,
				},
				},
		}


--register with animals mod
minetest.log("action","\tadding animal "..clownfish_prototype.name)
mobf_add_mob(clownfish_prototype)
minetest.log("action","MOD: animal_clownfish mod       version " .. version .. " loaded")