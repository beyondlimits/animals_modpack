local version = "0.0.9"

local selectionbox_fish_blue_white = {-0.5, -0.5, -0.5, 0.5, 0.5, 0.5}

local fish_blue_white_groups = {
                        not_in_creative_inventory=1
                    }

local modpath = minetest.get_modpath("animal_fish_blue_white")

--include debug trace functions
dofile (modpath .. "/model.lua")

function fish_blue_white_drop()
	local result = {}
	
	if math.random() < 0.01 then
		table.insert(result,"animalmaterials:scale_blue 1")
	end
	
	if math.random() < 0.01 then
		table.insert(result,"animalmaterials:scale_white 1")
	end
	
	table.insert(result,"animalmaterials:fish_bluewhite 3")
	
	return result
end

fish_blue_white_prototype = {   
		name="fish_blue_white",
		modname="animal_fish_blue_white",
	
		generic = {
					description="Blue white fish",
					base_health=5,
					kill_result=fish_blue_white_drop,
					armor_groups= {
						fleshy=3,
					},
					groups = fish_blue_white_groups,
					envid="shallow_waters",
				},				
		movement =  { 
					default_gen="probab_mov_gen",
					min_accel=0.1,
					max_accel=0.3,
					max_speed=0.8,
					pattern="swim_pattern1",
					canfly=true,
					},		
		harvest        = nil,
		catching = {
					tool="animalmaterials:net",
					consumed=true,
					},				  	
		random_drop    = nil,		
		auto_transform = nil,					
		graphics_3d = {
					visual = "wielditem",
					textures = {"animal_fish_blue_white:box_fish_blue_white"},
					collisionbox = selectionbox_fish_blue_white,
					visual_size= {x=0.666,y=0.666,z=0.666},
					},
		graphics = {
					sprite_scale={x=2,y=1},
					sprite_div = {x=1,y=1},
					visible_height = 1,
					visible_width = 1,
					},
		combat         = nil,
		
		spawning = {		
					rate=0.02,
					density=150,
					algorithm="in_shallow_water_spawner",
					height=-1,
					respawndelay = 60,
					},
		}


--register with animals mod
print ("Adding animal "..fish_blue_white_prototype.name)
animals_add_animal(fish_blue_white_prototype)
print ("animal_fish_blue_white mod version " .. version .. " loaded")