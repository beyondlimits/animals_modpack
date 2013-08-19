-------------------------------------------------------------------------------
-- Mob Framework Settings Mod by Sapier
-- 
-- You may copy, use, modify or do nearly anything except removing this
-- copyright notice. 
-- And of course you are NOT allowed to pretend you have written it.
--
--! @file init.lua
--! @brief settings gui for mobf
--! @copyright Sapier
--! @author Sapier
--! @date 2013-05-20
--
-- Contact sapier a t gmx net
-------------------------------------------------------------------------------
minetest.log("action","MOD: mobf_settings mod loading ... ")

mobf_settings = {}
mobf_settings.tabs = {}
mobf_settings.version = "0.9.0"
mobf_settings.formname = "mobf_settings"

local COLOR_RED   = "#FF0000"
local COLOR_GREEN = "#00FF00"

------------------------------------------------------------------------------
-- name: contains
--
--! @brief check if element is in table
--! @ingroup mobf_settings
--
--! @param cur_table table to check for element
--! @param element element to find in table
--!
--! @return true/false
-------------------------------------------------------------------------------
function contains(cur_table,element)

	if cur_table == nil then
		--print("looking in empty table")
		return false
	end
	
	--print("looking for " .. dump(element) .. " in " .. dump(cur_table))
	
	for i,v in ipairs(cur_table) do
		if v == element then
			--print("found: " .. element .. " in table")
			return true
		end
	end
	
	--print("didn't find " .. element)
	return false
end

------------------------------------------------------------------------------
-- name: explode_textlist_event
--
--! @brief fetch data from textlist event
--! @ingroup mobf_settings
--
--! @param text data to parse
--!
--! @return textlist event
-------------------------------------------------------------------------------
function explode_textlist_event(text)
	
	local retval = {}
	retval.typ = "INV"
	
	local parts = text:split(":")
				
	if #parts == 2 then
		retval.typ = parts[1]:trim()
		retval.index= tonumber(parts[2]:trim())
		
		if type(retval.index) ~= "number" then
			retval.typ = "INV"
		end
	end
	
	return retval
end

------------------------------------------------------------------------------
-- name: handle_event
--
--! @brief do actions according to event
--! @ingroup mobf_settings
--
--! @param player issuing the formspec
--! @param formname form to be shown
--! @param fields event information
--!
--! @return true/false handled or not
-------------------------------------------------------------------------------
function mobf_settings.handle_event(player,formname,fields)
	--print("event handler: form: " .. formname)
	--print("fields: " .. dump(fields))
	if formname ~= mobf_settings.formname then
		return false
	end
	
	local sender_data = mobf_settings.get_sender_data(fields)
	
	if sender_data ~= nil and sender_data.name == "maintab" then
		sender_data.tab = tonumber(sender_data.value)
	end
	
	if sender_data ~= nil then
		sender_data.player = player
		sender_data.formname = formname
		sender_data.fields = fields
		
		--check admin privs
		sender_data.is_admin = true
		
		--print("event handler: tab: #" .. dump(sender_data.tab) .. " btn: " .. dump(sender_data.name)) 
	
		if sender_data.tab <= #mobf_settings.tabs then
			--make sure no admin tab is shown to non admin users
			if mobf_settings.tabs[sender_data.tab].admin then
				if not sender_data.is_admin then
					local fixed = false
					for i=1,#mobf_settings.tabs,1 do
						if not mobf_settings.tabs[i].admin then
							sender_data.tab = i
							sender_data.name = "ukn"
							sender_data.fields = {}
							sender_data.type = "ukn"
							fixed = true
						end
					end
					
					if not fixed then
						return
					end
				end
			end
			
			--print("showing tab: #" .. sender_data.tab .. " " .. dump(mobf_settings.tabs[sender_data.tab]))
			mobf_settings.tabs[sender_data.tab].handler(sender_data)
		end

	end
	return true
end

