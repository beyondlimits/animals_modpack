-------------------------------------------------------------------------------
-- Mob Framework Mod by Sapier
-- 
-- You may copy, use, modify or do nearly anything except removing this
-- copyright notice. 
-- And of course you are NOT allow to pretend you have written it.
--
--! @file factions.lua
--! @brief contains factions adaption of mobf
--! @copyright Sapier
--! @author Sapier
--! @date 2013-08-21
--!
-- Contact sapier a t gmx net
-------------------------------------------------------------------------------

mobf_assert_backtrace(mobf_factions == nil)
mobf_factions = {}


-------------------------------------------------------------------------------
-- name: init()
--
--! @brief initialize mobf factions support
--! @memberof mobf_factions
--
-------------------------------------------------------------------------------
function mobf_factions.init()
	if  minetest.get_modpath("factions")then
		mobf_rtd.factions_available = true
	end
	
	--need to catch my form events
	minetest.register_on_player_receive_fields(mobf_factions.button_handler)
end


-------------------------------------------------------------------------------
-- name: setupmob(factionsdata)
--
--! @brief creat factions a mob may be member of
--! @memberof mobf_factions
--
--! @param factions data of mob
--
-------------------------------------------------------------------------------
function mobf_factions.setupmob(factionsdata)
	if mobf_rtd.factions_available and factionsdata ~= nil and
		factionsdata.member ~= nil then
		
		for i=1,#factionsdata.member,1 do
			if not factions.exists(factionsdata.member[i]) then
				factions.add_faction(factionsdata.member[i])
			end
		end
	end
end

-------------------------------------------------------------------------------
-- name: setupentity(entity)
--
--! @brief add a mob to it's factons
--! @memberof mobf_factions
--
--! @param entity to be added to it's factions
--
-------------------------------------------------------------------------------
function mobf_factions.setupentity(entity)
	if mobf_rtd.factions_available and entity.data.factions ~= nil and
		entity.data.factions.member ~= nil then
		
		for i=1,#entity.data.factions.member,1 do
			factions.member_add(entity.data.factions.member[i],entity)
		end
	end
end


-------------------------------------------------------------------------------
-- name: mob_rightclick_callback(entity,player)
--
--! @brief show factions rightclick menu
--! @memberof mobf_factions
--
--! @param entity to modify
--! @param player issuing rightclick
--
-------------------------------------------------------------------------------
function mobf_factions.mob_rightclick_callback(entity,player)
	local menu_data = {}
	
	local new_id = mobf_global_data_store(menu_data)
	
	menu_data.entity = entity
	menu_data.player = player
	
	mobf_factions.show_mob_factions_menu(new_id,menu_data)
end


-------------------------------------------------------------------------------
-- name: mob_rightclick_callback(entity,player)
--
--! @brief show factions rightclick menu
--! @memberof mobf_factions
--
--! @param entity clicked
--
-------------------------------------------------------------------------------
function mobf_factions.config_check(entity)
	if entity.dynamic_data.spawning.spawner ~= nil then
		return true
	end
	return false
end

-------------------------------------------------------------------------------
-- name: button_handler(entity,player)
--
--! @brief show factions rightclick menu
--! @memberof mobf_factions
--
--! @param entity to modify
--! @param player issuing rightclick
--
-------------------------------------------------------------------------------
function mobf_factions.button_handler(player, formname, fields)
	local playername = player:get_player_name()
	
	mobf_assert_backtrace(playername ~= nil)
	
	if formname == "mobf:factions:main_menu" then
		dbg_mobf.path_lvl2("MOBF: factions menu opened")
		for k,v in pairs(fields) do
			local parts = string.split(k,":")
			
			if parts[1] == "mobf_factions" then
				
				local menu_data = mobf_factions.handle_rightclick(parts,fields,formname,player,k)
				
				if menu_data  ~= nil then
					--push data back to store
					local new_id = mobf_global_data_store(menu_data)
					mobf_factions.show_mob_factions_menu(new_id,menu_data)
					break
				end

			end
		end
		return true
	end
end

-------------------------------------------------------------------------------
-- name: handle_rightclick(current_fields,fields,formname,player,fieldname)
--
--! @brief show factions rightclick menu
--! @memberof mobf_factions
--
--! @param current_fields
--! @param fields
--! @param formname
--! @param player
--! @param fieldname name of field causingt the callback
--
--! @return true/false show menu again
-------------------------------------------------------------------------------
function mobf_factions.handle_rightclick(current_fields,fields,formname,player,fieldname)
	--try to read data from global store
	local menu_data = mobf_global_data_get(current_fields[3])
	if menu_data ~= nil then
		if current_fields[2]  == "btn_set_reputation" then
			local factionlist = factions.get_faction_list()
			if fields["te_reputation"] ~= nil and
				menu_data.selected ~= nil and
				menu_data.selected > 0 and
				menu_data.selected <= #factionlist then
					reputation = factions.get_reputation(factionlist[menu_data.selected],menu_data.entity.object)
					
					local delta = fields["te_reputation"] - reputation
					
					factions.modify_reputation(factionlist[menu_data.selected],menu_data.entity.object,delta)
			end
		elseif current_fields[2] == "tl_selected_faction" then
			local event = explode_textlist_event(fields[fieldname])
			
			if event.typ ~= "INV" then
				menu_data.selected = event.index
			end
		end
	else
		dbg_mobf.path_lvl1("MOBF: factions menu failed to find menu_data")
	end

	return menu_data
end

-------------------------------------------------------------------------------
-- name: show_mob_factions_menu(new_id,menu_data)
--
--! @brief show factions rightclick menu
--! @memberof mobf_factions
--
--! @param new_id
--! @param menu_data
--
--! @return true/false show menu again
-------------------------------------------------------------------------------
function mobf_factions.show_mob_factions_menu(new_id,menu_data)

	mobf_assert_backtrace(menu_data.entity ~= nil)
	mobf_assert_backtrace(menu_data.player ~= nil)
	
	local playername = menu_data.player:get_player_name()
	
	local formspec =  ""
	
	--check if menu creator is owner of the specific mob
	if menu_data.entity.dynamic_data.spawning.spawner == playername then
		formspec = formspec .. "size[4,7.5]"
				.."label[0,-0.25;Factions:]"
				.."textlist[0,0.3;3.7,6;mobf_factions:tl_selected_faction:" .. new_id .. ";"
				
		local factionlist = factions.get_faction_list()
	
		if #factionlist ~= 0 then
			for i=1,#factionlist,1 do
				formspec = formspec .. factionlist[i] .. ","
			end
		else
			formspec = formspec .. "no factions available"
		end
		
		local reputation = ""
		if menu_data.selected == nil then
			menu_data.selected = 0
		end
		if	menu_data.selected > 0 and
			menu_data.selected <= #factionlist then
			reputation = factions.get_reputation(factionlist[menu_data.selected],menu_data.entity.object)
		end
				
		formspec = formspec .. ";" ..menu_data.selected .. ";false]"
				.."label[0,6.4;Reputation:]"
				.."field[2,6.75;2.2,0.5;te_reputation;;" .. reputation .. "]"
				.."button[0,7.25;3.9,0.5;mobf_factions:btn_set_reputation:" .. new_id .. ";Set reputation]"
	else
		formspec = "label[0,0;This is not your mob keep away!]"
	end
	
	--show formspec
	minetest.show_formspec(playername,"mobf:factions:main_menu",formspec)
end