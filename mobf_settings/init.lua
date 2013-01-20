-------------------------------------------------------------------------------
-- Mob Framework Settings Mod by Sapier
-- 
-- You may copy, use, modify or do nearly anything except removing this
-- copyright notice. 
-- And of course you are NOT allow to pretend you have written it.
--
--! @file init.lua
--! @brief settings gui for mobf
--! @copyright Sapier
--! @author Sapier
--! @date 2012-12-27
--
-- Contact sapier a t gmx net
-------------------------------------------------------------------------------

mobf_settings = {}
mobf_settings.version = "0.0.15"
mobf_settings.max_list_page_num = 5
mobf_settings.buttons = {}
mobf_settings.menubutton = "button_exit[11,9.5;2,0.5;main; Exit]"
mobf_settings.formspechandler = function(player,formspec)
			name = player:get_player_name()
			minetest.show_formspec(name,"mobf_settings:mainform",formspec)
		end
		
mobf_settings_debug = function () end
------------------------------------------------------------------------------
-- name: save
--
--! @brief save current config to config file
--! @ingroup mobf_settings
--
-------------------------------------------------------------------------------
function mobf_settings.save()
	if not minetest.is_singleplayer() then
	
		if minetest.settings_save ~= nil then
			minetest.settings_save()
		else
			minetest.log("error","MOBF_SETTINGS: You're running server without " .. 
					"support for saving config file don't expect your settings " ..
					"to survive a reboot!")
		end
	end
	--singleplayer saves automaticaly
end

------------------------------------------------------------------------------
-- name: get_animal_list
--
--! @brief get animal list form element for a page
--! @ingroup mobf_settings
--
--! @param page_number number of page to get list for
--!
--! @return formspec for page
-------------------------------------------------------------------------------
function mobf_settings.get_animal_list(page_number)

    local mobf_mob_blacklist_string = minetest.setting_get("mobf_blacklist")
    local mobf_mobs_blacklisted = nil
    if mobf_mob_blacklist_string ~= nil then
        mobf_mobs_blacklisted = minetest.deserialize(mobf_mob_blacklist_string)
    end

    local retval = ""
    local line = 3

    local start_at = page_number -1

    for i,val in ipairs(mobf_rtd.registred_mob) do
        
        if i > (start_at*16) then
	        if i <= (start_at*16 + 8) then
	            retval = retval .. "label[1.0," .. line .. ";" .. val .. "]"
	            local line_btn = line + 0.25
	            if contains(mobf_mobs_blacklisted,val) then
	               retval = retval .. "button[0.5," .. line_btn .. ";0.5,0.25;page"..page_number.."_enable_" .. val .. "; ]"
	            else
	               retval = retval .. "button[0.5," .. line_btn .. ";0.5,0.25;page"..page_number.."_disable_" .. val .. ";x]"
	            end
	        end
	        
	        if i > (start_at*16 + 8 ) and
	            i <= (start_at*16 + 16) then
	            
	            local temp_line = line - (8*0.75)
	            retval = retval .. "label[7.0," .. temp_line .. ";" .. val .. "]"
	            
	            local line_btn = temp_line +0.25
	            if contains(mobf_mobs_blacklisted,val) then
                   retval = retval .. "button[6.5," .. line_btn .. ";0.5,0.25;page"..page_number.."_enable_" .. val .. "; ]"
                else
                   retval = retval .. "button[6.5," .. line_btn .. ";0.5,0.25;page"..page_number.."_disable_" .. val .. ";x]"
                end
	        end
	        
	        line = line + 0.75
	    end
    end

    return retval
end


