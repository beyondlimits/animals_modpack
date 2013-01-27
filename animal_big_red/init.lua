-------------------------------------------------------------------------------
-- Mob Framework Mod by Sapier
-- 
-- You may copy, use, modify or do nearly anything except removing this
-- copyright notice. 
-- And of course you are NOT allow to pretend you have written it.
--
--! @file init.lua
--! @brief big_red implementation
--! @copyright Sapier
--! @author Sapier
--! @date 2013-01-27
--
-- Contact sapier a t gmx net
-------------------------------------------------------------------------------
minetest.log("action","MOD: animal_big_red mod loading ...")
local version = "0.0.17"

local big_red_groups = {
						not_in_creative_inventory=1
						}

local selectionbox_big_red = {-0.75, -1.9, -0.75, 0.75, 1.9, 0.75}

big_red_prototype = {
		name="big_red",
		modname="animal_big_red",
		
		generic = {
					description="Big Red",
					base_health=8,
					kill_result="animalmaterials:meat_toxic 3",
					armor_groups= {
						fleshy=1,
						cracky=1,
						deamon=1,
					},
					groups = big_red_groups,
					envid="on_ground_1",
				},
		movement = {
					default_gen="probab_mov_gen",
					min_accel=0.2,
					max_accel=0.4,
					max_speed=2,
					pattern="stop_and_go",
					canfly=false,
					follow_speedup=30,
					},
		harvest = {	
					tool="",
					tool_consumed=false,
					result="", 
					transforms_to="",
					min_delay=-1,
					},
		combat = {
					angryness=0.95,
					starts_attack=true,
					sun_sensitive=true,
					melee = {
						maxdamage=2,
						range=2,
						speed=2,
						},
					distance = {
						attack="mobf:plasmaball_entity", 
						range=10,
						speed=2,
						},
					self_destruct = nil,
					},
		
		spawning = {
					rate=0.01,
					density=1000,
					algorithm="shadows_spawner",
					height=4,
					respawndelay = 60,
					},
		sound = {
			random = {
					name="animal_big_red_random_1",
					min_delta = 30,
					chance = 0.5,
					gain = 1,
					max_hear_distance = 5,
					},
			},
		animation = {
				walk = {
					start_frame = 91,
					end_frame   = 170,
					},
				stand = {
					start_frame = 11,
					end_frame   = 90,
					},
				combat = {
					start_frame = 171,
					end_frame   = 250,
					},
				throw_plasmaball = {
					start_frame = 1,
					end_frame = 10,
				}
			},
		states = {
				{ 
				name = "default",
				movgen = "none",
				chance = 0,
				animation = "stand",
				graphics_3d = {
					visual = "mesh",
					mesh = "animal_big_red.b3d",
					textures = {"animal_big_red_mesh.png"},
					collisionbox = selectionbox_big_red,
					visual_size= {x=1,y=1,z=1},
					},
				graphics = {
					sprite_scale={x=6,y=6},
					sprite_div = {x=1,y=1},
					visible_height = 3.2,
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
				{
				movgen="follow_mov_gen",
				name = "combat",
				chance = 0,
				animation = "combat",
				typical_state_time = 0,
				},
			},
		}


--register with animals mod
minetest.log("action","\tadding mob "..big_red_prototype.name)
mobf_add_mob(big_red_prototype)
minetest.log("action","MOD: animal_big_red mod         version " .. version .. " loaded")