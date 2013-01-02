local version = "0.0.2"

local modpath = minetest.get_modpath("mob_npc")

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
					envid="on_ground_1",
					custom_on_activate_handler=mob_inventory.init_trader_inventory,
				},
		movement =  {
					default_gen="none",
					min_accel=0.3,
					max_accel=0.7,
					max_speed=1.5,
					min_speed=0.01,
					pattern="stop_and_go",
					canfly=false,
					},
		harvest        = nil,
		catching       = nil,
		random_drop    = nil,
		auto_transform = nil,
		graphics_3d = {
					visual = "mesh",
					mesh = "character.x",
					textures = {"zombie.png"},
					collisionbox = {-0.3,-1.0,-0.3, 0.3,0.8,0.3},
					visual_size= {x=1, y=1},
					},
		combat = nil,
		
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
							{ "default:sword_steel 1", "default:cobble 50", "default:stone 20"},
						},
				random_names = { "Hans","Franz","Xaver","Fritz","Thomas","Martin"},
			}
		}
		
--register with animals mod
print ("Adding animal "..npc_prototype.name)
mobf_add_mob(npc_prototype)
print ("mob_npc mod version " .. version .. " loaded")