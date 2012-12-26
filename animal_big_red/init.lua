local version = "0.0.10"

local big_red_groups = {
                        not_in_creative_inventory=1
                    }

local selectionbox_big_red = {-0.75, -1.9, -0.75, 0.75, 1.9, 0.75}

local modpath = minetest.get_modpath("animal_big_red")

dofile (modpath .. "/model.lua")

big_red_prototype = {   
		name="big_red",
		modname="animal_big_red",
		
		generic = {
					description="Big Red",
					base_health=30,
					kill_result="animalmaterials:meat_toxic 3",
					armor_groups= {
						fleshy=1,
						cracky=1,
						deamon=1,
					},
					envid="on_ground_1",
				},
		movement =  {
					default_gen="probab_mov_gen",
					min_accel=0.2,
					max_accel=0.4,
					max_speed=2,
					pattern="stop_and_go",
					canfly=false,
					},
		harvest = {	
					tool="",
					tool_consumed=false,
					result="", 
					transforms_to="",
					min_delay=-1,
				  	},
		catching       = nil,
		random_drop    = nil,
		auto_transform = nil,
		graphics_3d = {
			visual = "wielditem",
			textures = {"animal_big_red:box_big_red"},
			collisionbox = selectionbox_big_red,
			visual_size= {x=1.5,y=2.5,z=1.5},
			},
		graphics = {
					sprite_scale={x=6,y=6},
					sprite_div = {x=1,y=1},
					visible_height = 3.2,
					visible_width = 1,
					},
		combat = {
					angryness=0,--0.95,
					starts_attack=true,
					sun_sensitive=true,
					melee = {
						maxdamage=4,
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
					algorithm="shadows",
					height=4
					},
		}


--register with animals mod
print ("Adding animal "..big_red_prototype.name)
animals_add_animal(big_red_prototype)
print ("animal_big_red mod version " .. version .. " loaded")