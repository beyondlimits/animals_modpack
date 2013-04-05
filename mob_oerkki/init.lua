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
minetest.log("action","MOD: mob_oerkki mod loading ...")
local version = "0.0.2"

local oerkki_groups = {
						not_in_creative_inventory=1
						}

local selectionbox_oerkki = {-0.75, -1.25, -0.75, 0.75, 0.75, 0.75}

oerkki_prototype = {
		name="oerkki",
		modname="mob_oerkki",
		
		generic = {
					description="Oerkki",
					base_health=3,
					kill_result="animalmaterials:meat_toxic 1",
					armor_groups= {
						cracky=30,
						deamon=30,
					},
					groups = oerkki_groups,
					envid="on_ground_1",
				},
		movement = {
					default_gen="probab_mov_gen",
					min_accel=0.2,
					max_accel=0.6,
					max_speed=2.5,
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
					angryness=0.65,
					starts_attack=true,
					sun_sensitive=false,
					melee = {
						maxdamage=1.5,
						range=2,
						speed=2,
						},
					self_destruct = nil,
					},
		
		spawning = {
					rate=0.01,
					density=750,
					algorithm="shadows_spawner",
					height=4,
					respawndelay = 60,
					},
		sound = {
			},
		animation = {
				move = {
					start_frame = 1,
					end_frame   = 29,
					},
				combat = {
					start_frame = 30,
					end_frame   = 60,
					},
			},
		states = {
				{ 
				name = "default",
				movgen = "none",
				chance = 0,
				animation = "move",
				graphics_3d = {
					visual = "mesh",
					mesh = "mob_oerkki.b3d",
					textures = {"mob_oerkki_mesh.png"},
					collisionbox = selectionbox_oerkki,
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
				chance = 0.5,
				animation = "move",
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
minetest.log("action","\tadding mob "..oerkki_prototype.name)
mobf_add_mob(oerkki_prototype)
minetest.log("action","MOD: mob_oerkki mod         version " .. version .. " loaded")