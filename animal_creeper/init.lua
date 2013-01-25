local version = "0.0.14"

local creeper_groups = {
                        not_in_creative_inventory=1
                    }
local selectionbox_creeper = {-1, -1, -1, 1, 1, 1}

local modpath = minetest.get_modpath("animal_creeper")

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
print ("Adding mob "..creeper_prototype.name)
mobf_add_mob(creeper_prototype)
print ("animal_creeper mod version " .. version .. " loaded")