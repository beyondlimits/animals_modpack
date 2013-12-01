local version = "0.0.1"

minetest.log("action","MOD: mob_shark loading ...")

local selectionbox_shark = {-0.75, -0.5, -0.75, 0.75, 0.5, 0.75}

local shark_groups = {
                        not_in_creative_inventory=1
                    }

function shark_drop()
	local result = {}

	if math.random() < 0.01 then
		table.insert(result,"animalmaterials:shark_tooth 3")
	end

	if math.random() < 0.01 then
		table.insert(result,"animalmaterials:shark_skin 1")
	end

	table.insert(result,"animalmaterials:fish_shark 3")

	return result
end

shark_prototype = {
		name="shark",
		modname="mob_shark",

		factions = {
			member = {
				"animals",
				"fish",
				"sharks"
				}
			},

		generic = {
					description="Shark",
					base_health=5,
					kill_result=shark_drop,
					armor_groups= {
						fleshy=20,
					},
					groups = shark_groups,
					envid="deep_water",
				},
		movement =  {
					default_gen="probab_mov_gen",
					min_accel=0.1,
					max_accel=0.3,
					max_speed=0.8,
					pattern="swim_pattern1",
					canfly=true,
					follow_speedup= { x=20,y=1.5,z=20 },
				},
		combat = {
					angryness=1,
					starts_attack=true,
					sun_sensitive=false,
					melee = {
						maxdamage=5,
						range=2,
						speed=1,
						},
					distance 		= nil,
					self_destruct 	= nil,
					},
		spawning = {
					primary_algorithms = {
						{
							rate=0.02,
							density=450,
							algorithm="deep_water_spawner",
							height=-1,
							respawndelay = 60,
						},
					}
				},
		animation = {
				swim = {
					start_frame = 80,
					end_frame   = 160,
					},
				stand = {
					start_frame = 1,
					end_frame   = 80,
					},
				},
		states = {
				{
					name = "default",
					movgen = "none",
					chance = 0,
					animation = "stand",
					graphics_3d = {
						visual = "mesh",
						mesh = "mob_shark.b3d",
						textures = {"mob_shark_shark_mesh.png"},
						collisionbox = selectionbox_shark,
						visual_size= {x=1,y=1,z=1},
						},
					graphics = {
						sprite_scale={x=2,y=1},
						sprite_div = {x=1,y=1},
						visible_height = 1,
						visible_width = 1,
						},
					typical_state_time = 30,
				},
				{
					name = "swiming",
					movgen = "probab_mov_gen",
					chance = 0.9,
					animation = "swim",
					typical_state_time = 180,
				},
				{
					name = "combat",
					typical_state_time = 9999,
					chance = 0.0,
					animation = "swim",
					movgen = "follow_mov_gen"
				},
				},
		}


--register with animals mod
minetest.log("action","\tadding mob "..shark_prototype.name)
mobf_add_mob(shark_prototype)
minetest.log("action","MOD: mob_shark mod version " .. version .. " loaded")