------------------------------------------------------------------------------
-- name: contains
--
--! @brief ccheck if element is in table
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
-- name: get_known_animals_form
--
--! @brief create page to be shown
--! @ingroup mobf_settings
--
--! @param page name of page
--!
--! @return formspec of page
-------------------------------------------------------------------------------
function mobf_settings.get_known_animals_form(page)
	local retval = ""
	
	
	for i=0,mobf_settings.max_list_page_num,1 do
		if page == "mobf_list_page" .. i then
			local nextpage = i +1
			local prevpage = i -1
			retval = "label[0.5,2.25;Known Mobs, Page ".. i .. "]"
				.."label[0.5,2.5;-------------------------------------------]"
				.."label[6.5,2.5;----------------------------------------]"
				.. mobf_settings.get_animal_list(i)
			
			if i ~= mobf_settings.max_list_page_num then
				retval = retval .."button[3,9.5;2,0.5;mobf_list_page" .. nextpage ..";Next]"
			end
			if i ~= 1 then
				retval = retval .."button[0.5,9.5;2,0.5;mobf_list_page" .. prevpage ..";Prev]"
			end
			
			return retval
		end
	end
	
	
	
	if page == "mobf_restart_required" then
		retval = "label[0.5,2.25;This settings require to restart Game!]"
			.."label[0.5,2.5;-------------------------------------------]"
			.."label[6.5,2.5;----------------------------------------]"
		
		local y_pos = 3.75
		
		for i=1,#mobf_settings.buttons,1 do
			local current_setting = minetest.setting_getbool(mobf_settings.buttons[i].value)
			
			if mobf_settings.buttons[i].inverted then
				if not current_setting then
					retval = retval .. "button[0.5,".. y_pos .. ";6,0.5;" .. 
					"en_" .. mobf_settings.buttons[i].value .. ";" .. 
					mobf_settings.buttons[i].text .. " is enabled]"
				else
					retval = retval .. "button[0.5,".. y_pos .. ";6,0.5;" .. 
					"dis_" .. mobf_settings.buttons[i].value .. ";" .. 
					mobf_settings.buttons[i].text .. " is disabled]"
				end
			
			else
				if current_setting then
					retval = retval .. "button[0.5,".. y_pos .. ";6,0.5;" .. 
					"dis_" .. mobf_settings.buttons[i].value .. ";" .. 
					mobf_settings.buttons[i].text .. " is enabled]"
				else
					retval = retval .. "button[0.5,".. y_pos .. ";6,0.5;" .. 
					"en_" .. mobf_settings.buttons[i].value .. ";" .. 
					mobf_settings.buttons[i].text .. " is disabled]"
				end
			end
			
			y_pos = y_pos + 0.75
		end
		
		return retval
	end
	
	return ""
end

------------------------------------------------------------------------------
-- name: handle_mob_en_disable_button
--
--! @brief handle press of en_disable button for a mob
--! @ingroup mobf_settings
--
--! @param fields
--!
--! @return
-------------------------------------------------------------------------------
function mobf_settings.handle_mob_en_disable_button(fields)
	for i,val in ipairs(mobf_rtd.registred_mob) do
		
        local page = nil
        
        for i = 0 , 5 , 1 do
            if fields["page".. i .. "_enable_" .. val] ~= nil then
                local mobf_mob_blacklist_string = minetest.setting_get("mobf_blacklist")
                local mobf_mobs_blacklisted = nil
                if mobf_mob_blacklist_string ~= nil then
                    mobf_mobs_blacklisted = minetest.deserialize(mobf_mob_blacklist_string)
                end
                
                if mobf_mobs_blacklisted == nil then
                    mobf_settings_debug("MOBF_SETTINGS: trying to enable mob but no mobs were blacklisted!?")
                else
                
                    local new_blacklist = {}
                    
                    for i,v in ipairs(mobf_mobs_blacklisted) do
                        if v ~= val then
                            table.insert(new_blacklist,v)
                        end
                    end
                    
                    minetest.setting_set("mobf_blacklist",minetest.serialize(new_blacklist))
                    mobf_settings_debug("MOBF_SETTINGS: Enabling: " .. val .. " blacklist is now: " .. dump(new_blacklist))
                end
                page = i
            end
        end
        
        for i = 0 , 5 , 1 do
            if fields["page".. i .. "_disable_" .. val] ~= nil then
            
                local mobf_mob_blacklist_string = minetest.setting_get("mobf_blacklist")
                local mobf_mobs_blacklisted = nil
                if mobf_mob_blacklist_string ~= nil then
                    mobf_mobs_blacklisted = minetest.deserialize(mobf_mob_blacklist_string)
                end
                
                if mobf_mobs_blacklisted == nil then
                    mobf_mobs_blacklisted = {}
                end
                
                table.insert(mobf_mobs_blacklisted,val)
                    
                minetest.setting_set("mobf_blacklist",minetest.serialize(mobf_mobs_blacklisted))
                page = i
                mobf_settings_debug("MOBF_SETTINGS: Disabling: " .. val)
            end
        end
        
        if page ~= nil then
            mobf_settings.save()
            return "mobf_list_page" .. page
        end
    end
    
    mobf_settings.save()
    return nil
end


------------------------------------------------------------------------------
-- name: handle_config_changed_button
--
--! @brief handle press of a settings button
--! @ingroup mobf_settings
--
--! @param fields
--!
--! @return
-------------------------------------------------------------------------------
function mobf_settings.handle_config_changed_button(fields)

	local config_setting = nil
	local enable  = false

	for i=1,#mobf_settings.buttons,1 do
		local fieldname = "en_" .. mobf_settings.buttons[i].value
		if fields[fieldname] ~= nil then
			config_setting = mobf_settings.buttons[i]
			enable = true
			break
		end
		
		fieldname = "dis_" .. mobf_settings.buttons[i].value
		if fields[fieldname] ~= nil then
			config_setting = mobf_settings.buttons[i]
			enable = false
			break
		end
	end

	if config_setting ~= nil then
		mobf_settings_debug("MOBF_SETTINGS: detected changed value " .. config_setting.value)
		if enable then
			minetest.setting_set(config_setting.value,"true")
		else
			minetest.setting_set(config_setting.value,"false")
		end
		mobf_settings.save()
		return true
	end
	
	return false
