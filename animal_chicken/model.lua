function x(val) 
 return ((val -80) / 160)
end

function z(val) 
 return ((val -80) / 160)
end

function y(val)
	return ((val + 80) / 160)
end

local textures_chicken = {
			"animal_chicken_chicken_bottom.png",
			"animal_chicken_chicken_top.png",
			"animal_chicken_chicken_front.png",
			"animal_chicken_chicken_back.png",
			"animal_chicken_chicken_left.png",
			"animal_chicken_chicken_right.png",
}

local textures_chick = {
            "animal_chicken_chick_top.png",
            "animal_chicken_chick_top.png",
            "animal_chicken_chick_front.png",
            "animal_chicken_chick_back.png",
            "animal_chicken_chick_left.png",
            "animal_chicken_chick_right.png",
}

local textures_rooster = {
            "animal_chicken_chicken_bottom.png",
            "animal_chicken_rooster_top.png",
            "animal_chicken_chicken_front.png",
            "animal_chicken_rooster_back.png",
            "animal_chicken_chicken_left.png",
            "animal_chicken_chicken_right.png",
}


local nodebox_chick = {
	--body_1
	{ x(65.000),y(-60.000),z(90.000),
		x(95.000),y(-75.000),z(70.000) },
	--body_2
	{ x(77.501),y(-45.000),z(85.000),
		x(97.499),y(-60.000),z(75.000) },
	--schnabel
	{ x(97.499),y(-52.501),z(82.499),
		x(102.499),y(-57.496),z(77.501) },
	--leg1
	{ x(78.000),y(-75.000),z(78.000),
		x(82.000),y(-80.000),z(74.000) },
	--leg2
	{ x(78.000),y(-75.000),z(86.000),
		x(82.000),y(-80.000),z(82.000) },
}


local nodebox_chicken ={

	--body
	{x(50),y(-60),z(100),x(110),y(-90),z(60)},
	
	--body lower
	{x(60),y(-90),z(90),x(100),y(-100),z(70)},
	
	--tail
	{x(40),y(-60),z(90),x(50),y(-80),z(70)},
	{x(30),y(-54),z(85),x(40),y(-70),z(75)},
	
	--neck
	{x(110),y(-45),z(88),x(120),y(-80),z(72)},
	{x(120),y(-40),z(88),x(130),y(-70),z(72)},
	
	{x(130),y(-48),z(83),x(140),y(-54),z(77)},
	
	--feet
	{x(78),y(-100),z(88),x(82),y(-110),z(85)},
	{x(75),y(-110),z(88),x(85),y(-112),z(85)},
	
	{x(78),y(-100),z(75),x(82),y(-110),z(72)},
	{x(75),y(-110),z(75),x(85),y(-112),z(72)},
	
}

local nodebox_rooster ={

    --body
    {x(50),y(-60),z(100),x(110),y(-90),z(60)},
    
    --body lower
    {x(60),y(-90),z(90),x(100),y(-100),z(70)},
    
    --tail
    {x(40),y(-60),z(90),x(50),y(-80),z(70)},
    {x(30),y(-54),z(85),x(40),y(-70),z(75)},
    
    --neck
    {x(110),y(-45),z(88),x(120),y(-80),z(72)},
    {x(120),y(-40),z(88),x(130),y(-70),z(72)},
    
    {x(130),y(-48),z(83),x(140),y(-54),z(77)},
    
    {x(120),y(-35),z(81),x(130),y(-50),z(79)},
    {x(115),y(-38),z(81),x(120),y(-50),z(79)},
    
    --feet
    {x(78),y(-100),z(88),x(82),y(-110),z(85)},
    {x(75),y(-110),z(88),x(85),y(-112),z(85)},
    
    {x(78),y(-100),z(75),x(82),y(-110),z(72)},
    {x(75),y(-110),z(75),x(85),y(-112),z(72)},
    
}


minetest.register_node("animal_chicken:box_chicken", {
	tiles = textures_chicken,
	drawtype = "nodebox",
	node_box = {
		type = "fixed",
		fixed = nodebox_chicken
		},
		groups = chicken_groups
		})
		
minetest.register_node("animal_chicken:box_rooster", {
    tiles = textures_rooster,
    drawtype = "nodebox",
    node_box = {
        type = "fixed",
        fixed = nodebox_rooster
        },
        groups = chicken_groups
        })
        
minetest.register_node("animal_chicken:box_chick", {
    tiles = textures_chick,
    drawtype = "nodebox",
    node_box = {
        type = "fixed",
        fixed = nodebox_chick
        },
        groups = chicken_groups
        })
