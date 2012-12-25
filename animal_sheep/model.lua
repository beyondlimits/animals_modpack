local textures_wool = {"animals_sheep_wool.png", 
				   "animals_sheep_wool.png",
				   "animals_sheep_front.png",
				   "animals_sheep_wool.png",
				   "animals_sheep_wool.png",
				   "animals_sheep_wool.png"}
				   
local textures_wool_sleeping = {"animals_sheep_wool.png", 
				   "animals_sheep_wool.png",
				   "animals_sheep_sleeping_front.png",
				   "animals_sheep_wool.png",
				   "animals_sheep_wool.png",
				   "animals_sheep_wool.png"}
				   
local textures_wool_eating = {"animals_sheep_wool.png", 
				   "animals_sheep_wool.png",
				   "animals_sheep_eating_front.png",
				   "animals_sheep_wool.png",
				   "animals_sheep_wool.png",
				   "animals_sheep_wool.png"}
				   
local textures_naked = {"animals_sheep_no_wool.png", 
				   "animals_sheep_no_wool.png",
				   "animals_sheep_no_wool_front.png",
				   "animals_sheep_no_wool.png",
				   "animals_sheep_no_wool.png",
				   "animals_sheep_no_wool.png"}
				   
local textures_naked_eating = {"animals_sheep_no_wool.png", 
				   "animals_sheep_no_wool.png",
				   "animals_sheep_no_wool_eating_front.png",
				   "animals_sheep_no_wool.png",
				   "animals_sheep_no_wool.png",
				   "animals_sheep_no_wool.png"}
				   
local textures_naked_sleeping = {"animals_sheep_no_wool.png", 
				   "animals_sheep_no_wool.png",
				   "animals_sheep_no_wool_sleeping_front.png",
				   "animals_sheep_no_wool.png",
				   "animals_sheep_no_wool.png",
				   "animals_sheep_no_wool.png"}
				   
function x(value)
     return (value - (100/2)) / 100
end

function z(value)
     return (value - (100/2)) / 100
end

function y(value)
     return (value + (100/2)) / 100
end

local nodebox_sheep = {
	--body
	{ x(20.000),y(-30.000),z(70.000),
		x(80.000),y(-70.000),z(30.000) },
	--leg_vr
	{ x(70.000),y(-70.000),z(40.000),
		x(80.000),y(-100.000),z(30.000) },
	--leg_vl
	{ x(70.000),y(-70.000),z(70.000),
		x(80.000),y(-100.000),z(60.000) },
	--leg_hl
	{ x(20.000),y(-70.000),z(70.000),
		x(30.000),y(-100.000),z(60.000) },
	--leg_hr
	{ x(20.000),y(-70.000),z(40.000),
		x(30.000),y(-100.000),z(30.000) },
	--head
	{ x(75.000),y(-10.000),z(60.000),
		x(100.000),y(-35.000),z(40.000) },
	--tail
	{ x(15.000),y(-35.000),z(55.000),
		x(20.000),y(-60.000),z(45.000) },
}

local nodebox_sheep_eating = {
	--body
	{ x(20.000),y(-30.000),z(70.000),
		x(80.000),y(-70.000),z(30.000) },
	--leg_vr
	{ x(70.000),y(-70.000),z(40.000),
		x(80.000),y(-100.000),z(30.000) },
	--leg_vl
	{ x(70.000),y(-70.000),z(70.000),
		x(80.000),y(-100.000),z(60.000) },
	--leg_hl
	{ x(20.000),y(-70.000),z(70.000),
		x(30.000),y(-100.000),z(60.000) },
	--leg_hr
	{ x(20.000),y(-70.000),z(40.000),
		x(30.000),y(-100.000),z(30.000) },
	--head
	{ x(85.000),y(-65.000),z(60.000),
		x(105.000),y(-90.000),z(40.000) },
	--tail
	{ x(15.000),y(-35.000),z(55.000),
		x(20.000),y(-60.000),z(45.000) },
	--neck
	{ x(80.000),y(-50.000),z(60.000),
		x(92.000),y(-75.000),z(40.000) },
}

local nodebox_sheep_sleeping = {
	--body
	{ x(20.000),y(-60.000),z(70.000),
		x(80.000),y(-100.000),z(30.000) },
	--leg_hl
	{ x(20.000),y(-90.000),z(72.000),
		x(50.000),y(-100.000),z(62.000) },
	--leg_hr
	{ x(20.000),y(-90.000),z(38.000),
		x(50.000),y(-100.000),z(28.000) },
	--head
	{ x(75.000),y(-40.000),z(60.000),
		x(100.000),y(-65.000),z(40.000) },
	--tail
	{ x(15.000),y(-65.000),z(55.000),
		x(20.000),y(-90.000),z(45.000) },
	--leg_vl
	{ x(70.000),y(-90.000),z(72.000),
		x(90.000),y(-100.000),z(62.000) },
	--leg_vr
	{ x(70.000),y(-90.000),z(38.000),
		x(90.000),y(-100.000),z(28.000) },
}

minetest.register_node("animal_sheep:box_wool", {
	tiles = textures_wool,
	drawtype = "nodebox",
	node_box = {
		type = "fixed",
		fixed = nodebox_sheep
		},
		groups = sheep_groups
		})
		
minetest.register_node("animal_sheep:box_naked", {
	tiles = textures_naked,
	drawtype = "nodebox",
	node_box = {
		type = "fixed",
		fixed = nodebox_sheep
		},
		groups = sheep_groups
		})
		
minetest.register_node("animal_sheep:box_wool_eating", {
	tiles = textures_wool_eating,
	drawtype = "nodebox",
	node_box = {
		type = "fixed",
		fixed = nodebox_sheep_eating
		},
		groups = sheep_groups
		})
		
minetest.register_node("animal_sheep:box_naked_eating", {
	tiles = textures_naked_eating,
	drawtype = "nodebox",
	node_box = {
		type = "fixed",
		fixed = nodebox_sheep_eating
		},
		groups = sheep_groups
		})
		
minetest.register_node("animal_sheep:box_wool_sleeping", {
	tiles = textures_wool_sleeping,
	drawtype = "nodebox",
	node_box = {
		type = "fixed",
		fixed = nodebox_sheep_sleeping
		},
		groups = sheep_groups
		})
		
minetest.register_node("animal_sheep:box_naked_sleeping", {
	tiles = textures_naked_sleeping,
	drawtype = "nodebox",
	node_box = {
		type = "fixed",
		fixed = nodebox_sheep_sleeping
		},
		groups = sheep_groups
		})