------------------------------------------------------------------------------
-- name: get_sender_data
--
--! @brief find caller of formspec
--! @ingroup mobf_settings
--
--! @param fields to look for sender
--!
--! @return sender information
-------------------------------------------------------------------------------
function mobf_settings.get_sender_data(fields)
	for key,value in pairs(fields) do
		local parts = key:split("_")
		
		if #parts >= 3 then
			if parts[1] == "btn" or
				parts[1] == "cb" or
				parts[1] == "tl" or
				parts[1] == "th" then
				
				local name = ""
				for i=3, #parts,1 do
					if name ~= "" then
						name = name .. "_"
					end
					name = name .. parts[i]
				end
				
				return {
					type = parts[1],
					tab = tonumber(parts[2]),
					name = name,
					value = value
				}
			end
		end
	end
	return nil
end

------------------------------------------------------------------------------
-- name: handle_statistics_tab
--
--! @brief handle events from main tab
--! @ingroup mobf_settings
--
--! @param sender_data all information gatered
--!
--! @return sender information
-------------------------------------------------------------------------------
function mobf_settings.handle_statistics_tab(sender_data)

	mobf_settings.show_statistics_tab(sender_data)

end

------------------------------------------------------------------------------
-- name: handle_main_tab
--
--! @brief handle events from main tab
--! @ingroup mobf_settings
--
--! @param sender_data all information gatered
--!
--! @return sender information
-------------------------------------------------------------------------------
function mobf_settings.handle_main_tab(sender_data)
	--check player privs
	if sender_data.is_admin then
		
		mobf_settings.handle_main_tab_input(sender_data)
		
		mobf_settings.show_main_tab(sender_data)
	else
		
	end
end

------------------------------------------------------------------------------
-- name: handle_settings_tab
--
--! @brief handle events from main tab
--! @ingroup mobf_settings
--
--! @param sender_data all information gatered
--!
--! @return sender information
-------------------------------------------------------------------------------
function mobf_settings.handle_settings_tab(sender_data)
	--check player privs
	if sender_data.is_admin then
		
		mobf_settings.handle_settings_tab_input(sender_data)
		
		mobf_settings.show_settings_tab(sender_data)
	else
		
	end
end

------------------------------------------------------------------------------
-- name: handle_main_tab
--
--! @brief handle events from main tab
--! @ingroup mobf_settings
--
--! @param sender_data all information gatered
--!
--! @return sender information
-------------------------------------------------------------------------------
function mobf_settings.handle_tools_tab(sender_data)
	if mobf_settings.handle_tools_tab_input(sender_data) then
		mobf_settings.show_tools_tab(sender_data)
	end
end


------------------------------------------------------------------------------
-- name: show_main_tab
--
--! @brief update formspec to main tab
--! @ingroup mobf_settings
--
--! @param sender_data all information gatered
-------------------------------------------------------------------------------
function mobf_settings.show_main_tab(sender_data)
	local formspec = mobf_settings.formspec_header(sender_data)
	
	formspec = formspec .. "label[0.5,0;Mobs:]"
	formspec = formspec .. "textlist[0.5,0.5;7,8;tl_" .. sender_data.tab .. "_mobs;"
	
	local mobf_mob_blacklist_string = minetest.world_setting_get("mobf_blacklist")
	local mobf_mobs_blacklisted = nil
	if mobf_mob_blacklist_string ~= nil then
		mobf_mobs_blacklisted = minetest.deserialize(mobf_mob_blacklist_string)
	end
	
	
	local toadd = ""
	
	for i,val in ipairs(mobf_rtd.registred_mob) do
		if toadd ~= "" then
			toadd = toadd .. ","
		end
		if contains(mobf_mobs_blacklisted,val) then
			toadd = toadd .. COLOR_RED .. val
		else
			toadd = toadd .. COLOR_GREEN .. val
		end	
	end
	
	formspec = formspec .. toadd .. ";0]"
	
	if formspec ~= nil then
		minetest.show_formspec(sender_data.player:get_player_name(),
							sender_data.formname,
							formspec)
	end
