
mob_npc_houses = {}
building_spawner = {}

blueprint_normalhouse = {
	size = {x=8,z=10},
	walls = {
	--cleanarea
		{"air",{x=-1,y=1,z=-1},{x=9,y=1,z=11}},
		{"air",{x=-1,y=2,z=-1},{x=9,y=2,z=11}},
		{"air",{x=-1,y=3,z=-1},{x=9,y=3,z=11}},
		{"air",{x=-1,y=4,z=-1},{x=9,y=4,z=11}},
		{"air",{x=-1,y=5,z=-1},{x=9,y=5,z=11}},
		{"air",{x=-1,y=6,z=-1},{x=9,y=6,z=11}},
		{"air",{x=-1,y=7,z=-1},{x=9,y=7,z=11}},
		{"air",{x=-1,y=8,z=-1},{x=9,y=8,z=11}},
		{"air",{x=-1,y=9,z=-1},{x=9,y=9,z=11}},
	--floor
		{"default:stone",{x=0,y=0,z=0},{x=8,y=0,z=10}},
		
	--walls
		{"default:brick",{x=0,y=1,z=0},{x=8,y=4,z=0}},
		{"default:brick",{x=0,y=1,z=10},{x=8,y=4,z=10}},
		{"default:brick",{x=8,y=1,z=0},{x=8,y=4,z=10}},
		{"default:brick",{x=0,y=1,z=0},{x=0,y=4,z=10}},
		
	--roof
		{"default:clay",{x=-1,y=5,z=-1},{x=9,y=5,z=11}},
		{"default:clay",{x=1,y=6,z=1},{x=7,y=6,z=9}},
		{"default:clay",{x=3,y=7,z=3},{x=5,y=7,z=7}},
		
	--front_door
		{"air",{x=2,y=1,z=0},{x=2,y=2,z=0}},
		
	--windows
		{"default:glass",{x=4,y=1,z=0},{x=7,y=3,z=0}},
		{"default:glass",{x=0,y=2,z=2},{x=0,y=3,z=3}},
		{"default:glass",{x=8,y=2,z=4},{x=8,y=3,z=5}},

	--torches
		{"default:torch",{x=1,y=3,z=7},{x=1,y=3,z=7}},
		{"default:torch",{x=3,y=3,z=9},{x=3,y=3,z=9}},
		{"default:torch",{x=5,y=3,z=9},{x=5,y=3,z=9}},
		{"default:torch",{x=3,y=4,z=3},{x=3,y=4,z=3}},
		{"default:torch",{x=5,y=4,z=3},{x=5,y=4,z=3}},
		
	--
		{"default:wood",{x=1,y=1,z=4},{x=3,y=1,z=4}},
		{"default:wood",{x=4,y=1,z=4},{x=4,y=1,z=8}},
		
	--shelfs
		{"default:bookshelf",{x=7,y=1,z=7},{x=7,y=3,z=9}},
		
	--kamin
		{"default:cobble",{x=1,y=1,z=7},{x=1,y=2,z=7}},
		{"default:cobble",{x=1,y=1,z=9},{x=1,y=2,z=9}},
		{"default:cobble",{x=1,y=2,z=8},{x=1,y=4,z=8}},
		{"default:cobble",{x=0,y=1,z=7},{x=0,y=2,z=9}},
		{"default:lava_source",{x=1,y=0,z=8},{x=1,y=0,z=8}},
	},
	entities = {
			{ {x=3,y=1,z=5},"mob_npc:npc_trader__default",-1.14 }
		}
}

table.insert(mob_npc_houses,blueprint_normalhouse)

function building_spawner.buid_wall(material,startpos,endpos)

	--print("builder: wall: ".. dump(material) .. " " .. dump(startpos) .. " " .. dump(endpos))

	if startpos.x ~= endpos.x and
		startpos.y ~= endpos.y and
		startpos.z ~= endpos.z then
		return false
	end
	
	if endpos.x < startpos.x or
		endpos.y < startpos.y or
		endpos.z < startpos.z then
		return false
	end

	if startpos.x == endpos.x then
	
		for y=startpos.y,endpos.y,1 do
		for z=startpos.z,endpos.z,1 do
			minetest.env:set_node({x=startpos.x,y=y,z=z},{ name=material } )
		end
		end
	end
	
	if startpos.y == endpos.y then
		for x=startpos.x,endpos.x,1 do
		for z=startpos.z,endpos.z,1 do
			minetest.env:set_node({x=x,y=startpos.y,z=z},{ name=material })
		end
		end	
	end
	
	if startpos.z == endpos.z then
		for y=startpos.y,endpos.y,1 do
		for x=startpos.x,endpos.x,1 do
			minetest.env:set_node({x=x,y=y,z=startpos.z},{ name=material })
		end
		end	
	end
	
	return true
end

