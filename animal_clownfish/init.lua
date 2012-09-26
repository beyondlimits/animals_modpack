local version = "0.0.5"

local selectionbox_clownfish = {-0.5, -0.5, -0.5, 0.5, 0.5, 0.5}

local modpath = minetest.get_modpath("animal_clownfish")

--include debug trace functions
dofile (modpath .. "/model.lua")

clownfish_prototype = {   
		name="clownfish",
		modname="animal_clownfish",
	
		generic = {
					description="Clownfish",
					base_health=5,
					kill_result="animalmaterials:scale_golden",
					armor_groups= {
						fleshy=3,
					},
					envid = "open_waters"
				},				
		movement =  {
					default_gen="probab_mov_gen",
					min_accel=0.2,
					max_accel=0.3,
					max_speed=1.5,
					pattern="swim_pattern2",
					canfly=true,
					},		
		harvest        = nil,
		catching = {
					tool="animalmaterials:net",
					consumed=true,
					},				  	
		random_drop    = nil,		
		auto_transform = nil,					
		graphics = {
					sprite_scale={x=1,y=1},
					sprite_div = {x=6,y=1},
					visible_height = 1,
					visible_width = 1,
					},
      graphics_3d = {
            visual = "wielditem",
            textures = {"animal_clownfish:box_clownfish"},
            collisionbox = selectionbox_clownfish,
            visual_size= {x=0.666,y=0.666,z=0.666},
            },
		combat         = nil,
		
		spawning = {		
					rate=0.02,
					density=350,
					algorithm="in_shallow_water",
					height=-1
					},
		}


--register with animals mod
print ("Adding animal "..clownfish_prototype.name)
animals_add_animal(clownfish_prototype)
print ("animal_clownfish mod version " .. version .. " loaded")