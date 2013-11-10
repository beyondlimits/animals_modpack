-------------------------------------------------------------------------------
-- Mob Framework Mod by Sapier
-- 
-- You may copy, use, modify or do nearly anything except removing this
-- copyright notice. 
-- And of course you are NOT allow to pretend you have written it.
--
--! @file init.lua
--! @brief deer implementation
--! @copyright Sapier
--! @author Sapier
--! @date 2013-01-27
--
-- Contact sapier a t gmx net
-------------------------------------------------------------------------------
minetest.log("action","MOD: animal_deer mod loading ... ")

local version = "0.1.2"

local deer_groups = {
						not_in_creative_inventory=1
					}

local selectionbox_deer = {-0.7, -1.25, -0.7, 0.7, 0.8, 0.7}

function deer_m_drop()
	local result = {}
	if math.random() < 0.25 then
		table.insert(result,"animalmaterials:meat_venison 3")
	else
		table.insert(result,"animalmaterials:meat_venison 2")
	end
	
	if math.random() < 0.25 then
		table.insert(result,"animalmaterials:deer_horns 1")
	end
	
	if math.random() < 0.25 then
		table.insert(result,"animalmaterials:fur_deer 1")
	end
	
	if math.random() < 0.1 then
		table.insert(result,"animalmaterials:bone 1")
	end
	
	return result
end

function deer_f_drop()
	local result = {}
	if math.random() < 0.05 then
		table.insert(result,"animalmaterials:meat_venison 3")
	else
		table.insert(result,"animalmaterials:meat_venison 2")
	end
	
	if math.random() < 0.25 then
		table.insert(result,"animalmaterials:fur_deer 1")
	end
	
	if math.random() < 0.1 then
		table.insert(result,"animalmaterials:bone 1")
	end
	
	return result
end

deer_m_prototype = {
	name="deer_m",
	modname = "animal_deer",
	
	factions = {
		member = {
			"animals",
			"forrest_animals"
			}
		},

	generic = {
				description="Deer (m)",
				base_health=25,
				kill_result=deer_m_drop,
				armor_groups= {
					fleshy=75,
				},
				groups = deer_groups,
				envid="meadow",
			},
	movement =  { 
				default_gen="probab_mov_gen",
				min_accel=0.2,
				max_accel=0.4,
				max_speed=2,
				min_speed=0.02,
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
				primary_algorithms = {
					{
					rate=0.002,
					density=200,
					algorithm="forrest_mapgen",
					height=2
					},
				},
				secondary_algorithms = {
					{
					rate=0.002,
					density=200,
					algorithm="forrest",
					height=2
					},
				}
			},
	animation = {
			walk = {
				start_frame = 0,
				end_frame   = 60,
				basevelocity = 0.225,
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
			{ 
			name = "flee",
			movgen = "flee_mov_gen",
			typical_state_time = 20,
			chance = 0,
			animation = "walk",
			},
		}
	}
		
deer_f_prototype = {
	name="deer_f",
	modname = "animal_deer",
	
	factions = {
		member = {
			"animals",
			"forrest_animals"
			}
		},

	generic = {
				description="Deer (f)",
				base_health=25,
				kill_result=deer_f_drop,
				armor_groups= {
					fleshy=75,
				},
				groups = deer_groups,
				envid="meadow",
			},
	movement =  { 
				default_gen="probab_mov_gen",
				min_accel=0.2,
				max_accel=0.4,
				max_speed=2,
				min_speed=0.02,
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
				primary_algorithms = {
					{
					rate=0.002,
					density=200,
					algorithm="forrest_mapgen",
					height=2
					},
				},
				secondary_algorithms = {
					{
					rate=0.002,
					density=200,
					algorithm="forrest",
					height=2
					},
				}
			},
	animation = {
			walk = {
				start_frame = 0,
				end_frame   = 60,
				basevelocity = 0.225,
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
					mesh = "animal_deer_f.b3d",
					textures = {"animal_deer_mesh_m.png"},
					collisionbox = selectionbox_deer,
					visual_size= {x=0.9,y=0.9,z=0.9},
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
			{ 
			name = "flee",
			movgen = "flee_mov_gen",
			typical_state_time = 20,
			chance = 0,
			animation = "walk",
			},
		}
	}
		
--compatibility code
minetest.register_entity(":animal_deer:deer__default",
	{
		on_activate = function(self,staticdata)
			minetest.add_entity(self.object:getpos(),"animal_deer:deer_m")
			self.object:remove()
		end
	})

--register with animals mod
minetest.log("action","\tadding mob "..deer_m_prototype.name)
mobf_add_mob(deer_m_prototype)
minetest.log("action","\tadding mob "..deer_f_prototype.name)
mobf_add_mob(deer_f_prototype)
minetest.log("action","MOD: animal_deer mod            version " .. version .. " loaded")