-------------------------------------------------------------------------------
-- Mob Framework Mod by Sapier
--
-- You may copy, use, modify or do nearly anything except removing this
-- copyright notice.
-- And of course you are NOT allow to pretend you have written it.
--
--! @file tutorial_quests.lua
--! @brief quests tutor npc uses to teach you how to interact with mobs
--! @copyright Sapier
--! @author Sapier
--! @date 2017-01-21
--
-- Contact sapier a t gmx net
-------------------------------------------------------------------------------

local mobf_tutorial_1 = {
	quests_required = {},
	repeatable = false,
	init_state = {
		text = "nice to meet you. I'm your tutor. I'm gonna teach you what you can do with mobs" ..
				" from \"animals modpack\".\n\n" ..
				"Let's start with how to get wool from sheep." ..
				"\nIn order to sheer sheep you'll need to craft scissors." ..
				" Have a look at the reciep to the right.\n\n" ..
				"Once you've crafted your pair of scissors come back to me for further instructions.",
		action1 =  { 
					action_available_fct=nil, 
					msg="Ok I'm gonna craft scissors", 
					next_state="wait_for_scissors"
					},
		action2 =  { msg="No thank's I don't wanna learn anything" },
		reciep = {
					{ "", "default:steel_ingot", "" },
					{ "", "default:steel_ingot", "" },
					{ "default:stick", "", "default:stick" }
		}
	},
	
	wait_for_scissors = {
		text = "nice to meet you once again. Did you craft you scissors yet?\n" ..
				"Have a look at the reciep to the right if you're unsure how to craft them.",
		reciep = {
					{ "", "default:steel_ingot", "" },
					{ "", "default:steel_ingot", "" },
					{ "default:stick", "", "default:stick" }
				},
		action1 = {
			action_available_fct=function(entity,player)
				if player:get_inventory():contains_item("main","animalmaterials:scissors 1") then
					return true
				end
				return false
			end,
			next_state="quest_completed",
			msg="Yes I did, have a look at them."
			},
		action2 = {
			msg="Not yet, I'm still looking for the raw materials."
			}
	
	}
}

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
local mobf_tutorial_2 = {
	quests_required = { "mobf_tutorial_1"},
	repeatable = false,
	init_state = {
		text = "are you ready for your next lesson?\n\n" ..
				"The next lesson will be about how to sheer sheep.\n" .. 
				"If you want to get wool from them just punch a sheep while you have scissors selected.\n" ..
				"The sheep will be naked afterwards and you'll have to wait some time for the wool to grow again.\n\n" ..
				"Just give it a try and get back once you've collected at least 4 pieces of wool.",
		action1 =  { 
					action_available_fct=nil, 
					msg="Ok I'm gonna look for sheep and sheer them", 
					next_state="wait_for_wool"
					},
		action2 =  { msg="No thank's sheering sheep is stupid" },
		reciep = {
					{ "", "", "" },
					{ "", "animalmaterials:scissors", "" },
					{ "", "", "" }
				},
	},
	
	wait_for_wool = {
		text = "nice to meet you once again. How's your sheep sheering going on?\n" ..
				"Do you have the 4 pieces of wool?",
		
		action1 = {
			action_available_fct=function(entity,player)
				if player:get_inventory():contains_item("main","wool:white 4") then
					return true
				end
				return false
			end,
			next_state="quest_completed",
			msg="Yes I do, good work, isn't it?"
			},
		action2 = {
			msg="Not yet, I'm still looking for sheep to sheer."
			},
		reciep = {
					{ "", "", "" },
					{ "", "animalmaterials:scissors", "" },
					{ "", "", "" }
				},
	}
}

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
mobf_quest_engine.register_quest("mobf_tutorial_1", mobf_tutorial_1)
mobf_quest_engine.register_quest("mobf_tutorial_2", mobf_tutorial_2)