end

------------------------------------------------------------------------------
-- name: get_formspec
--
--! @brief generate page form for mobf_settings
--! @ingroup mobf_settings
--
--! @param player player to create page for
--! @param page pagename to create
-------------------------------------------------------------------------------
function mobf_settings.get_formspec(player,page)

    local version = "< 1.4.5"
    
    if (type(mobf_get_version) == "function") then
        version = mobf_get_version()
    end
    
    local playername = player:get_player_name()
		if minetest.check_player_privs(playername, {mobfw_admin=true}) then
		    local pageform = mobf_settings.get_known_animals_form(page)
		    
			return "size[13,10]"
			..mobf_settings.menubutton
			.."button[0.5,0.75;3,0.5;mobf_list_page1; Known Mobs ]"
			.."button[4,0.75;3,0.5;mobf_restart_required; Settings ]"
			.."label[5.5,0;MOBF " .. version .. "]"
			.. pageform
	else
		return "size[13,10]"
			..mobf_settings.menubutton
			.."label[0.5,1.0;You are not allowed to change any setting!]"
			.."label[0.5,2.25;Go Away!]"
			.."label[5.5,0;MOBF " .. version .. "]"
	end

end


------------------------------------------------------------------------------
-- name: set_mob_list_page(fields)
--
--! @brief check if requested page is a list page and show it
--! @ingroup mobf_settings
--
--! @oaram player 
--! @param fields data for callback
--
--! @return true if handled false if not
-------------------------------------------------------------------------------
function mobf_settings.set_mob_list_page(player,fields)
	if fields.mobf then
		mobf_settings.formspechandler(player, mobf_settings.get_formspec(player,"mobf_list_page1"))
		return true
	end
	
	
	for i=1,5,1 do
		local namestring = "mobf_list_page" .. i

		if fields[namestring] ~= nil then
			mobf_settings.formspechandler(player, mobf_settings.get_formspec(player,namestring))
			return true
		end
	end

	return false
end

------------------------------------------------------------------------------
-- name: register_config_button(configvalue,buttontext)
--
--! @brief register a button to be shown on config page
--! @ingroup mobf_settings
--
--! @param configvalue config value to change by this button
--! @param buttontext to set for this value
--! @param inverted invert enable/disable text on button
--
-------------------------------------------------------------------------------
function mobf_settings.register_config_button(configvalue,buttontext,inverted)

	local toadd = {
					value		= configvalue,
					text		= buttontext,
					inverted	= inverted,
					}
	
	table.insert(mobf_settings.buttons,toadd)
end

------------------------------------------------------------------------------
-- register handler for pressed buttons to inventory plus
------------------------------------------------------------------------------
minetest.register_on_player_receive_fields(function(player, formname, fields)
	--if one of your page buttons is pressed show another moblist page
	if mobf_settings.set_mob_list_page(player,fields) then
		return true
	end
	
	if mobf_settings.handle_config_changed_button(fields) or 
		fields.mobf_restart_required ~= nil then
		mobf_settings_debug("MOBF_SETTINGS: settings have been changed, show settings page: " .. dump(fields.mobf_restart_required))
		mobf_settings.formspechandler(player, mobf_settings.get_formspec(player,"mobf_restart_required"))
		return true
	end
	
	local blacklist_changed_page = mobf_settings.handle_mob_en_disable_button(fields)
	
	if blacklist_changed_page ~= nil then
		mobf_settings.formspechandler(player, mobf_settings.get_formspec(player,blacklist_changed_page))
		return true
	end
	
	return false
end)


--register chatcommand
minetest.register_chatcommand("mobf_settings",
	{
		params		= "",
		description = "show mobf settings" ,
		privs		= {mobfw_admin=true},
		func		= function(name,param)
				local player = minetest.env:get_player_by_name(name)
				mobf_settings.formspechandler(player,mobf_settings.get_formspec(player,"mobf_list_page1"))
			end
	})

------------------------------------------------------------------------------
-- register mobf_settings buttons
------------------------------------------------------------------------------
mobf_settings.register_config_button("mobf_disable_animal_spawning","Animal spawning",true)
mobf_settings.register_config_button("mobf_disable_3d_mode","3D mode",true)
mobf_settings.register_config_button("mobf_animal_spawning_secondary","Secondary spawning algorithm",false)
mobf_settings.register_config_button("mobf_delete_disabled_mobs","Deletion if disabled mob entities",false)
mobf_settings.register_config_button("mobf_log_bug_warnings","Show noisy bug warnings",false)
mobf_settings.register_config_button("vombie_3d_burn_animation_enabled","Vombie 3d burn animation",false)

print("mod mobf_settings "..mobf_settings.version.." loaded")