end

------------------------------------------------------------------------------
-- name: show_tools_tab
--
--! @brief update formspec to tools tab
--! @ingroup mobf_settings
--
--! @param sender_data all information gatered
-------------------------------------------------------------------------------
function mobf_settings.show_tools_tab(sender_data)
	local formspec = mobf_settings.formspec_header(sender_data)
	
	formspec = formspec .. 
		"button[1.5,1;4,0.5;btn_" .. sender_data.tab .. "_pathmaker_tool;Give pathmarker tool]" ..
		"button[1.5,1.75;4,0.5;btn_" .. sender_data.tab .. "_preserved_mobs;Show preserved mobs gui]" ..
		"button[1.5,2.5;4,0.5;btn_" .. sender_data.tab .. "_path_manager;Show path manager]"
	
	if formspec ~= nil then
		minetest.show_formspec(sender_data.player:get_player_name(),
							sender_data.formname,
							formspec)
	end
end

------------------------------------------------------------------------------
-- name: show_statistics_tab
--
--! @brief update formspec to tools tab
--! @ingroup mobf_settings
--
--! @param sender_data all information gatered
-------------------------------------------------------------------------------
function mobf_settings.show_statistics_tab(sender_data)
	local formspec = mobf_settings.formspec_header(sender_data)
	
	local printfac = function(name,data,yval,fs)
		return 
			"label[0.75," .. yval .. ";" .. mobf_fixed_size_string(name,20) .. "]" ..
			"label[2.75," .. yval .. ";" .. 
				mobf_fixed_size_string(string.format(fs,data.current),10).. "]" ..
			"label[4.25," .. yval .. ";" .. 
				mobf_fixed_size_string(data.maxabs,10).. "]" ..
			"label[6," .. yval .. ";" .. 
				mobf_fixed_size_string(string.format(fs,data.max),10).. "]"

	end
	
	formspec = formspec ..
		"label[0.75,0.5;Info:]" ..
		"label[0.75,0.75;--------------------------------------------------]" ..
		"label[0.75,1.25;Timesource:]" ..
		"label[2.75,1.25;" .. mobf_fixed_size_string(mobf_rtd.timesource,30) .. "]" ..
		printfac("Active Mobs",statistics.data.mobs,"1.75","%6d") ..
		printfac("Jobqueue",statistics.data.queue,"2.25","%6d") ..
		"label[0.75,3;"	.. mobf_fixed_size_string("Facility",20)
						.. mobf_fixed_size_string("Current",10)
						.. mobf_fixed_size_string("Abs.Max",10)
						.. mobf_fixed_size_string("Maximum",10) .. "]" ..
		"label[0.75,3.25;--------------------------------------------------]" ..
		printfac("Total",statistics.data.total,"3.75","%.2f%%") ..
		printfac("Onstep",statistics.data.onstep,"4.25","%.2f%%") ..
		printfac("Punch",statistics.data.punch,"4.75","%.2f%%") ..
		printfac("ABM",statistics.data.abm,"5.25","%.2f%%") ..
		printfac("MapGen",statistics.data.mapgen,"5.75","%.2f%%") ..
		printfac("Spawn onstep",statistics.data.spawn_onstep,"6.25","%.2f%%") ..
		printfac("Activate",statistics.data.activate,"6.75","%.2f%%") ..
		printfac("User 1",statistics.data.user_1,"7.5","%.2f%%") ..
		printfac("User 2",statistics.data.user_2,"8","%.2f%%") ..
		printfac("User 3",statistics.data.user_3,"8.5","%.2f%%")

	if formspec ~= nil then
		minetest.show_formspec(sender_data.player:get_player_name(),
							sender_data.formname,
							formspec)
	end
