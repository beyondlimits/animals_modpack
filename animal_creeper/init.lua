local version = "0.0.7"

local creeper_groups = {
                        not_in_creative_inventory=1
                    }
local selectionbox_creeper = {-1, -1, -1, 1, 1, 1}

local modpath = minetest.get_modpath("animal_creeper")

--include debug trace functions
dofile (modpath .. "/model.lua")

creeper_prototype = {
		name="creeper",
		modname="animal_creeper", 
	
		generic = {
					description="BoomBomb",
					base_health=5,
					kill_result="",
					armor_groups= {
						cracky=3,
					},
					envid="on_ground_1",
				},				
		movement =  {
					default_gen="probab_mov_gen",
					min_accel=0.4,
					max_accel=0.6,
					max_speed=2,
					pattern="stop_and_go",
					canfly=false,
					},		
		harvest        = nil,
		catching       = nil,
		random_drop    = nil,
		auto_transform = nil,
		graphics = {
					sprite_scale={x=4,y=4},
					sprite_div = {x=6,y=1},
					visible_height = 1.5,
					},
		graphics_3d = {
			visual = "wielditem",
			textures = {"animal_creeper:box_creeper"},
			collisionbox = selectionbox_creeper,
			visual_size= {x=1.33,y=1.33,z=1.33},
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
					algorithm="at_night",
					height=2
					},
		sound = {
					random = {
								name="random_1",
								min_delta = 10,
								chance = 0.5,
								gain = 1,
								max_hear_distance = 75,
								},
					self_destruct = {
								name="bomb_explosion",
								gain = 2,
								max_hear_distance = 150,
								},
					},	
		}


--register with animals mod
print ("Adding animal "..creeper_prototype.name)
animals_add_animal(creeper_prototype)
print ("animal_creeper mod version " .. version .. " loaded")