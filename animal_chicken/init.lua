local version = "0.0.10"

local chicken_groups = {
						not_in_creative_inventory=1
					}

local selectionbox_chicken = {-0.2, -0.25, -0.4, 0.2, 0.25, 0.4}
local selectionbox_chick = {-0.1, -0.125, -0.2, 0.1, 0.125, 0.2}

local modpath = minetest.get_modpath("animal_chicken")

dofile (modpath .. "/model.lua")

function chicken_drop()
	local result = {}
	if math.random() < 0.05 then
		table.insert(result,"animalmaterials:feather 2")
	else
		table.insert(result,"animalmaterials:feather 1")
	end
	
	table.insert(result,"animalmaterials:meat_chicken 1")
	
	return result
end

chicken_prototype = {   
		name="chicken",
		modname="animal_chicken",
	
		generic = {
					description="Chicken",
					base_health=5,
					kill_result=chicken_drop,
					armor_groups= {
						fleshy=3,
					},
					envid = "meadow"
				},
		movement =  {
					default_gen="probab_mov_gen",
                    min_accel=0.05,
                    max_accel=0.1,
                    max_speed=0.3,
                    min_speed=0.1,
					pattern="stop_and_go",
					canfly = false,
					},		
		harvest        = nil,
		catching = {
					tool="animalmaterials:lasso",
					consumed=true,
					},
		random_drop = {
 					result="animalmaterials:egg",
 					min_delay=60,
 					chance=0.2
 					},		
		auto_transform = nil,
		graphics = {
					sprite_scale={x=1,y=1},
					sprite_div = {x=6,y=1},
					visible_height = 1,
					visible_width = 1,
					},
		graphics_3d = {
			visual = "wielditem",
			textures = {"animal_chicken:box_chicken"},
			collisionbox = selectionbox_chicken,
			visual_size= {x=0.6,y=0.6,z=0.6},
			},
		combat         = nil,
		spawning = {
					rate=0.001,
					density=50,
					algorithm="willow_mapgen",
					height=1
					},
		}
		
rooster_prototype = {   
        name="rooster",
        modname="animal_chicken",
    
        generic = {
                    description="Rooster",
                    base_health=5,
                    kill_result=chicken_drop,
                    armor_groups= {
                        fleshy=3,
                    },
                    envid = "meadow"
                },
        movement =  {
                    default_gen="probab_mov_gen",
                    min_accel=0.05,
                    max_accel=0.1,
                    max_speed=0.3,
                    min_speed=0.1,
                    pattern="stop_and_go",
                    canfly = false,
                    },      
        harvest        = nil,
        catching = {
                    tool="animalmaterials:lasso",
                    consumed=true,
                    },
        random_drop = nil,
        auto_transform = nil,
        graphics = {
                    sprite_scale={x=1,y=1},
                    sprite_div = {x=6,y=1},
                    visible_height = 1,
                    visible_width = 1,
                    },
        graphics_3d = {
            visual = "wielditem",
            textures = {"animal_chicken:box_rooster"},
            collisionbox = selectionbox_chicken,
            visual_size= {x=0.6,y=0.6,z=0.6},
            },
        combat         = nil,
        spawning = {
                    rate=0.001,
                    density=50,
                    algorithm="willow_mapgen",
                    height=1
                    },
        }
        
chick_m_prototype = {   
        name="chick_m",
        modname="animal_chicken",
    
        generic = {
                    description="Chick - male",
                    base_health=5,
                    kill_result="animalmaterials:feather 1",
                    armor_groups= {
                        fleshy=3,
                    },
                    envid = "meadow"
                },
        movement =  {
                    default_gen="probab_mov_gen",
                    min_accel=0.02,
                    max_accel=0.05,
                    max_speed=0.2,
                    min_speed=0.05,
                    pattern="stop_and_go",
                    canfly = false,
                    },      
        harvest        = nil,
        catching = {
                    tool="animalmaterials:lasso",
                    consumed=true,
                    },
        random_drop = nil,
        auto_transform = {
                    result="animal_chicken:rooster",
                    delay=600,
                    },
        graphics = {
                    sprite_scale={x=1,y=1},
                    sprite_div = {x=6,y=1},
                    visible_height = 1,
                    visible_width = 1,
                    },
        graphics_3d = {
            visual = "wielditem",
            textures = {"animal_chicken:box_chick"},
            collisionbox = selectionbox_chick,
            visual_size= {x=0.6,y=0.6,z=0.6},
            },
        combat         = nil,
        spawning = {
                    rate=0.001,
                    density=50,
                    algorithm="none",
                    height=1
                    },
        }
        
chick_f_prototype = {   
        name="chick_f",
        modname="animal_chicken",
    
        generic = {
                    description="Chick - female",
                    base_health=5,
                    kill_result="animalmaterials:feather 1",
                    armor_groups= {
                        fleshy=3,
                    },
                    envid = "meadow"
                },
        movement =  {
                    default_gen="probab_mov_gen",
                    min_accel=0.02,
                    max_accel=0.05,
                    max_speed=0.2,
                    min_speed=0.05,
                    pattern="stop_and_go",
                    canfly = false,
                    },      
        harvest        = nil,
        catching = {
                    tool="animalmaterials:lasso",
                    consumed=true,
                    },
        random_drop = nil,
        auto_transform = {
                    result="animal_chicken:rooster",
                    delay=600,
                    },
        graphics = {
                    sprite_scale={x=1,y=1},
                    sprite_div = {x=6,y=1},
                    visible_height = 1,
                    visible_width = 1,
                    },
        graphics_3d = {
            visual = "wielditem",
            textures = {"animal_chicken:box_chick"},
            collisionbox = selectionbox_chick,
            visual_size= {x=0.3,y=0.3,z=0.3},
            },
        combat         = nil,
        spawning = {
                    rate=0.001,
                    density=50,
                    algorithm="none",
                    height=1
                    },
        }


--register with animals mod
print ("Adding animal "..chicken_prototype.name)
animals_add_animal(chicken_prototype)
print ("Adding animal "..chick_m_prototype.name)
animals_add_animal(chick_m_prototype)
print ("Adding animal "..chick_f_prototype.name)
animals_add_animal(chick_f_prototype)
print ("Adding animal "..rooster_prototype.name)
animals_add_animal(rooster_prototype)
print ("animal_chicken mod version " .. version .. " loaded")