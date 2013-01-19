local version = "0.0.10"

local gull_groups = {
						not_in_creative_inventory=1
					}

local selectionbox_gull = {-1, -0.3, -1, 1, 0.3, 1}

gull_prototype = {   
		name="gull",
		modname="animal_gull",
	
		generic = {
					description="Gull",
					base_health=5,
					kill_result="",
					armor_groups= {
						fleshy=3,
					},
					groups = gull_groups,
					envid="flight_1",
				},				
		movement =  {
					min_accel=0.5,
					max_accel=1,
					max_speed=4,
					pattern="flight_pattern1",
					canfly=true,
					},
		
		spawning = {
					rate=0.02,
					density=250,
					algorithm="in_air1_spawner",
					height=-1,
					respawndelay=60
					},
		animation = {
				fly = {
					start_frame = 0,
					end_frame   = 95,
					},
				},
		states = {
				{
					name = "default",
					movgen = "probab_mov_gen",
					typical_state_time = 100,
					chance = 0,
					animation = "fly",
					graphics = {
						sprite_scale={x=2,y=2},
						sprite_div = {x=6,y=1},
						visible_height = 1,
						visible_width = 1,
					},
					graphics_3d = {
						visual = "mesh",
						mesh = "animal_gull.b3d",
						textures = {"animal_gull_mesh.png"},
						collisionbox = selectionbox_gull,
						visual_size= {x=1,y=1,z=1},
						},
				},
			}
		}


--register with animals mod
print ("Adding mob "..gull_prototype.name)
mobf_add_mob(gull_prototype)
print ("animal_gull mod version " .. version .. " loaded")