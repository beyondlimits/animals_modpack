function x(val) 
 return ((val -80) / 160)
end

function z(val) 
 return ((val -80) / 160)
end

function y(val)
	return ((val + 80) / 160)
end

local textures_dm = {
            "animal_dm_dm_bottom.png",
            "animal_dm_dm_top.png",
            "animal_dm_dm_front.png",
            "animal_dm_dm_back.png",
            "animal_dm_dm_back.png",
            "animal_dm_dm_back.png",
}

local nodebox_dm ={

    --head
    {x(70),y(-10),z(95),x(100),y(-20),z(65) },
    
    --shoulders
    {x(65),y(-20),z(130),x(95),y(-50),z(30) },

    --face
    {x(95),y(-20),z(105),x(105),y(-50),z(55) },

    --body
    {x(60),y(-50),z(105),x(100),y(-120),z(55) },
    {x(65),y(-70),z(110),x(95),y(-110),z(50) },
    
     --belly
    {x(100),y(-70),z(100),x(105),y(-110),z(60) },
	
	--arms
    {x(80),y(-50),z(130),x(100),y(-60),z(112) },
    {x(80),y(-50),z(48),x(100),y(-60),z(30) },
    {x(85),y(-60),z(130),x(105),y(-70),z(112) },
    {x(85),y(-60),z(48),x(105),y(-70),z(30) },
    {x(90),y(-70),z(130),x(110),y(-75),z(112) },
    {x(90),y(-70),z(48),x(110),y(-75),z(30) },
    {x(100),y(-75),z(130),x(115),y(-90),z(112) },
    {x(100),y(-75),z(48),x(115),y(-90),z(30) },
	
	--legs
	
	{x(70),y(-120),z(105),x(90),y(-140),z(82.5) },
	{x(70),y(-120),z(77.5),x(90),y(-140),z(55) },
	
	{x(70),y(-140),z(110),x(90),y(-160),z(87.5) },
    {x(70),y(-140),z(72.5),x(90),y(-160),z(50) },
}

minetest.register_node("animal_dm:box_dm", {
	tiles = textures_dm,
	drawtype = "nodebox",
	node_box = {
		type = "fixed",
		fixed = nodebox_dm
		},
		groups = dm_groups
		})