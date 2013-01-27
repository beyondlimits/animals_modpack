-------------------------------------------------------------------------------
-- Mob Framework Mod by Sapier
-- 
-- You may copy, use, modify or do nearly anything except removing this
-- copyright notice. 
-- And of course you are NOT allow to pretend you have written it.
--
--! @file init.lua
--! @brief boombomb implementation
--! @copyright Sapier
--! @author Sapier
--! @date 2013-01-27
--
-- Contact sapier a t gmx net
-------------------------------------------------------------------------------
minetest.log("action","MOD: animal_creeper mod loading ...")

local version = "0.0.15"

local creeper_groups = {
						not_in_creative_inventory=1
						}
						
local selectionbox_creeper = {-1, -1, -1, 1, 1, 1}

creeper_prototype = {
		name="creeper",
		modname="animal_creeper",
	
		generic = {
					description="BoomBomb",
					base_health=3,
					kill_result="",
					armor_groups= {
						cracky=3,
					},
					groups = creeper_groups,
					envid="on_ground_1",
				},				
		movement =  {
					min_accel=0.4,
					max_accel=0.6,
					max_speed=2,
					pattern="stop_and_go",
					canfly=false,
					follow_speedup=5,
					},
		combat = {
					angryness=0.95,
					starts_attack=true,
					sun_sensitive=true,
					melee = {
						maxdamage=0,
						range=2, 
						speed=1, 
						},
					distance 		= nil,
					self_destruct = {
						damage=15,
						range=5,
						node_damage_range = 1.5,
						delay=5,
						},
					},
		
		spawning = {
					rate=0.02,
					density=500,
					algorithm="at_night_spawner",
					height=2,
					respawndelay=60,
					},
		sound = {
					random = {
								name="animal_creeper_random_1",
								min_delta = 10,
								chance = 0.5,
								gain = 1,
								max_hear_distance = 75,
								},
					self_destruct = {
								name="animal_creeper_bomb_explosion",
								gain = 2,
								max_hear_distance = 150,
								},
					},
		states = {
				{
					name = "default",
					movgen = "probab_mov_gen",
					typical_state_time = 30,
					chance = 0,
					graphics = {
						sprite_scale={x=4,y=4},
						sprite_div = {x=6,y=1},
						visible_height = 1.5,
						},
					graphics_3d = {
						visual = "mesh",
						mesh = "boombomb.b3d",
						textures = {"boombomb_mesh.png"},
						collisionbox = selectionbox_creeper,
						visual_size= {x=1,y=1,z=1},
					},
				},
			}
		}

--register with animals mod
minetest.log("action","\tadding mob "..creeper_prototype.name)
mobf_add_mob(creeper_prototype)
minetest.log("action","MOD: animal_creeper mod         version " .. version .. " loaded")