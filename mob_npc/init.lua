local version = "0.0.7"

local npc_groups = {
						not_in_creative_inventory=1
					}

local modpath = minetest.get_modpath("mob_npc")

dofile (modpath .. "/spawn_building.lua")

npc_prototype = {
		name="npc",
		modname="mob_npc",
	
		generic = {
					description="NPC",
					base_health=40,
					kill_result="",
					armor_groups= {
						fleshy=3,
					},
					groups = npc_groups,
					envid="on_ground_1",
				},
		movement =  {
					min_accel=0.3,
					max_accel=0.7,
					max_speed=1.5,
					min_speed=0.01,
					pattern="stop_and_go",
					canfly=false,
					},
		
		spawning = {
					rate=0,
					density=0,
					algorithm="none",
					height=2
					},
		states = {
				{ 
				name = "walking",
				movgen = "probab_mov_gen",
				typical_state_time = 180,
				chance = 0.50,
				animation = "walk",
				},
				{ 
				name = "default",
				movgen = "none",
				typical_state_time = 180,
				chance = 0.00,
				animation = "stand",
				graphics_3d = {
					visual = "mesh",
					mesh = "npc_character.b3d",
					textures = {"zombie.png"},
					collisionbox = {-0.3,-1.0,-0.3, 0.3,0.8,0.3},
					visual_size= {x=1, y=1},
					},
				},
			},
		animation = {
				walk = {
					start_frame = 168,
					end_frame   = 187,
					},
				stand = {
					start_frame = 0,
					end_frame   = 79,
					},
			},
		}
		
npc_trader_prototype = {
		name="npc_trader",
		modname="mob_npc",
	
		generic = {
					description="Trader",
					base_health=200,
					kill_result="",
					armor_groups= {
						fleshy=3,
					},
					groups = npc_groups,
					envid="on_ground_1",
					custom_on_activate_handler=mob_inventory.init_trader_inventory,
				},
		movement =  {
					min_accel=0.3,
					max_accel=0.7,
					max_speed=1.5,
					min_speed=0.01,
					pattern="stop_and_go",
					canfly=false,
					},
		
		spawning = {
					rate=0,
					density=750,
					algorithm="building_spawner",
					height=2
					},
		states = {
				{ 
				name = "default",
				movgen = "none",
				chance = 0,
				animation = "stand",
				graphics = {
					visual = "upright_sprite",
					sprite_scale={x=1.5,y=2},
					sprite_div = {x=1,y=1},
					visible_height = 2,
					visible_width = 1,
					},
				graphics_3d = {
					visual = "mesh",
					mesh = "npc_character.b3d",
					textures = {"mob_npc_trader_mesh.png"},
					collisionbox = {-0.3,-1.0,-0.3, 0.3,0.8,0.3},
					visual_size= {x=1, y=1},
					},
				},
			},
		animation = {
				walk = {
					start_frame = 168,
					end_frame   = 187,
					},
				stand = {
					start_frame = 0,
					end_frame   = 79,
					},
			},
		trader_inventory = {
				goods = {
							{ "default:mese 1", "default:dirt 99", "default:cobble 50"},
							{ "default:steel_ingot 1", "default:dirt 50", "default:cobble 20"},
							{ "default:stone 1", "default:dirt 10", "default:cobble 5"},
							{ "default:furnace", "default:steel_ingot 2", nil},
							{ "default:sword_steel 1", "default:cobble 50", "default:stone 20"},
						},
				random_names = { "Hans","Franz","Xaver","Fritz","Thomas","Martin"},
			}
		}
		
--register with animals mod
print ("Adding mob "..npc_trader_prototype.name)
mobf_add_mob(npc_trader_prototype)
print ("Adding mob "..npc_prototype.name)
mobf_add_mob(npc_prototype)
print ("mob_npc mod version " .. version .. " loaded")