end
------------------------------------------------------------------------------
-- name: show_settings_tab
--
--! @brief update formspec to settings tab
--! @ingroup mobf_settings
--
--! @param sender_data all information gatered
-------------------------------------------------------------------------------
function mobf_settings.show_settings_tab(sender_data)
	local formspec = mobf_settings.formspec_header(sender_data)
	
	formspec = formspec .. "checkbox[1,0.5;" .. 
				"cb_" .. sender_data.tab .. "_disable_animal_spawning;" ..
				"Disable mob spawning;" .. 
				mobf_settings.setting_gettext("mobf_disable_animal_spawning") .."]"
				
	formspec = formspec .. "checkbox[1,1;" .. 
				"cb_" .. sender_data.tab .. "_disable_3d_mode;" ..
				"Disable 3D mobs;" .. 
				mobf_settings.setting_gettext("mobf_disable_3d_mode") .."]"
				
	formspec = formspec .. "checkbox[1,1.5;" .. 
				"cb_" .. sender_data.tab .. "_animal_spawning_secondary;" ..
				"Enable secondary spawning;" .. 
				mobf_settings.setting_gettext("mobf_animal_spawning_secondary") .."]"
				
	formspec = formspec .. "checkbox[1,2;" .. 
				"cb_" .. sender_data.tab .. "_delete_disabled_mobs;" ..
				"Delete disabled mobs+spawners;" .. 
				mobf_settings.setting_gettext("mobf_delete_disabled_mobs") .."]"
				
	formspec = formspec .. "checkbox[1,2.5;" .. 
				"cb_" .. sender_data.tab .. "_log_bug_warnings;" ..
				"Log MOBF bug warnings;" .. 
				mobf_settings.setting_gettext("mobf_log_bug_warnings") .."]"
				
	formspec = formspec .. "checkbox[1,3;" .. 
				"cb_" .. sender_data.tab .. "_vombie_3d_burn_animation_enabled;" ..
				"Vombie 3D burn animation;" .. 
				mobf_settings.setting_gettext("vombie_3d_burn_animation_enabled") .."]"
				
	formspec = formspec .. "checkbox[1,3.5;" .. 
				"cb_" .. sender_data.tab .. "_log_removed_entities;" ..
				"Log all removed mobs;" .. 
				mobf_settings.setting_gettext("mobf_log_removed_entities") .."]"
				
	formspec = formspec .. "checkbox[1,4;" .. 
				"cb_" .. sender_data.tab .. "_grief_protection;" ..
				"Enable grief protection;" .. 
				mobf_settings.setting_gettext("mobf_grief_protection") .."]"
				
	formspec = formspec .. "checkbox[1,4.5;" .. 
				"cb_" .. sender_data.tab .. "_lifebar;" ..
				"Show mob lifebar;" .. 
				mobf_settings.setting_gettext("mobf_lifebar") .."]"
				
	formspec = formspec .. "checkbox[1,5;" .. 
				"cb_" .. sender_data.tab .. "_enable_statistics;" ..
				"Enable statistics;" .. 
				mobf_settings.setting_gettext("mobf_enable_statistics") .."]"
	formspec = formspec .. "checkbox[1,5.5;" .. 
				"cb_" .. sender_data.tab .. "_delayed_spawning;" ..
				"Delay spawning at mapgen;" .. 
				mobf_settings.setting_gettext("mobf_delayed_spawning") .."]"
	--print("formspec: " .. formspec)
	if formspec ~= nil then
		minetest.show_formspec(sender_data.player:get_player_name(),
							sender_data.formname,
							formspec)
	end
end

------------------------------------------------------------------------------
-- name: handle_tools_tab_input
--
--! @brief handle input from tools tab
--! @ingroup mobf_settings
--
--! @param sender_data all information gatered
-------------------------------------------------------------------------------
function mobf_settings.handle_tools_tab_input(sender_data)

	if sender_data.name == "pathmaker_tool" then
		sender_data.player:get_inventory():add_item("main", "mobf:path_marker 1")
	end
	
	local name = sender_data.player:get_player_name()
	
	if sender_data.name == "preserved_mobs" then
		mob_preserve.handle_command(name,nil)
		return false
	end
	
	if sender_data.name == "path_manager" then
		mobf_path.show_manage_menu(name,nil)
		return false
	end

	return true