function building_spawner.checkfloor(startpos,endpos)

	if startpos.y ~= endpos.y then
		return false
	end

	if endpos.x < startpos.x or
		endpos.y < startpos.y or
		endpos.z < startpos.z then
		return false
	end

	for x=startpos.x,endpos.x,1 do
	for z=startpos.z,endpos.z,1 do
	
		local found_ground	= false
		local found_air		= false
		for y=startpos.y-1,startpos.y+2,1 do
			local node_to_check	= minetest.env:get_node({x=x,y=y,z=z})

			if node_to_check ~= nil and
				node_to_check.name ~= "ignore" then
			
				if node_to_check.name == "air" then
					found_air = true
				end
				
				if node_to_check.name == "default:dirt" or
					node_to_check.name == "default:stone" or
					node_to_check.name == "default:dirt_with_grass" or 
					node_to_check.name == "default:desert_stone" or
					node_to_check.name == "default:desert_sand" then
					found_ground = true
				end
			end
		end
		
		if not found_ground or
			not found_air then
			--print("builder: surface not correct: " .. dump(found_ground) .. " " .. dump(found_air))
			return false
		end
	end
	end
	
	return true
end


function building_spawner.builder(startpos,blueprint,mobname)

	if building_spawner.checkfloor(
			{
				x=startpos.x -1,
				y=startpos.y,
				z=startpos.z -1
			},
			{
				x=startpos.x +blueprint.size.x + 1,
				y=startpos.y,
				z=startpos.z +blueprint.size.z + 1
			}
		) then
		--print("spawning building at " .. printpos(startpos) .. "!")
		for i=1,#blueprint.walls,1 do
			building_spawner.buid_wall(blueprint.walls[i][1],
						{
							x=startpos.x + blueprint.walls[i][2].x,
							y=startpos.y + blueprint.walls[i][2].y,
							z=startpos.z + blueprint.walls[i][2].z
						},
						{
							x=startpos.x + blueprint.walls[i][3].x,
							y=startpos.y + blueprint.walls[i][3].y,
							z=startpos.z + blueprint.walls[i][3].z
						})
		end
		
		for i=1,#blueprint.entities,1 do
			if mobname == nil then
				mobname = blueprint.entities[i][2]
			end
			local object = minetest.env:add_entity( {
								x=startpos.x + blueprint.entities[i][1].x,
								y=startpos.y + blueprint.entities[i][1].y,
								z=startpos.z + blueprint.entities[i][1].z},
								mobname)
			if object ~= nil then
				object:setyaw(blueprint.entities[i][3])
			end
		end
		
		return true
	end
	
	return false
end

-------------------------------------------------------------------------------
-- name: mobf_spawn_on_willow_mapgen(mob_name,mob_transform,spawning_data,environment)
--
--! @brief find a place on willow to spawn a mob on map generation
--
--! @param mob_name name of mob
--! @param mob_transform secondary name of mob
--! @param spawning_data spawning configuration
--! @param environment environment of mob
-------------------------------------------------------------------------------
function mob_npc_spawn_building(mob_name,mob_transform,spawning_data,environment)
	minetest.log(LOGLEVEL_INFO,"MOBF:\tspawn_building spawner for mob "..mob_name)
	
	--add mob on map generation
	minetest.register_on_generated(function(minp, maxp, seed)
		spawning.divide_mapgen(minp,maxp,spawning_data.density,mob_name,mob_transform,
		
		function(name,pos,min_y,max_y)
			
			if math.random() < 0.05 then
				local blueprint = mob_npc_houses[math.random(1,#mob_npc_houses)]
				
				if building_spawner.builder(pos,blueprint,mob_name .."__default") then
					return true
				end
			end
			return false
		end,
		mobf_get_sunlight_surface,
		20)
	end)
end --end spawn algo

function build_house_cmd_handler(name,param)
	local parameters = param:split(" ")

	if #parameters ~= 2 and
		#parameters ~= 3 then
		minetest.chat_send_player(name, "/build_house invalid parameter count: " .. #parameters)
		return
	end
	
	local pos_strings = parameters[1]:split(",")

	if #pos_strings ~= 3 then
		minetest.chat_send_player(name, "/build_house invalid position")
		return
	end

	local spawnpoint = {
						x=tonumber(pos_strings[1]),
						y=tonumber(pos_strings[2]),
						z=tonumber(pos_strings[3])
						}

	if spawnpoint.x == nil or
		spawnpoint.y == nil or
		spawnpoint.z == nil then
		minetest.chat_send_player(name, "/build_house invalid position")
		return
	end
	
	local blueprintnumber = tonumber(parameters[2])
	
	if blueprintnumber == nil then
		minetest.chat_send_player(name, "/build_house invalid blueprintnumber")
		return
	end
	
	if mob_npc_houses[blueprintnumber] == nil then
		minetest.chat_send_player(name, "/build_house no blueprint with number " .. blueprintnumber .. " known")
		return
	end
	
	if not building_spawner.builder(spawnpoint,mob_npc_houses[blueprintnumber],parameters[3]) then
		minetest.chat_send_player(name, "/build_house failed to build house maybe ground wasn't suitable")
	end
end
 
minetest.register_chatcommand("build_house",
			{
				params		= "<pos> <blueprintnumber> <mobname|optional>",
				description = "spawn a house at a specific position" ,
				privs		= {mobfw_admin=true},
				func		= build_house_cmd_handler,

			})
 
spawning.register_spawn_algorithm("building_spawner", mob_npc_spawn_building)