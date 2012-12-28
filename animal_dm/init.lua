local version = "0.0.9"

local dm_groups = {
                        not_in_creative_inventory=1
                    }

local selectionbox_dm = {-0.75, -1, -0.75, 0.75, 1, 0.75}

local modpath = minetest.get_modpath("animal_dm")

dofile (modpath .. "/model.lua")

dm_prototype = {   
		name="dm",
		modname="animal_dm",
	
		generic = {
					description="Dungeonmaster (Animals)",
					base_health=50,
					kill_result="",
					armor_groups= {
						fleshy=1,
						deamon=1,
					},
					envid="simple_air"
				},				
		movement =  {
					default_gen="probab_mov_gen",
					min_accel=0.2,
					max_accel=0.4,
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
					visible_height = 2,
					},
       graphics_3d = {
            visual = "wielditem",
            textures = {"animal_dm:box_dm"},
            collisionbox = selectionbox_dm,
            visual_size= {x=1.5,y=1.5,z=1.5},
            },
		combat = {
					mgen="follow_mov_gen",
					angryness=0.99,
					starts_attack=true,
					sun_sensitive=true,
					melee = {
						maxdamage=8,
						range=5, 
						speed=1,
						},
					distance = {
						attack="mobf:fireball_entity",
						range =15,
						speed = 1,
						},				
					self_destruct = nil,
					},
		
		spawning = {		
					rate=0.02,
					density=750,
					algorithm="shadows",
					height=3
					},
		sound = {
					random = {
								name="animal_dm_random_1",
								min_delta = 30,
								chance = 0.5,
								gain = 0.5,
								max_hear_distance = 5,
								},
					distance = {
								name="animal_dm_fireball",
								gain = 0.5,
								max_hear_distance = 7,
								},
					die = {
								name="animal_dm_die",
								gain = 0.7,
								max_hear_distance = 7,
								},
					melee = {
								name="animal_dm_hit",
								gain = 0.7,
								max_hear_distance = 5,
								},
					},		
		}
		
dm_debug = function (msg)
    --minetest.log("action", "mobs: "..msg)
    --minetest.chat_send_all("mobs: "..msg)
end

local modpath = minetest.get_modpath("animal_dm")
dofile (modpath .. "/vault.lua")

--register with animals mod
print ("Adding animal "..dm_prototype.name)
if mobf_add_mob(dm_prototype) then
	dofile (modpath .. "/vault.lua")
end
print ("animal_dm mod version " .. version .. " loaded")