function x(val) 
 return ((val -20) / 40)
end

function z(val) 
 return ((val -20) / 40)
end

function y(val)
    return ((val + 20) / 40)
end

local textures_creeper = {
            "animal_creeper_boombomb_bottom.png",
            "animal_creeper_boombomb_top.png",
            "animal_creeper_boombomb.png",
            "animal_creeper_boombomb.png",
            "animal_creeper_boombomb.png",
            "animal_creeper_boombomb.png",
}

local nodebox_creeper = {
        {x(19.75),y(2.5),z(20.25),
            x(20.25),y(0),z(19.75) },
        {x(19.75),y(2.75),z(20.25),
            x(22.5),y(2.5),z(19.75) },
        {x(22.25),y(5),z(20.25),
            x(22.5),y(2.5),z(19.75) },
        {x(22.5),y(5),z(20.25),
            x(25),y(5.25),z(19.75) },
        }

local radius = 20
local yval = -1

for yval = -1, -40, -1 do

    local hperr = (radius + yval)/radius
    local asin  = math.asin(hperr)

    local x_delta = math.floor(math.cos(asin) * 20)
    
    print("XDelta: " .. x_delta .. " yval: " .. yval .. " h/r: " .. hperr .. " asin: " .. asin)
    table.insert(nodebox_creeper,{x(radius-x_delta),y(yval),z(22),
                                    x(radius+x_delta),y(yval-1),z(18) })
                                    
    table.insert(nodebox_creeper,{x(18),y(yval),z(radius+x_delta),
                                    x(22),y(yval-1),z(radius-x_delta) })
                                    
    table.insert(nodebox_creeper,{x(radius-x_delta+1),y(yval),z(24),
                                    x(radius+x_delta-1),y(yval-1),z(16) })
                                    
    table.insert(nodebox_creeper,{x(16),y(yval),z(radius+x_delta-1),
                                    x(24),y(yval-1),z(radius-x_delta+1) })
    if yval < -2 and yval > -38 then
    table.insert(nodebox_creeper,{x(radius-x_delta+2),y(yval),z(26),
                                    x(radius+x_delta-2),y(yval-1),z(14) })
                                    
    table.insert(nodebox_creeper,{x(14),y(yval),z(radius+x_delta-2),
                                    x(26),y(yval-1),z(radius-x_delta+2) })
    end
    
    if yval < -3 and yval > -37 then
    table.insert(nodebox_creeper,{x(radius-x_delta+3),y(yval),z(28),
                                    x(radius+x_delta-3),y(yval-1),z(12) })
                                    
    table.insert(nodebox_creeper,{x(12),y(yval),z(radius+x_delta-3),
                                    x(28),y(yval-1),z(radius-x_delta+3) })
    end
    
    if yval < -4 and yval > -36 then
    table.insert(nodebox_creeper,{x(radius-x_delta+4),y(yval),z(30),
                                    x(radius+x_delta-4),y(yval-1),z(10) })
                                    
    table.insert(nodebox_creeper,{x(10),y(yval),z(radius+x_delta-4),
                                    x(30),y(yval-1),z(radius-x_delta+4) })
    end
    
    if yval < -5 and yval > -35 then
    table.insert(nodebox_creeper,{x(radius-x_delta+5),y(yval),z(32),
                                    x(radius+x_delta-5),y(yval-1),z(8) })
                                    
    table.insert(nodebox_creeper,{x(8),y(yval),z(radius+x_delta-5),
                                    x(32),y(yval-1),z(radius-x_delta+5) })
    end
end



minetest.register_node("animal_creeper:box_creeper", {
    tiles = textures_creeper,
    drawtype = "nodebox",
    node_box = {
        type = "fixed",
        fixed = nodebox_creeper
        },
        groups = creeper_groups
        })