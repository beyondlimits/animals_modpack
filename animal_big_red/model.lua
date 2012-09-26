function x(val) 
 return ((val -80) / 160)
end

function z(val) 
 return ((val -80) / 160)
end

function y(val)
	return ((val + 120) / 240)
end

local textures_dm = {
            "animal_big_red_big_red_bottom.png",
            "animal_big_red_big_red_top.png",
            "animal_big_red_big_red_front.png",
            "animal_big_red_big_red_back.png",
            "animal_big_red_big_red_right.png",
            "animal_big_red_big_red_left.png",
}

local nodebox_big_red ={

    --corns
    
    {x(82),y(0),z(113),x(88),y(-10),z(107) },
    {x(80),y(-10),z(110),x(90),y(-20),z(100) },
    {x(80),y(-20),z(105),x(90),y(-30),z(95) },
    {x(80),y(-30),z(100),x(90),y(-40),z(90) },
    
    {x(82),y(0),z(53),x(88),y(-10),z(47) },
    {x(80),y(-10),z(60),x(90),y(-20),z(50) },
    {x(80),y(-20),z(65),x(90),y(-30),z(55) },
    {x(80),y(-30),z(70),x(90),y(-40),z(60) },

    --head
    {x(60),y(-40),z(100),x(95),y(-80),z(60) },

    --face
    --todo
    {x(95),y(-40),z(100),x(100),y(-50),z(60) },
    {x(95),y(-50),z(75),x(100),y(-60),z(60) },
    {x(95),y(-50),z(100),x(100),y(-60),z(85) },
    {x(95),y(-60),z(100),x(100),y(-65),z(60) },
    
    --tooth
    {x(95),y(-65),z(70),x(100),y(-75),z(60) },
    
    {x(95),y(-65),z(70),x(100),y(-75),z(67.5) },
    {x(95),y(-65),z(75),x(100),y(-70),z(72.5) },
    {x(95),y(-65),z(80),x(100),y(-75),z(77.5) },
    {x(95),y(-70),z(82.5),x(100),y(-75),z(80) },
    {x(95),y(-65),z(87.5),x(100),y(-75),z(85) },
    
    {x(95),y(-65),z(100),x(100),y(-75),z(90) },
    --end tooth
    {x(95),y(-75),z(100),x(100),y(-80),z(60) },

    --body
    {x(60),y(-80),z(120),x(100),y(-150),z(40) },
	
	--arms
    {x(60),y(-80),z(40),x(140),y(-100),z(20) },
    {x(60),y(-80),z(140),x(140),y(-100),z(120) },
    
    --fingers
    {x(135),y(-80),z(140),x(142),y(-110),z(135) },
    {x(135),y(-80),z(130),x(142),y(-110),z(125) },
    
    {x(135),y(-80),z(30),x(142),y(-110),z(25) },
    
	
	--legs
	{x(75),y(-140),z(70),x(105),y(-190),z(40) },
	{x(80),y(-190),z(70),x(110),y(-240),z(40) },

    {x(55),y(-140),z(120),x(95),y(-190),z(90) },
    {x(65),y(-190),z(110),x(75),y(-240),z(100) },
}

minetest.register_node("animal_big_red:box_big_red", {
	tiles = textures_dm,
	drawtype = "nodebox",
	node_box = {
		type = "fixed",
		fixed = nodebox_big_red
		},
		groups = big_red_groups
		})