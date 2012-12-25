mobf_settings_version = "0.0.6"

if type(inventory_plus.register_button) == "function" then
	minetest.register_on_joinplayer(function(player)
	    local playername = player:get_player_name()
	    if playername == "singleplayer" or
	        minetest.check_player_privs(playername, {mobfw_admin=true}) then
	        
	        
	            inventory_plus.register_button(player,"mobf","Mobf Settings")
	        
	    end
	end)
else
    inventory_plus.pages["mobf"] = "Mobf Settings"
end

function get_animal_list(page)

    local mobf_mob_blacklist_string = minetest.setting_get("mobf_blacklist")
    local mobf_mobs_blacklisted = nil
    if mobf_mob_blacklist_string ~= nil then
        mobf_mobs_blacklisted = minetest.deserialize(mobf_mob_blacklist_string)
    end

    local retval = ""
    local line = 3

    local start_at = page -1

    for i,val in ipairs(mobf_registred_mob) do
        
        if i > (start_at*16) then
	        if i <= (start_at*16 + 8) then
	            retval = retval .. "label[1.0," .. line .. ";" .. val .. "]"
	            local line_btn = line + 0.25
	            if contains(mobf_mobs_blacklisted,val) then
	               retval = retval .. "button[0.5," .. line_btn .. ";0.5,0.25;page"..page.."_enable_" .. val .. "; ]"
	            else
	               retval = retval .. "button[0.5," .. line_btn .. ";0.5,0.25;page"..page.."_disable_" .. val .. ";x]"
	            end
	        end
	        
	        if i > (start_at*16 + 8 ) and
	            i <= (start_at*16 + 16) then
	            
	            local temp_line = line - (8*0.75)
	            retval = retval .. "label[7.0," .. temp_line .. ";" .. val .. "]"
	            
	            local line_btn = temp_line +0.25
	            if contains(mobf_mobs_blacklisted,val) then
                   retval = retval .. "button[6.5," .. line_btn .. ";0.5,0.25;page"..page.."_enable_" .. val .. "; ]"
                else
                   retval = retval .. "button[6.5," .. line_btn .. ";0.5,0.25;page"..page.."_disable_" .. val .. ";x]"
                end
	        end
	        
	        line = line + 0.75
	    end
    end

    return retval
end

function contains(cur_table,element)

    if cur_table == nil then
        print("looking in empty table")
        return false
    end
    
    print("looking for " .. dump(element) .. " in " .. dump(cur_table))
    
    for i,v in ipairs(cur_table) do
        if v == element then
            print("found: " .. element .. " in table")
            return true
        end
    end
    
    print("didn't find " .. element)
    return false
end