end

------------------------------------------------------------------------------
-- name: handle_main_tab_input
--
--! @brief handle input from main tab
--! @ingroup mobf_settings
--
--! @param sender_data all information gatered
-------------------------------------------------------------------------------
function mobf_settings.handle_main_tab_input(sender_data)
	
	if sender_data.name == "mobs" then
		local tl_event = explode_textlist_event(sender_data.value)
		if tl_event.typ == "DCL" and
			tl_event.index < #mobf_rtd.registred_mob then
			local clicked_mob = mobf_rtd.registred_mob[tl_event.index]
		
			local mobf_mob_blacklist_string = minetest.world_setting_get("mobf_blacklist")
			local mobf_mobs_blacklisted = nil
			if mobf_mob_blacklist_string ~= nil then
				mobf_mobs_blacklisted = minetest.deserialize(mobf_mob_blacklist_string)
			else
				mobf_mobs_blacklisted = {}
			end
			
			local new_blacklist = {}
			
			if contains(mobf_mobs_blacklisted,clicked_mob) then
				for i=1,#mobf_mobs_blacklisted,1 do
					if mobf_mobs_blacklisted[i] ~= clicked_mob then
						table.insert(new_blacklist,mobf_mobs_blacklisted[i])
					end
				end
			else
				new_blacklist = mobf_mobs_blacklisted
				table.insert(mobf_mobs_blacklisted,clicked_mob)
			end
			
			minetest.world_setting_set("mobf_blacklist",minetest.serialize(new_blacklist))
		end
	end
end

------------------------------------------------------------------------------
-- name: handle_settings_tab_input
--
--! @brief handle input from settings tab
--! @ingroup mobf_settings
--
--! @param sender_data all information gatered
-------------------------------------------------------------------------------
function mobf_settings.handle_settings_tab_input(sender_data)
	print("settings tab handler " .. dump(sender_data))
	if sender_data.name == "disable_animal_spawning" then
		mobf_set_world_setting("mobf_disable_animal_spawning",
								mobf_settings.tobool(sender_data.value))
	end
	
	if sender_data.name == "disable_3d_mode" then
		mobf_set_world_setting("mobf_disable_3d_mode",
								mobf_settings.tobool(sender_data.value))
	end
	
	if sender_data.name == "animal_spawning_secondary" then
		mobf_set_world_setting("mobf_animal_spawning_secondary",
								mobf_settings.tobool(sender_data.value))
	end
	
	if sender_data.name == "delete_disabled_mobs" then
		mobf_set_world_setting("mobf_delete_disabled_mobs",
								mobf_settings.tobool(sender_data.value))
	end
	
	if sender_data.name == "log_bug_warnings" then
		mobf_set_world_setting("mobf_log_bug_warnings",
								mobf_settings.tobool(sender_data.value))
	end

	if sender_data.name == "log_removed_entities" then
		mobf_set_world_setting("mobf_log_removed_entities",
								mobf_settings.tobool(sender_data.value))
	end
	
	if sender_data.name == "grief_protection" then
		mobf_set_world_setting("mobf_grief_protection",
								mobf_settings.tobool(sender_data.value))
	end
	
	if sender_data.name == "lifebar" then
		mobf_set_world_setting("mobf_lifebar",
								mobf_settings.tobool(sender_data.value))
	end
	
	if sender_data.name == "enable_statistics" then
		mobf_set_world_setting("mobf_enable_statistics",
								mobf_settings.tobool(sender_data.value))
	end
	
	if sender_data.name == "delayed_spawning" then
		mobf_set_world_setting("mobf_delayed_spawning",
								mobf_settings.tobool(sender_data.value))
	end
