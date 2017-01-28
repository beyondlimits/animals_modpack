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
	title= "Scissors crafting",
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
	title="Sheep sheering",
	init_state = {
		text = "are you ready for your next lesson?\n\n" ..
				"The next lesson will be about how to sheer sheep.\n" .. 
				"If you want to get wool from them just punch a sheep while you have scissors selected.\n" ..
				"The sheep will be naked afterwards and you'll have to wait some time for the wool to grow again.\n\n" ..
				"Just give it a try and get back once you've sheered at least 4 sheep.",
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
				"Did you sheer 4 sheep by now?",
		
		action1 = {
			events_required = {
				{ type="event_harvest", count=4, mobtype="animal_sheep:sheep"}
			},
			next_state="quest_completed",
			msg="Yes I did that's been quite funny!"
			},
		action2 = {
			events_required = {
				{ type="event_harvest", count=4, mobtype="animal_sheep:sheep"}
			},
			next_state="quest_completed",
			msg="Yes I did but it's been quite boring."
		},
		action3 = {
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
local mobf_tutorial_3 = {
	quests_required = { "mobf_tutorial_2"},
	repeatable = false,
	title="Lasso crafting",
	init_state = {
		text = "very good you've learned how to harvest wool from sheep.\n\n" ..
				"Now it's time for our next lesson.\n" .. 
				"Topic is how to create a lasso for catching mobs.\n" ..
				"Have a look to the right to see the reciep for crafting a lasso\n\n" ..
				"Craft 3 of them and get back to me with them.",
		action1 =  { 
					action_available_fct=nil, 
					msg="Great I always wanted to catch mobs, I'll be back soon", 
					next_state="wait_for_lasso"
					},
		action2 =  { msg="No thank's catching mobs ain't my style of doing things" },
		reciep = {
					{ "", "wool:white", "" },
					{ "wool:white", "", "wool:white" },
					{ "", "wool:white", "" }
				},
	},
	
	wait_for_lasso = {
		text = "nice to meet you once again. Lasso crafting is fun, isn't it?\n" ..
				"Do you have the 3 lassos I requested you to craft?",
		
		action1 = {
			action_available_fct=function(entity,player)
				if player:get_inventory():contains_item("main","animalmaterials:lasso 3") then
					return true
				end
				return false
			end,
			next_state="quest_completed",
			msg="Yes I do, very good master grade lassos of course!"
			},
		action2 = {
			msg="Not yet, I'm still working at it."
			},
		reciep = {
					{ "", "wool:white", "" },
					{ "wool:white", "", "wool:white" },
					{ "", "wool:white", "" }
				},
	}
}

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
local mobf_tutorial_4 = {
	quests_required = { "mobf_tutorial_3"},
	repeatable = false,
	title="Mob catching",
	init_state = {
		text = "Great lassos indeed.\n\n" ..
				"Not all mobs can be cought using a lasso but there are quite a few which can.\n" .. 
				"I'd suggest start catching sheep but of course you can catch cattle or chicken too.\n" ..
				"If you need more lassos, don't bother to craft\n" ..
				"Now take your chances and catch at least 10 mobs before I can teach you your next lesson.",
		action1 =  { 
					action_available_fct=nil, 
					msg="Oh boy 10 mobs that's gonna be quite some work", 
					next_state="wait_for_catching_done"
					},
		action2 =  { msg="No thank's I don't wanna catch mobs right now" },
	},
	
	wait_for_catching_done = {
		text = "it's always a pleasure to see you.\n" ..
				"Did you manage to catch 10 mobs yet?",
		
		action1 = {
			events_required = {
				{ type="event_cought", count=10 }
			},
			next_state="quest_completed",
			msg="Yes of course it's been way more easy then I expected."
			},
		action2 = {
			msg="Not yet, I'm still looking for mobs."
			},
	}
}

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
local mobf_tutorial_5 = {
	quests_required = { "mobf_tutorial_4"},
	repeatable = false,
	title="Breeding",
	init_state = {
		text = "Now that you know how to catch animals I'm gonna show you how to breed them."..
				"\nLets start breeding chicks. I suggest building some sort of cage so your chicken don't runn away." ..
				"\nOnce you've built that cage catch at least a chicken and a rooster and craft a barn as shown to the right." ..
				"\nPlace the barn within your cage and fill it (punch barn!) using leaves for example." ..
				"\n\nNow take your time and wait till a chick spawns.\n" ..
				"To complete this quest breed at least 3 chicks. If you want to do this faster craft more barns.",
		action1 =  { 
					action_available_fct=nil, 
					msg="Great I'm gonna start immediatly", 
					next_state="wait_for_breeding_done"
					},
		action2 =  { msg="No thank's" },
		reciep = {
			{ "", "", "" },
			{ "default:stick", "default:stick", ""},
			{ "default:wood", "default:wood", ""}
		}
	},
	
	wait_for_breeding_done = {
		text = "it's always a pleasure to see you.\n" ..
				"Did you bree 3 chicks yet?",
		
		action1 = {
			events_required = {
				{ type="event_breed", mobtype1="animal_chicken:chicken", mobtype2="animal_chicken:rooster", count=3 }, 
				{ type="event_craft", item="barn:barn_small_empty", count=1 }
			},
			next_state="quest_completed",
			msg="Yes 3 little chicks grew up."
			},
		action2 = {
			msg="Not yet, I'm still working on it."
			},
		reciep = {
			{ "", "", "" },
			{ "default:stick", "default:stick", ""},
			{ "default:wood", "default:wood", ""}
		}
	}
}

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
quest_engine.register_quest("mobf_tutorial_1", mobf_tutorial_1)
quest_engine.register_quest("mobf_tutorial_2", mobf_tutorial_2)
quest_engine.register_quest("mobf_tutorial_3", mobf_tutorial_3)
quest_engine.register_quest("mobf_tutorial_4", mobf_tutorial_4)
quest_engine.register_quest("mobf_tutorial_5", mobf_tutorial_5)