function get_known_animals_form(page)
    local retval = ""

    if page == "mobf_list_page1" then
        
        retval = "label[0.5,2.25;Known Mobs, Page 1]"
                 .."label[0.5,2.5;-------------------------------------------]"
                 .."label[6.5,2.5;----------------------------------------]"
                 .. get_animal_list(1)
                 .."button[3,9.5;2,0.5;mobf_list_page2;Next]"
        return retval
    end
    
    if page == "mobf_list_page2" then
        retval = "label[0.5,2.25;Known Mobs, Page 2]"
                .."label[0.5,2.5;-------------------------------------------]"
                .."label[6.5,2.5;----------------------------------------]"
                .. get_animal_list(2)
                .."button[3,9.5;2,0.5;mobf_list_page3;Next]"
                .."button[0.5,9.5;2,0.5;mobf_list_page1;Prev]"
        return retval
    end
    
    if page == "mobf_list_page3" then
        retval = "label[0.5,2.25;Known Mobs, Page 3]"
                .."label[0.5,2.5;-------------------------------------------]"
                .."label[6.5,2.5;----------------------------------------]"
                .. get_animal_list(3)
                .."button[3,9.5;2,0.5;mobf_list_page4;Next]"
                .."button[0.5,9.5;2,0.5;mobf_list_page2;Prev]"
        return retval
    end
    
    if page == "mobf_list_page4" then
        retval = "label[0.5,2.25;Known Mobs, Page 4]"
                .."label[0.5,2.5;-------------------------------------------]"
                .."label[6.5,2.5;----------------------------------------]"
                .. get_animal_list(4)
                .."button[3,9.5;2,0.5;mobf_list_page5;Next]"
                .."button[0.5,9.5;2,0.5;mobf_list_page3;Prev]"
        return retval
    end
    
    if page == "mobf_list_page5" then
        retval = "label[0.5,2.25;Known Mobs, Page 5]"
                .."label[0.5,2.5;-------------------------------------------]"
                .."label[6.5,2.5;----------------------------------------]"
                .. get_animal_list(5)
                .."button[0.5,9.5;2,0.5;mobf_list_page4;Prev]"
        return retval
    end
    
    
    if page == "mobf_restart_required" then
        retval = "label[0.5,2.25;This settings require to restart Game!]"
                .."label[0.5,2.5;-------------------------------------------]"
                .."label[6.5,2.5;----------------------------------------]"
    
        if minetest.setting_getbool("mobf_disable_animal_spawning") then
            retval = retval .. "button[0.5,3.75;6,0.5;mobf_enable_spawning;Spawning is disabled]"
        else
            retval = retval .. "button[0.5,3.75;6,0.5;mobf_disable_spawning;Spawning is enabled]"
        end
        
        if minetest.setting_getbool("mobf_disable_3d_mode") then
            retval = retval .. "button[0.5,4.5;6,0.5;mobf_enable_3dmode;3D mode is disabled]"
        else
            retval = retval .. "button[0.5,4.5;6,0.5;mobf_disable_3dmode;3D mode is enabled]"
        end
        
        if minetest.setting_getbool("mobf_animal_spawning_secondary") then
            retval = retval .. "button[0.5,5.25;6,0.5;mobf_disable_secondary_spawning;Secondary spawning is enabled]"
        else
            retval = retval .. "button[0.5,5.25;6,0.5;mobf_enable_secondary_spawning;Secondary spawning is disabled]"
        end
        
        if minetest.setting_getbool("mobf_delete_disabled_mobs") then
            retval = retval .. "button[0.5,6;6,0.5;mobf_dont_delete_disabled_mobs_from_map;Disabled mobs are deleted]"
        else
            retval = retval .. "button[0.5,6;6,0.5;mobf_delete_disabled_mobs_from_map;Disabled mobs stay as unknown]"
        end
        
        if minetest.setting_getbool("mobf_log_bug_warnings") then
            retval = retval .. "button[0.5,6.75;6,0.5;mobf_dont_log_bug_warnings;Bug warnings are logged]"
        else
            retval = retval .. "button[0.5,6.75;6,0.5;mobf_log_bug_warnings;Bug warnings are not logged]"
        end
    
        return retval
    end
    
    return ""
end

function check_mob_en_disable(fields)
    for i,val in ipairs(mobf_registred_mob) do
        
        local page = nil
        
        for i = 0 , 5 , 1 do
	        if fields["page".. i .. "_enable_" .. val] ~= nil then
	            local mobf_mob_blacklist_string = minetest.setting_get("mobf_blacklist")
                local mobf_mobs_blacklisted = nil
                if mobf_mob_blacklist_string ~= nil then
                    mobf_mobs_blacklisted = minetest.deserialize(mobf_mob_blacklist_string)
                end
                
                if mobf_mobs_blacklisted == nil then
                    print("trying to enable mob but no mobs were blacklisted!?")
                else
                
                    local new_blacklist = {}
                    
                    for i,v in ipairs(mobf_mobs_blacklisted) do
                        if v ~= val then
                            table.insert(new_blacklist,v)
                        end
                    end
                    
                    minetest.setting_set("mobf_blacklist",minetest.serialize(new_blacklist))
                    print("Enabling: " .. val .. " blacklist is now: " .. dump(new_blacklist))
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
                print("Disabling: " .. val)
            end
        end
        
        if page ~= nil then
            return "mobf_list_page" .. page
        end
    end
    
    return nil
end