end

------------------------------------------------------------------------------
-- name: tobool(value)
--
--! @brief convert string to bool value
--! @ingroup mobf_settings
--
--! @param value string
-------------------------------------------------------------------------------
function mobf_settings.tobool(value)
	if value == "true" then
		return true
	else
		return false
	end
end

------------------------------------------------------------------------------
-- name: setting_getbool(name)
--
--! @brief convert string to bool value
--! @ingroup mobf_settings
--
--! @param value string
-------------------------------------------------------------------------------
function mobf_settings.setting_gettext(value)
	
	local value = mobf_get_world_setting(value)
	
	if value == nil then
		return "false"
	end
	
	if value then
		return "true"
	end
	
	return "false"
end

------------------------------------------------------------------------------
-- name: formspec_header
--
--! @brief handle input from settings tab
--! @ingroup mobf_settings
--
--! @param sender_data all information gatered
-------------------------------------------------------------------------------
function mobf_settings.formspec_header(sender_data)
	local retval = "size[8,9]" ..
				"label[-0.25,8.98;MOBF version: " ..mobf_get_version().."]" ..
				"tabheader[-0.3,-0.99;th_" .. sender_data.tab .. "_maintab;"

	local toadd = ""
	
	for i=1,#mobf_settings.tabs,1 do
		if mobf_settings.tabs[i].admin then
			if sender_data.is_admin then
				if toadd ~= "" then
					toadd = toadd .. ","
				end
				toadd = toadd .. mobf_settings.tabs[i].caption
			end
		else
			if toadd ~= "" then
				toadd = toadd .. ","
			end
			toadd = toadd .. mobf_settings.tabs[i].caption
		end
	end
	
	retval = retval .. toadd .. ";" .. sender_data.tab .. ";true;false]"
	
	return retval
end

------------------------------------------------------------------------------
-- name: register_tab(caption,adminrequired,tabhandler)
--
--! @brief handle input from settings tab
--! @ingroup mobf_settings
--
--! @param caption of tab button
--! @param adminrequired should this tab be shown to admin only?
--! @param tabhandler function called to handle this tab
-------------------------------------------------------------------------------
function mobf_settings.register_tab(caption,adminrequired,tabhandler)

	local tab_to_add = {
				admin = adminrequired,
				handler = tabhandler,
				caption = caption
			}
	table.insert(mobf_settings.tabs,tab_to_add)
end


mobf_settings.register_tab("Known Mobs",true, mobf_settings.handle_main_tab)
mobf_settings.register_tab("Settings",  true, mobf_settings.handle_settings_tab)
mobf_settings.register_tab("Tools",     false,mobf_settings.handle_tools_tab)

if minetest.world_setting_get("mobf_enable_statistics") then
	mobf_settings.register_tab("Statistics",     false,mobf_settings.handle_statistics_tab)
end

------------------------------------------------------------------------------
-- register handler for pressed buttons
------------------------------------------------------------------------------
minetest.register_on_player_receive_fields(mobf_settings.handle_event)

--register chatcommand
minetest.register_chatcommand("mobf_settings",
	{
		params		= "",
		description = "show mobf settings" ,
		privs		= {},
		func		= function(name,param)
				minetest.chat_send_player(name, "MOBF: >mobf_settings< is DEPRECATED use >mobf<")
				local player = minetest.get_player_by_name(name)
				mobf_settings.handle_event(player,mobf_settings.formname,{btn_1_init="init"})
			end
	})
--"mobf_settings" will be removed
minetest.register_chatcommand("mobf",
	{
		params		= "",
		description = "show mobf settings" ,
		privs		= {},
		func		= function(name,param)
				local player = minetest.get_player_by_name(name)
				mobf_settings.handle_event(player,mobf_settings.formname,{btn_1_init="init"})
			end
	})
minetest.log("action","MOD: mobf_settings mod           version "..mobf_settings.version.." loaded")