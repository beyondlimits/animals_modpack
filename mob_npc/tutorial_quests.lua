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
				" Have a look at the recipe to the right.\n\n" ..
				"Once you've crafted your pair of scissors come back to me for further instructions.",
		action1 =  { 
					action_available_fct=nil, 
					msg="Ok I'm gonna craft scissors", 
					next_state="wait_for_scissors"
					},
		action2 =  { msg="No thank's I don't wanna learn anything" },
		recipe = {
					{ "", "default:steel_ingot", "" },
					{ "", "default:steel_ingot", "" },
					{ "default:stick", "", "default:stick" }
		}
	},
	
	wait_for_scissors = {
		text = "nice to meet you once again. Did you craft you scissors yet?\n" ..
				"Have a look at the recipe to the right if you're unsure how to craft them.",
		recipe = {
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
		recipe = {
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
		recipe = {
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
				"Have a look to the right to see the recipe for crafting a lasso\n\n" ..
				"Craft 3 of them and get back to me with them.",
		action1 =  { 
					action_available_fct=nil, 
					msg="Great I always wanted to catch mobs, I'll be back soon", 
					next_state="wait_for_lasso"
					},
		action2 =  { msg="No thank's catching mobs ain't my style of doing things" },
		recipe = {
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
		recipe = {
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
		recipe = {
			{ "", "", "" },
			{ "default:stick", "default:stick", ""},
			{ "default:wood", "default:wood", ""}
		}
	},
	
	wait_for_breeding_done = {
		text = "it's always a pleasure to see you.\n" ..
				"Did you breed 3 chicks yet?",
		
		action1 = {
			events_required = {
				{ type="event_breed", mobtype1="animal_chicken:chicken", mobtype2="animal_chicken:rooster", count=3 }, 
				{ type="event_craft", item="barn:barn_small_empty", count=1 }
			},
			next_state="spawn_from_egg",
			msg="Yes 3 little chicks grew up."
			},
		action2 = {
			msg="Not yet, I'm still working on it."
			},
		recipe = {
			{ "", "", "" },
			{ "default:stick", "default:stick", ""},
			{ "default:wood", "default:wood", ""}
		}
	},
	
	spawn_from_egg = {
		text = "Great to hear you managed to breed chicks.\n\n" ..
				"Btw there's a small chance for chicks to spawn from eggs. If you want more chicken don't remove them",
		action1 = {
			msg="Oh thanks, good to know",
			next_state="quest_completed"
		}
	}
}

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
local mobf_tutorial_6 = {
	quests_required = { "mobf_tutorial_5"},
	repeatable = false,
	title="Breeding big animals",
	init_state = {
		text = "Ok let's continue breeding bigger animals. Sheep for example"..
				"\nYou should build a stable once again and put some sheep in it." ..
				"\nFor sheep you need a bigger barn, see the recipe to the left and fill it with leaves once again." ..
				"To complete this quest breed at least 2 lambs. If you want to do this faster craft more barns.",
		action1 =  { 
					action_available_fct=nil, 
					msg="Great I'm gonna start immediatly", 
					next_state="wait_for_breeding_done"
					},
		action2 =  { msg="No thank's" },
		recipe = {
			{ "", "", "" },
			{ "default:stick", "default:stick", "default:stick"},
			{ "default:wood", "default:wood", "default:wood"}
		}
	},
	
	wait_for_breeding_done = {
		text = "it's always a pleasure to see you.\n" ..
				"Did you breed 2 lambs by now?",
		
		action1 = {
			events_required = {
				{ type="event_breed", mobtype1="animal_sheep:sheep", count=2 }, 
				{ type="event_craft", item="barn:barn_empty", count=1 }
			},
			next_state="quest_completed",
			msg="Yes there are 2 tiny lambs."
			},
		action2 = {
			msg="Not yet, I'm still working on it."
			},
		recipe = {
			{ "", "", "" },
			{ "default:stick", "default:stick", "default:stick"},
			{ "default:wood", "default:wood", "default:wood"}
		}
	},
}

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
local mobf_tutorial_7 = {
	quests_required = { "mobf_tutorial_6"},
	repeatable = false,
	title="Milking",
	init_state = {
		text = "As you're now more familiar to bigger animals let's try to get some milk.\n" ..
				"In order to get milk from cows get some glasses and punch a cow with them.\n" ..
				"Be carefull don't try this with bulls ;-).\n" .. 
				"And of course you'll have to wait a little bit after milking a cow." .. 
				"Get back to me once you gained 10 glasses of milk.",
		action1 =  { 
					action_available_fct=nil, 
					msg="Ok I'm gonna do some milking", 
					next_state="wait_for_milk"
					},
		action2 =  { msg="No thank's I don't like milk" },
	},
	
	wait_for_milk = {
		text = "Do you have 10 glasses of milk from miliking cows?",
		
		action1 = {
			events_required = {
				{ type="event_harvest", count=10, mobtype="animal_cow:cow", msg="Another glass of milk harvested"}
			},
			next_state="quest_completed",
			msg="Yes milk tasts great!"
			},
		action2 = {
			msg="Not yet, I'm still working on it."
			},
	},
}

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
local mobf_tutorial_8 = {
	quests_required = { "mobf_tutorial_7"},
	repeatable = false,
	title="Catching wolfes",
	init_state = {
		text = "you did very well by now. Let's start with really difficult tasks.\n" ..
				"There are some animals you need a net for to catch. Quite obvious a net is helpfull for fish.\n" ..
				"But that's not what we're gonna learn here. You can use a net for catching and taming a wolf too.\n\n" ..
				"Wolfes are quite rare you'll have to look for a while to find one. But be carefull they do attack!\n\n" ..
				"Craft two nets and catch a wolf in order to complet this quest.",
		action1 =  { 
					action_available_fct=nil, 
					msg="Ok I'm gonna go taming now", 
					next_state="wait_tamed_wolf"
					},
		action2 =  { msg="No thank's, sounds way to dangerous." },
		recipe = {
			{"wool:white",'',"wool:white"},
			{'', "wool:white",''},
			{"wool:white",'',"wool:white"},
		}
	},
	
	wait_tamed_wolf = {
		text = "Did you craft two nets and catch a wolf by now?",
		
		action1 = {
			events_required = {
				{ type="event_cought", count=1, mobtype="animal_wolf:wolf", msg="Tamed a wolf!"},
				{ type="event_craft", count=2, item="animalmaterials:net", msg="Net crafted"}
			},
			next_state="quest_completed",
			msg="That's been a challenge but I did master it!"
			},
		action2 = {
			msg="Not yet, I'm still looking for a wolf."
			},
		recipe = {
			{"wool:white",'',"wool:white"},
			{'', "wool:white",''},
			{"wool:white",'',"wool:white"},
		}
	},
}

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
local mobf_tutorial_9 = {
	quests_required = { "mobf_tutorial_8"},
	repeatable = false,
	title="Hunting",
	init_state = {
		text = "you're doing very well. Let's do the more robust things, get out there and kill at least 10 deer.",
		action1 =  { 
					action_available_fct=nil, 
					msg="Ok I'm gonna go hunting deer now", 
					next_state="wait_deer_killed"
					},
		action2 =  { msg="No I don't wanna kill deer." },
	},
	
	wait_deer_killed = {
		text = "Did you find your 10 deer by now?",
		
		action1 = {
			events_required = {
				{ type="event_killed", count=10, mobtype="animal_deer*", msg="Another deer hunted"},
			},
			next_state="quest_completed",
			msg="Yes hunting is fun!"
			},
		action2 = {
			msg="Not yet, I'm still looking for deer."
			},
	},
}

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
local mobf_tutorial_10 = {
	quests_required = { "mobf_tutorial_9"},
	repeatable = false,
	title="Patroling",
	init_state = {
		text = "ok, fighting is fun but wouldn't you like to do this for you?\n" ..
				"Thought so too, find a trader and buy a guard contract.\n" ..
				"Be warned hireing personal ain't cheap! You'll gonna need some mese.\n\n" ..
				"Once you have the contract come back for further instructions",
		action1 =  { 
					msg="Ok let's hire some fighters", 
					next_state="wait_for_contract"
					},
		action2 =  { msg="No I don't have enough mese by now." },
	},
	
	wait_for_contract = {
		text = "Do you have a guard contract in your inventory?",
		
		action1 = {
			action_available_fct=function(entity,player)
				if player:get_inventory():contains_item("main","mob_guard:guard 1") then
					return true
				end
				return false
			end,
			next_state="guard_instructions",
			msg="Yes I have it!"
			},
		action2 = {
			msg="Not yet, I'm still saving mese."
			},
	},
	guard_instructions = {
		text = "You can use the contract to place your guard. Same as you sapwn cought mobs." ..
				"If you want to get your guard back to inventory an place it somewhere else you'll have to craft a contract.\n\n" ..
				"Let's practice place your guard and get it back by using a contract.",
		action1 = {
			events_required = {
				{ type="event_cought", count=1, mobtype="mob_guard:guard", msg="got guard"},
			},
			next_state="quard_fighting",
			msg="Ok I now how to place and fetch my guard what's next?"
			},
		action2 = {
			msg="Not yet."
			},
		recipe = {
			{"default:paper"},
			{"default:paper"},
		}
	},
	quard_fighting = {
		text = "Ok you know how to move your guard now some fighting basics." ..
				"Your guard will attack any hostile mobs or any other player you didn't add to your faction.\n" ..
				"Factions is topic of another lesson so don't bother about it now.\n" ..
				"Let's try out your guart place it somewhere wher vombies spawn at night. Make sure it's not to bright nearby." ..
				"If you're interested hide somwhere at a safe place nearby and wait for next night.\n\n" ..
				"Come back to me once your guard killed at least 3 vombies.\n" ..
				"Good luck!",
		action1 = {
			events_required = {
				{ type="event_killed", count=3, mobtype="mob_guard:vombie", msg="got guard"},
			},
			next_state="guard_patroling",
			msg="Good to see how my guard is fighting!"
			},
		action2 = {
			msg="No he didn't attack enough vombies by now."
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
quest_engine.register_quest("mobf_tutorial_6", mobf_tutorial_6)
quest_engine.register_quest("mobf_tutorial_7", mobf_tutorial_7)
quest_engine.register_quest("mobf_tutorial_8", mobf_tutorial_8)
quest_engine.register_quest("mobf_tutorial_9", mobf_tutorial_9)
quest_engine.register_quest("mobf_tutorial_10", mobf_tutorial_10)