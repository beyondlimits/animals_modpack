function x(val) 
 return ((val -80) / 160)
end

function z(val) 
 return ((val -80) / 160)
end

function y(val)
	return ((val + 80) / 160)
end

local textures_baby_calf = {
            "animal_cow_baby_calf_bottom.png",
            "animal_cow_baby_calf_top.png",
            "animal_cow_baby_calf_front.png",
            "animal_cow_baby_calf_back.png",
            "animal_cow_baby_calf_left.png",
            "animal_cow_baby_calf_right.png",
}

function xs(value)
	 return (value - (100/2)) / 100
end

function zs(value)
	 return (value - (100/2)) / 100
end

function ys(value)
	 return (value + (100/2)) / 100
end

local nodebox_baby_calf = {
	--Body
	{ xs(0.000),ys(-30.000),zs(65.000),
		xs(65.000),ys(-60.000),zs(35.000) },
	--Head
	{ xs(85.000),ys(-14.000),zs(58.000),
		xs(98.000),ys(-22.000),zs(42.000) },
	--Head3
	{ xs(65.000),ys(-3.000),zs(59.000),
		xs(85.000),ys(-22.000),zs(41.000) },
	--Neck1
	{ xs(43.000),ys(-22.000),zs(59.000),
		xs(68.000),ys(-30.000),zs(41.000) },
	--Neck2
	{ xs(54.000),ys(-13.000),zs(57.000),
		xs(65.000),ys(-22.000),zs(43.000) },
	--Neck3
	{ xs(68.000),ys(-22.000),zs(57.000),
		xs(75.000),ys(-30.000),zs(43.000) },
	--Leg1
	{ xs(0.000),ys(-60.000),zs(45.000),
		xs(10.000),ys(-100.000),zs(35.000) },
	--Leg2
	{ xs(55.000),ys(-60.000),zs(65.000),
		xs(65.000),ys(-100.000),zs(55.000) },
	--Leg3
	{ xs(0.000),ys(-60.000),zs(65.000),
		xs(10.000),ys(-100.000),zs(55.000) },
	--Leg4
	{ xs(55.000),ys(-60.000),zs(45.000),
		xs(65.000),ys(-100.000),zs(35.000) },
	--Head2
	{ xs(85.000),ys(-10.000),zs(58.000),
		xs(90.000),ys(-14.000),zs(42.000) },
	--Neck4
	{ xs(65.000),ys(-30.000),zs(57.000),
		xs(69.000),ys(-49.000),zs(43.000) },
}

minetest.register_node("animal_cow:box_baby_calf", {
    tiles = textures_baby_calf,
    drawtype = "nodebox",
    node_box = {
        type = "fixed",
        fixed = nodebox_baby_calf
        },
        groups = cow_groups
        })