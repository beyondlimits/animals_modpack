
local playerdata = nil

local tutor_init = function(entity)
	if entity.dynamic_data.quest == nil then
		entity.dynamic_data.quest = {
			personal_tutor_for = nil,
		}
	end
end

local tutor_prototype = {
		name="tutor",
		modname="mob_npc",

		factions = {
			member = {
				"npc",
				}
			},

		generic = {
					description="Your personal tutor",
					base_health=40,
					kill_result="",
					armor_groups= {
						fleshy=90,
					},
					groups = npc_groups,
					envid="simple_air",
					population_density=0,
					custom_on_activate_handler=tutor_init,
				},
		movement =  {
					min_accel=0.3,
					max_accel=0.7,
					max_speed=1.5,
					min_speed=0.01,
					pattern="stop_and_go",
					canfly=false,
					},
		states = {
				{
				name = "default",
				movgen = "none",
				typical_state_time = 180,
				chance = 0.00,
				animation = "stand",
				graphics_3d = {
					visual = "mesh",
					mesh = "npc_character.b3d",
					textures = {"mob_npc_tutor.png"},
					collisionbox = {-0.3,-1.0,-0.3, 0.3,0.8,0.3},
					visual_size= {x=1, y=1},
					},
				},
			},
		animation = {
				walk = {
					start_frame = 168,
					end_frame   = 187,
					},
				stand = {
					start_frame = 0,
					end_frame   = 79,
					},
			},
		quest = {
			questlist = {
				"mobf_tutorial_1",
				"mobf_tutorial_2",
				"mobf_tutorial_3",
				"mobf_tutorial_4",
				"mobf_tutorial_5",
				"mobf_tutorial_6",
				"mobf_tutorial_7",
				"mobf_tutorial_8",
				"mobf_tutorial_9",
				"mobf_tutorial_10",
				"mobf_tutorial_11",
				"mobf_tutorial_12",
				"mobf_tutorial_13",
			}
		},
	}
	
local spawntutor = function(player)
	local playername = player:get_player_name()
	
	if utils.contains(playerdata, playername) then
		return
	end

	-- find place in front of player
	local direction = player:get_look_dir()
	local playerpos = player:getpos()
	local tutorpos = {
			x = playerpos.x + (direction.x*2),
			y = playerpos.y +1,
			z = playerpos.z + (direction.z*2),
			}
	
	print("Player: " .. playername .. " not yet known spawning tutor pos=" .. printpos(playerpos))
	
	-- spawn tutor in front of player
	local tutor_entity = spawning.spawn_and_check("mob_npc:tutor", tutorpos, "tutor_spawning")
	
	-- set player to be owner of tutor
	tutor_entity.dynamic_data.quest.personal_tutor_for = playername
	
	table.insert(playerdata, playername)
	utils.write_world_data("mobf_tutor_data", playerdata)
	
	--rotate mob to face player
	local direction = mobf_get_direction(tutorpos, player:getpos())

	if tutor_entity.mode == "3d" then
		graphics.setyaw(tutor_entity,
			mobf_calc_yaw(direction.x,direction.z))
	else
		graphics.setyaw(tutor_entity,
			mobf_calc_yaw(direction.x,direction.z)+math.pi/2)
	end
end
	
local on_join = function(player)
	core.after(2, spawntutor, player)
end

-- if personal tutor is requested for player
if mobf_get_world_setting("mobf_personal_tutor") or minetest.is_singleplayer() then

	minetest.log("action", "Enabling personal tutor support.")

	core.register_on_joinplayer(on_join)
	
	playerdata = utils.read_world_data("mobf_tutor_data")
	
	if playerdata == nil then
		playerdata = {}
	end
end

minetest.log("action","\tadding mob "..tutor_prototype.name)
mobf_add_mob(tutor_prototype)