-- get_formspec
local get_formspec = function(player,page)

    local version = "< 1.4.5"
    
    if (type(mobf_get_version) == "function") then
        version = mobf_get_version()
    end
    
    
    local pageform = get_known_animals_form(page)
    
	return "size[13,10]"
	.."button[11,9.5;2,0.5;main; Mainmenu ]"
	.."button[0.5,0.75;3,0.5;mobf_list_page1; Known Mobs ]"
	.."button[4,0.75;3,0.5;mobf_restart_required; Settings ]"
	.."label[5.5,0;MOBF " .. version .. "]"
	.. pageform
	

end

-- register_on_player_receive_fields
minetest.register_on_player_receive_fields(function(player, formname, fields)
    print("Fields: " .. dump(fields))
    if fields.mobf or
        fields.mobf_list_page1 then
        inventory_plus.set_inventory_formspec(player, get_formspec(player,"mobf_list_page1"))
        return true
    end
    
    if fields.mobf_list_page2 then
        inventory_plus.set_inventory_formspec(player, get_formspec(player,"mobf_list_page2"))
        return true
    end
    
    if fields.mobf_list_page3 then
        inventory_plus.set_inventory_formspec(player, get_formspec(player,"mobf_list_page3"))
        return true
    end
    
    if fields.mobf_list_page4 then
        inventory_plus.set_inventory_formspec(player, get_formspec(player,"mobf_list_page4"))
        return true
    end
    
    if fields.mobf_list_page5 then
        inventory_plus.set_inventory_formspec(player, get_formspec(player,"mobf_list_page5"))
        return true
    end
    
    if fields.mobf_enable_spawning then
        minetest.setting_set("mobf_disable_animal_spawning","false")
    end
    
    if fields.mobf_disable_spawning then
        minetest.setting_set("mobf_disable_animal_spawning","true")
    end
        
    if fields.mobf_enable_3dmode then
        minetest.setting_set("mobf_disable_3d_mode","false")
    end
    
    if fields.mobf_disable_3dmode then
        minetest.setting_set("mobf_disable_3d_mode","true")
    end
    
    if fields.mobf_enable_secondary_spawning then
        minetest.setting_set("mobf_animal_spawning_secondary","true")
    end
    
    if fields.mobf_disable_secondary_spawning then
        minetest.setting_set("mobf_animal_spawning_secondary","false")
    end
    
    if fields.mobf_delete_disabled_mobs_from_map then
        minetest.setting_set("mobf_delete_disabled_mobs","true")
    end
    
    if fields.mobf_dont_delete_disabled_mobs_from_map then
        minetest.setting_set("mobf_delete_disabled_mobs","false")
    end
    
    if fields.mobf_log_bug_warnings then
        minetest.setting_set("mobf_log_bug_warnings","true")
    end
    
    if fields.mobf_dont_log_bug_warnings then
        minetest.setting_set("mobf_log_bug_warnings","false")
    end
    
    if fields.mobf_restart_required or
        fields.mobf_enable_spawning or
        fields.mobf_disable_spawning or
        fields.mobf_enable_3dmode or
        fields.mobf_disable_3dmode or
        fields.mobf_disable_secondary_spawning or 
        fields.mobf_enable_secondary_spawning or 
        fields.mobf_delete_disabled_mobs_from_map or
        fields.mobf_dont_delete_disabled_mobs_from_map or
        fields.mobf_log_bug_warnings or
        fields.mobf_dont_log_bug_warnings
        then
        inventory_plus.set_inventory_formspec(player, get_formspec(player,"mobf_restart_required"))
        return true
    end
    
    local blacklist_changed_page = check_mob_en_disable(fields)
    
    if blacklist_changed_page ~= nil then
        inventory_plus.set_inventory_formspec(player, get_formspec(player,blacklist_changed_page))
    end
    
    --local temp_blacklist_string = minetest.setting_get("mobf_blacklist")
    --print("blacklist is: " .. dump(temp_blacklist_string))
    
    return false
end)

print("mod mobf_settings "..mobf_settings_version.." loaded")