function x(val) 
 return ((val -80) / 160)
end

function z(val) 
 return ((val -80) / 160)
end

function y(val)
	return ((val + 80) / 160)
end

local textures_clownfish = {
			"animal_clownfish_bottom.png",
			"animal_clownfish_top.png",
			"animal_clownfish_front.png",
			"animal_clownfish_back.png",
			"animal_clownfish_right.png",
			"animal_clownfish_left.png",
}

local nodebox_clownfish = {

	--head
	{ x(120), y(-70), z(85), x(130), y(-80), z(75)},
	{ x(110), y(-60), z(85), x(120), y(-90), z(75)},
	
	--body
	{ x(35), y(-50), z(90), x(110), y(-100), z(70)},

	--fins
	--right
	{ x(80), y(-97), z(70), x(100), y(-100),z(40)},
	{ x(87.5), y(-97), z(40), x(92.5), y(-100),z(35)},
	
	--left
    { x(80), y(-97), z(120), x(100), y(-100),z(90)},
    { x(87.5), y(-97), z(125), x(92.5), y(-100),z(120)},
	
	--backfin
	{ x(30), y(-55), z(85), x(35), y(-95),z(75)},
	{ x(25), y(-60), z(85), x(30), y(-90),z(75)},
	{ x(15), y(-55), z(82.5), x(25), y(-95),z(77.5)},
	{ x(10), y(-50), z(82.5), x(15), y(-100),z(77.5)},
	{ x(0), y(-50), z(82.5), x(10), y(-65),z(77.5)},
	{ x(0), y(-85), z(82.5), x(10), y(-100),z(77.5)},
}


minetest.register_node("animal_clownfish:box_clownfish", {
	tiles = textures_clownfish,
	drawtype = "nodebox",
	node_box = {
		type = "fixed",
		fixed = nodebox_clownfish
		},
		})