local version = "0.0.10"

local deer_groups = {
						not_in_creative_inventory=1
					}

local selectionbox_deer = {-0.7, -1.25, -0.7, 0.7, 0.8, 0.7}

deer_prototype = {
		name="deer_m",
		modname = "animal_deer", 

		generic = {
					description="Deer (m)",
					base_health=25,
					kill_result="animalmaterials:meat_venison 2",
					armor_groups= {
						fleshy=3,
					},
					groups = deer_groups,
					envid="meadow",
				},
		movement =  { 
					default_gen="probab_mov_gen",
					min_accel=0.2,
					max_accel=0.4,
					max_speed=2,
					pattern="stop_and_go",
					canfly=false,
					},		
		catching = {
					tool="animalmaterials:lasso",
					consumed=true,
					},
		random_drop    = nil,
		auto_transform = nil,
		spawning = {
					rate=0.002,
					density=200,
					algorithm="forrest_mapgen",
					height=2
					},
		animation = {
				walk = {
					start_frame = 0,
					end_frame   = 60,
					},
				stand = {
					start_frame = 61,
					end_frame   = 120,
					},
				eating = {
					start_frame = 121,
					end_frame   = 180,
					},
				sleep = {
					start_frame = 181,
					end_frame   = 240,
					},
			},
		states = {
				{
					name = "default",
					movgen = "none",
					typical_state_time = 30,
					chance = 0,
					animation = "stand",
					graphics = {
					sprite_scale={x=4,y=4},
						sprite_div = {x=6,y=1},
						visible_height = 2,
						visible_width = 1,
						},
					graphics_3d = {
						visual = "mesh",
						mesh = "animal_deer_m.b3d",
						textures = {"animal_deer_mesh_m.png"},
						collisionbox = selectionbox_deer,
						visual_size= {x=1,y=1,z=1},
						},
				},
				{ 
					name = "sleeping",
					--TODO replace by check for night
					custom_preconhandler = nil,
					movgen = "none",
					typical_state_time = 300,
					chance = 0.10,
					animation = "sleep",
				},
				{ 
					name = "eating",
					custom_preconhandler = nil,
					movgen = "none",
					typical_state_time = 20,
					chance = 0.25,
					animation = "eating"
				},
				{
					name = "walking",
					custom_preconhandler = nil,
					movgen = "probab_mov_gen",
					typical_state_time = 180,
					chance = 0.50,
					animation = "walk"
				},
			}
		}
		
--compatibility code
minetest.register_entity(":animal_deer:deer__default",
	{
		on_activate = function(self,staticdata)
			minetest.env:add_entity(self.object:getpos(),"animal_deer:deer_m__default")
			self.object:remove()
		end
	})


--register with animals mod
print ("Adding mob "..deer_prototype.name)
mobf_add_mob(deer_prototype)
print ("animal_deer mod version " .. version .. " loaded")