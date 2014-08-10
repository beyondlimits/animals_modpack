---------------------------------------------------------
--Cooking Support, added by Mr Elmux
-- You may use modify or do nearly anything except removing this Copyright hint
-----------------------------------------------------------

minetest.register_craftitem("cooking:meat_cooked", {
	description = "Cooked Meat",
	image = "cooking_cooked_meat.png",
	on_use = minetest.item_eat(6),
	groups = { meat=1 , eatable=1},
	stack_max = 25
})
minetest.register_craftitem("cooking:meat_pork_cooked", {
	description = "Cooked Pork Meat",
	image = "cooking_cooked_meat.png",
	on_use = minetest.item_eat(6),
	groups = { meat=1 , eatable=1},
	stack_max = 25
})
minetest.register_craftitem("cooking:meat_chicken_cooked", {
	description = "Cooked Chicken",
	image = "cooking_cooked_meat.png",
	on_use = minetest.item_eat(6),
	groups = { meat=1 , eatable=1},
	stack_max = 25
})
minetest.register_craftitem("cooking:meat_beef_cooked", {
	description = "Cooked Beef",
	image = "cooking_cooked_meat.png",
	on_use = minetest.item_eat(6),
	groups = { meat=1 , eatable=1},
	stack_max = 25
})
minetest.register_craftitem("cooking:meat_undead_cooked", {
	description = "Cooked Meat (Now Dead)",
	image = "cooking_cooked_meat.png",
	on_use = minetest.item_eat(-2),
	groups = { meat=1 , eatable=1},
	stack_max = 25
})minetest.register_craftitem("cooking:meat_venison_cooked", {
	description = "Cooked Venison Meat",
	image = "cooking_cooked_meat.png",
	on_use = minetest.item_eat(6),
	groups = { meat=1 , eatable=1},
	stack_max = 25
})minetest.register_craftitem("cooking:meat_toxic_cooked", {
	description = "Cooked Toxic Meat",
	image = "cooking_cooked_meat.png",
	on_use = minetest.item_eat(-5),
	groups = { meat=1 , eatable=1},
	stack_max = 25
})
minetest.register_craftitem("cooking:fish_bluewhite_cooked", {
	description = "Cooked Bluewhite Meat",
	image = "cooking_cooked_meat.png",
	on_use = minetest.item_eat(6),
	groups = { meat=1 , eatable=1},
	stack_max = 25
})
minetest.register_craftitem("cooking:fish_clownfish_cooked", {
	description = "Cooked Meat",
	image = "cooking_cooked_meat.png",
	on_use = minetest.item_eat(6),
	groups = { meat=1 , eatable=1},
	stack_max = 25
})
minetest.register_craft({
	type= "cooking",
	recipe = "animalmaterials:meat_raw",
	output = "cooking:meat_cooked",
})
minetest.register_craft({
	type= "cooking",
	recipe = "animalmaterials:meat_pork",
	output = "cooking:meat_pork_cooked",
})
minetest.register_craft({
	type= "cooking",
	recipe = "animalmaterials:meat_chicken",
	output = "cooking:meat_chicken_cooked",
})
minetest.register_craft({
	type= "cooking",
	recipe = "animalmaterials:meat_beef",
	output = "cooking:meat_beef_cooked",
})

minetest.register_craft({
	type= "cooking",
	recipe = "animalmaterials:meat_undead",
	output = "cooking:meat_undead_cooked",
})
minetest.register_craft({
	type= "cooking",
	recipe = "animalmaterials:meat_venison",
	output = "cooking:meat_venison_cooked",
})
minetest.register_craft({
	type= "cooking",
	recipe = "animalmaterials:meat_toxic",
	output = "cooking:meat_toxic_cooked",
})
minetest.register_craft({
	type= "cooking",
	recipe = "animalmaterials:fish_bluewhite",
	output = "cooking:fish_bluewhite_cooked",
})
minetest.register_craft({
	type= "cooking",
	recipe = "animalmaterials:fish_clownfish",
	output = "cooking:fish_clownfish_cooked",
})
