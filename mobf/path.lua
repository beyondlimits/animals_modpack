-------------------------------------------------------------------------------
-- Mob Framework Settings Mod by Sapier
-- 
-- You may copy, use, modify or do nearly anything except removing this
-- copyright notice. 
-- And of course you are NOT allow to pretend you have written it.
--
--! @file path.lua
--! @brief path support for mobf
--! @copyright Sapier
--! @author Sapier
--! @date 2013-02-09
--
-- Contact sapier a t gmx net
-------------------------------------------------------------------------------
mobf_assert_backtrace(mobf_path == nil)
mobf_path = {}

-------------------------------------------------------------------------------
-- name: init()
--
--! @brief initialize path subsystem
--! @ingroup mobf_path
-------------------------------------------------------------------------------
function mobf_path.init()
	mobf_path.load()

	if mobf_rtd.path_data == nil then
		mobf_rtd.path_data = {}
	end
	
	if mobf_rtd.path_data.users == nil then
		mobf_rtd.path_data.users = {}
	end
	
	--register path marker entity
	minetest.register_entity("mobf:path_marker_entity",
			 {
				physical        = false,
				collisionbox    = {-0.5,-0.5,-0.5,0.5,1.5,0.5 },
				visual          = "mesh",
				textures        = { "mobf_path_marker.png" },
				mesh            = "mobf_path_marker.b3d",
				initial_sprite_basepos 	= {x=0, y=0},
				automatic_rotate = 2,

				on_step = function(self,dtime)
				
					if self.creationtime == nil then
						self.creationtime = 0
					end
					
					self.creationtime = self.creationtime + dtime
					
					if self.creationtime > 30 then
						self.object:remove()
					end
				end
			})
			
	minetest.register_craftitem(":mobf:path_marker", {
		description = "Path marker tool",
		image = "mobf_path_marker_item.png",
		on_place = function(item, placer, pointed_thing)
			if pointed_thing.type == "node" then
				local pos = pointed_thing.above
				
				local entity = 
					spawning.spawn_and_check("mobf:path_marker_entity","",
												pos,"path_marker_click")

				if entity ~= nil then
					mobf_path.handle_path_marker_place(placer,pos)
				end
				return item
				end
			end
		})
		
	minetest.register_on_player_receive_fields(mobf_path.button_handler)
	
	minetest.register_chatcommand("mobf_manage_paths",
	{
		params		= "",
		description = "Manage paths for mobf" ,
		privs		= {mobfw_admin=true},
		func		= function(name,param)
						mobf_path.show_manage_menu(name,data)
						end
	})
end

-------------------------------------------------------------------------------
-- name: save()
--
--! @brief save all path data
--! @ingroup mobf_path
-------------------------------------------------------------------------------
function mobf_path.save()
	mobf_set_world_setting("mobf_path_data",minetest.serialize(mobf_rtd.path_data))
end

-------------------------------------------------------------------------------
-- name: load()
--
--! @brief save all path data
--! @ingroup mobf_path
-------------------------------------------------------------------------------
function mobf_path.load()
	mobf_rtd.path_data = minetest.deserialize(mobf_get_world_setting("mobf_path_data"))
end

-------------------------------------------------------------------------------
-- name: handle_path_marker_place(placer,pos)
--
--! @brief initialize path subsystem
--! @ingroup mobf_path
--
--! @param placer player object placing the path marker
--! @param pos position placed at
-------------------------------------------------------------------------------
function mobf_path.handle_path_marker_place(placer,pos)

	mobf_assert_backtrace(placer ~= nil)
	mobf_assert_backtrace(pos ~= nil)

	if placer:is_player() then
		local playername = placer:get_player_name()
		local player_paths = mobf_path.get_editable_path_names(playername)
		mobf_path.show_add_point_menu(playername,player_paths,pos)
	end
end


-------------------------------------------------------------------------------
-- name: get_editable_path_names(playername)
--
--! @brief get list of pathnames for a player
--! @ingroup mobf_path
--
--! @param playername name of player to get paths for
--
--! @return list of names
-------------------------------------------------------------------------------
function mobf_path.get_editable_path_names(playername)

	if mobf_rtd.path_data.users[playername] == nil then
		return nil
	end
	
	if mobf_rtd.path_data.users[playername].paths == nil then
		return nil
	end
	
	local retval = {}
	
	for k,v in pairs(mobf_rtd.path_data.users[playername].paths) do
		if not v.locked then
			table.insert(retval,k)
		end
	end
	
	if #retval > 0 then
		return retval
	end
	
	return nil
end

-------------------------------------------------------------------------------
-- name: add_point(playername,pathname,point)
--
--! @brief add a point to a path
--! @ingroup mobf_path
--
--! @param playername name of player to store point
--! @param pathname name of path to add point to
--! @param point point to add
-------------------------------------------------------------------------------
function mobf_path.add_point(playername,pathname,point)
	
	if mobf_rtd.path_data.users[playername] == nil then
		mobf_rtd.path_data.users[playername] = {}
	end
	
	if mobf_rtd.path_data.users[playername].paths == nil then
		mobf_rtd.path_data.users[playername].paths = {}
	end
	
	if mobf_rtd.path_data.users[playername].paths[pathname] == nil then
		mobf_rtd.path_data.users[playername].paths[pathname] = {}
		mobf_rtd.path_data.users[playername].paths[pathname].locked = false
		mobf_rtd.path_data.users[playername].paths[pathname].points = {}
	end
	
	table.insert(mobf_rtd.path_data.users[playername].paths[pathname].points,point)
end

-------------------------------------------------------------------------------
-- name: show_add_point_menu(pathnames)
--
--! @brief show a menu containing all paths a point may be added to
--! @ingroup mobf_path
--
--! @param playername player to show menu
--! @param pathnames names of paths
--! @param point point to add
-------------------------------------------------------------------------------
function mobf_path.show_add_point_menu(playername,pathnames,point)
	local buttons = ""
	local y_pos = 0.25
	local storage_id = mobf_global_data_store(point)
	if pathnames ~= nil then
		
		
		
		for i = 1, #pathnames, 1 do
			buttons = buttons .. "button_exit[0," .. y_pos .. ";4.5,0.5;" ..
					"mobfpath:existing:" .. storage_id ..
					":" .. pathnames[i] .. ";" .. pathnames[i] .. "]"
				y_pos = y_pos + 0.75
		end
	end
	
	local y_size = y_pos + 3 * 0.75 - 0.25
	--add new path element
	local formspec = "size[4.5," .. y_size .. "]" ..
				buttons ..
				"label[0," .. y_pos .. ";-----------------------------]" ..
				"field[0.25," .. (y_pos + 1) .. ";4.5,0.5;new_path_name;;]" ..
				"button_exit[1.5," .. (y_pos + 1.5) .. ";1.5,0.5;mobfpath:addnew:" ..
				storage_id .. ";new path]"
	
	--show formspec
	minetest.show_formspec(playername,"mobf:path:path_name_menu",formspec)
end

-------------------------------------------------------------------------------
-- name: button_handler(player, formname, fields)
--
--! @brief handle button click in mobf_path menu
--! @ingroup mobf_path
--
--! @param player player issuing click
--! @param formname name of form beeing clicked
--! @param fields data submitted to form
--
--! @return true/false event has been handled by this handler
-------------------------------------------------------------------------------
function mobf_path.button_handler(player, formname, fields)
	local playername = player:get_player_name()
	
	mobf_assert_backtrace(playername ~= nil)
	
	if formname == "mobf:path:path_name_menu" then
		dbg_mobf.path_lvl2("MOBF: Path marker rightclick path selected")
		for k,v in pairs(fields) do
			local parts = string.split(k,":")
			
			if parts[1] == "mobfpath" then
				local point = mobf_global_data_get(parts[3])
				local pathname = parts[4]
				if parts[2]  == "addnew" then
					pathname = fields.new_path_name
				end
				
				if point ~= nil and
					pathname ~= nil and
					pathname ~= "" then
					mobf_path.add_point(playername,pathname,point)
					mobf_path.save()
				end
			end
		end
		return true
	end
	
	if formname == "mobf:path:add_path_to_entity" then
		dbg_mobf.path_lvl2("MOBF: Adding path to an entity")
		for k,v in pairs(fields) do
			local parts = string.split(k,":")
			if parts[1] == "mobfpath" then
				local entity = mobf_global_data_get(parts[2])
				local pathname = parts[3]
				
				if entity ~= nil and
					pathname ~= nil and
					mobf_rtd.path_data.users[playername].paths[pathname] ~= nil and
					entity.data.patrol ~= nil then
					
					--switch to guard state
					 mobf_path.switch_patrol(entity,playername,pathname)
					
				end
			end
		end
		return true
	end
	
	if formname == "mobf:path:management_menu" then
		dbg_mobf.path_lvl2("MOBF: Path management menu button")
		for k,v in pairs(fields) do
			local data = mobf_path.parse_button_name(k)
			
			if data ~= nil then
				if data.buttonid == "next_page" then
					data.pagenum = data.pagenum + 1
					data.pathname = nil
					data.ownername = nil
				end
				
				if data.buttonid == "prev_page" and
					data.pagenum > 1 then
					data.pagenum = data.pagenum - 1
					data.pathname = nil
					data.ownername = nil
				end
				
				if data.buttonid == "lock_path" then
					mobf_rtd.path_data.users[data.ownername].paths[data.pathname].locked = true
					mobf_path.save()
				end
				
				if data.buttonid == "unlock_path" then
					mobf_rtd.path_data.users[data.ownername].paths[data.pathname].locked = false
					mobf_path.save()
				end
				
				if data.buttonid == "show_points" then
					for i,v in ipairs(mobf_rtd.path_data.users[data.ownername].paths[data.pathname].points) do
						local objects = minetest.get_objects_inside_radius(v,0.5)
						
						dbg_mobf.path_lvl3("MOBF: got " .. #objects .. 
							" around pos checking for marker")
						local found = false;
						for i=1,#objects,1 do
							local luaentity = objects[i]:get_luaentity()
							dbg_mobf.path_lvl3("MOBF: checking: " .. dump(luaentity))
							if luaentity.name == "mobf:path_marker_entity" then
								found = true
								break
							end
						end
						
						local node_at = minetest.get_node(v)
						
						if not found and 
							node_at.name ~= nil and
							node_at.name ~= "ignore" then
							spawning.spawn_and_check("mobf:path_marker_entity","",
												v,"mark_path")
						end
					end
				end
				
				if data.buttonid == "delete_path" then
					dbg_mobf.path_lvl1("MOBF: delete path issued: " 
						.. data.pathname .. " owner: " .. data.ownername)
					mobf_rtd.path_data.users[data.ownername].paths[data.pathname] = nil
					mobf_path.save()
					data.pathname = nil
					data.ownername = nil
				end
				
				dbg_mobf.path_lvl3("MOBF: Got button click with id: " .. 
									data.buttonid)
				mobf_path.show_manage_menu(playername,data)
			end
		end
		return true
	end
	
	--not handled by this callback
	return false
end

-------------------------------------------------------------------------------
-- name: get_pathlist(playername,isadmin)
--
--! @brief get a list of paths for a specific player
--! @ingroup mobf_path
--
--! @param playername name of player to get paths
--! @param isadmin does this player have admin rights?
--
--! @return list of paths
-------------------------------------------------------------------------------
function mobf_path.get_pathlist(playername,isadmin)
	local retval = {}
	if isadmin then
		for local_playername,userdata in pairs(mobf_rtd.path_data.users) do
			for pathname,path in pairs(userdata.paths) do
				dbg_mobf.path_lvl3("MOBF: Adding path: " .. pathname .. 
					" data:" .. dump(path))
				local toadd = {
					ownername = local_playername,
					pathname = pathname
				}
				dbg_mobf.path_lvl3("MOBF: Adding path entry: " .. dump(toadd))
				table.insert(retval,toadd)
			end
		end
	else
		if playername ~= nil and
			mobf_rtd.path_data.users[playername] ~= nil then
			for pathname,path in pairs(mobf_rtd.path_data.users[playername].paths) do
				local toadd = {
					ownername = playername,
					pathname = pathname
				}
				table.insert(retval,toadd)
			end
		end
	end
	
	return retval
end
-------------------------------------------------------------------------------
-- name: point_labels(playername,pathname)
--
--! @brief create a gui point gui element
--! @ingroup mobf_path
--
--! @param playername name of player to create path for
--! @param pathname name of path to prepare point gui list
--
--! @return string containing gui point list description
-------------------------------------------------------------------------------
function mobf_path.point_labels(playername,pathname)
	local retval = ""
	local current_y = 2.15
	local current_x = 6
	
	--TODO don't need to path playername here!
	for i,v in ipairs(mobf_rtd.path_data.users[playername].paths[pathname].points) do
	
		if i == 21 then 
			current_y = 2.15
			current_x = 9
		end
			
		if i <= 40 then
			retval = retval .. 
				"label[" .. current_x .. "," .. current_y .. ";".. 
					mobf_fixed_size_string(i .. ": ",5) .. printpos(v) .. "]"
		else
			--TODO add error maximum point count exceeded
		end
		
		current_y = current_y + 0.35
	end

	return retval
end

-------------------------------------------------------------------------------
-- name: path_buttons(paths,startindex, playername, data, isadmin)
--
--! @brief get buttons for paths
--! @ingroup mobf_path
--
--! @param paths paths to add
--! @param startindex index in paths to start
--! @param playername name of player
--! @param data information to add to button
--! @param isadmin create admin list
--
--! @return number of paths added,text
-------------------------------------------------------------------------------
function mobf_path.path_buttons(paths,startindex, playername,data,isadmin)
	dbg_mobf.path_lvl3("MOBF: path_buttons start index: " .. startindex .. 
									" table contains " .. #paths .. " entries")
	local current_index = 1
	local retval = ""
	local ystart = 1.75
	
	--preserve current data values
	local oldpathname  = data.pathname
	local oldownername = data.ownername
	
	for i,value in ipairs(paths) do
	
		if current_index >= startindex and
			current_index <= startindex + 10 then
			
			dbg_mobf.path_lvl3("MOBF: Creating button for: " .. dump(value))
			
			data.pathname = value.pathname
			data.ownername = value.ownername
			
			retval = retval ..
				"button[0," .. ystart .. ";3,0.5;" .. 
					mobf_path.make_button_name("pathbtn",data) .. ";" .. 
					value.pathname .. "]"
				
			if isadmin ~= nil then
				retval = retval ..
					"label[3," .. (ystart-0.125) .. ";" .. value.ownername .. "]"
			end
			
			ystart = ystart +0.75
		end	
		current_index = current_index +1
	end
	
	--restore data values
	data.pathname  = oldpathname
	data.ownername = oldownername
	
	return retval
end

-------------------------------------------------------------------------------
-- name: show_manage_menu(playername,data)
--
--! @brief show management menu for paths
--! @ingroup mobf_path
--
--! @param playername name of player
--! @param data current menu data prepared by previous functions
-------------------------------------------------------------------------------
function mobf_path.show_manage_menu(playername,data)

	mobf_assert_backtrace(playername ~= nil)
	
	if data == nil then
		data = {}
		data.pagenum = 1
	end

	--check privs	
	local isadmin = minetest.check_player_privs(playername, {mobfw_admin=true}) 
						or minetest.is_singleplayer()
	
	local pathbuttons = ""
	local all_paths = mobf_path.get_pathlist(playername,isadmin)
	
	local pathbuttons = 
		mobf_path.path_buttons(all_paths,
								(((data.pagenum -1) * 10) +1),playername,
								data, isadmin)
	
	local formspec = "size[13,10]"
	
	if data.pagenum > 1 then
		formspec = formspec ..
			"button[10.75,0;1,0.5;" .. 
				mobf_path.make_button_name("prev_page",data) .. "; <- ]"
	end
	if data.pagenum < #all_paths / 10 then
		formspec = formspec ..
			"button[12,0;1,0.5;" .. 
				mobf_path.make_button_name("next_page",data) .. "; -> ]"
	end
	formspec = formspec .. 
			"label[12.75,9.75;" .. data.pagenum .. "]" ..
			"label[0,-0.125;Mobf path management]" ..
			"label[0,1;Pathname]"

	if isadmin then
		formspec = formspec ..
			"label[3,1;Owner]"
	end
	
	formspec = formspec ..
			"label[6,1.5;Points]" ..
			"label[0,1.25;-----------------------------------]" ..
			"label[6,1.75;-------------------------------------------]" ..
			pathbuttons
			
	if data.pathname ~= nil then
		formspec = formspec ..
			"label[7,1;" .. data.pathname .."]" ..
			"label[9,1;" .. data.ownername .. "]"
			if not mobf_rtd.path_data.users[data.ownername].paths[data.pathname].locked then
				formspec = formspec ..
				"button[11.25,1.125;1.25,0.5;" .. 
					mobf_path.make_button_name("lock_path",data) .. ";lock]" ..
				"button[6,9.5;2,0.5;" .. 
					mobf_path.make_button_name("delete_path",data) .. ";delete]"
			else
				formspec = formspec ..
				"button[11.25,1.125;1.25,0.5;" .. 
					mobf_path.make_button_name("unlock_path",data) .. ";unlock]"
			end
			
			formspec = formspec ..
				"button[8.5,9.5;2,0.5;" .. 
					mobf_path.make_button_name("show_points",data) .. ";show points]" ..
				"button[10.5,9.5;2,0.5;" .. 
					mobf_path.make_button_name("unused",data) .. ";unused]"
				
			formspec = formspec .. 
				mobf_path.point_labels(data.ownername,data.pathname)
	end
	
	--show formspec
	minetest.show_formspec(playername,"mobf:path:management_menu",formspec)
end

-------------------------------------------------------------------------------
-- name: make_button_name(buttonid,data)
--
--! @brief create a button name
--! @ingroup mobf_path
--
--! @param buttonid id to use for this button
--! @param data information to add to this button
--
--! @return string containing data
-------------------------------------------------------------------------------
function mobf_path.make_button_name(buttonid,data)
	local retval = buttonid .. ":"
	
	retval = retval .. data.pagenum  .. ":"
	
	if data.pathname ~= nil then
		retval = retval .. data.pathname .. ":"
	else
		retval = retval .. ":"
	end
	
	if data.ownername ~= nil then
		retval = retval .. data.ownername .. ":"
	else
		retval = retval .. ":"
	end
	
	return retval
end

-------------------------------------------------------------------------------
-- name: parse_button_name(datastring)
--
--! @brief get data from button name
--! @ingroup mobf_path
--
--! @param datastring name to parse
--
--! @return parsed data
-------------------------------------------------------------------------------
function mobf_path.parse_button_name(datastring)
	mobf_assert_backtrace(datastring ~= nil)

	local data = {}
	local parts = string.split(datastring,":")
	
	data.buttonid  = parts[1]
	data.pagenum   = tonumber(parts[2])
	data.pathname  = parts[3]
	data.ownername = parts[4]
	if data.pathname == "" then
		data.pathname = nil
		data.ownername = nil
	end 
	
	return data
end

-------------------------------------------------------------------------------
-- name: mob_rightclick_callback(entity,player)
--
--! @brief do rightclick action
--! @ingroup mobf_path
--
--! @param entity mobf rightclicked
--! @param player issuing rightclick
-------------------------------------------------------------------------------

function mobf_path.mob_rightclick_callback(entity,player)

	if entity.dynamic_data.patrol_state_before ~= nil then
		mobf_path.switch_patrol(entity,nil,nil)
	else
		local buttons = ""
		local y_pos = 0.25
		local storage_id = mobf_global_data_store(entity)
		local playername = player:get_player_name()
		
		local pathlist = mobf_path.get_pathlist(playername,false)
		
		dbg_mobf.path_lvl2("MOBF: Pathlist contains: " .. dump(pathlist))
		
		for i = 1, #pathlist, 1 do
			buttons = buttons .. "button_exit[0," .. y_pos .. ";4.5,0.5;" ..
					"mobfpath:" .. storage_id ..
					":" .. pathlist[i].pathname .. ";" .. pathlist[i].pathname .. "]"
				y_pos = y_pos + 0.75
		end
		
		local y_size = y_pos - 0.25
		local formspec = "size[4.5," .. y_size .. "]" ..
					buttons
		
		--show formspec
		minetest.show_formspec(playername,"mobf:path:add_path_to_entity",formspec)
	end
end

-------------------------------------------------------------------------------
-- name: config_check(entity)
--
--! @brief check if mob is configured as trader
--! @ingroup mobf_path
--
--! @param entity mob being checked
--! @return true/false if trader or not
-------------------------------------------------------------------------------
function mobf_path.config_check(entity)
	if entity.data.patrol ~= nil then
		return true
	end
	
	return false
end

-------------------------------------------------------------------------------
-- name: buttontext(entity)
--
--! @brief return text for rightclick button
--! @ingroup mobf_path
--
--! @param entity to get text for
--! @return buttonname
-------------------------------------------------------------------------------
function mobf_path.buttontext(entity)
	if entity.dynamic_data.patrol_state_before == nil then
		return "Select path"
	end
	
	return "Disable path"
end

-------------------------------------------------------------------------------
-- name: switch_patrol(entity,points)
--
--! @brief check if mob is configured as trader
--! @ingroup mobf_path
--
--! @param entity mob being switched
--! @param pathowner owner of path to switch to
--! @param pathname path to switch to
-------------------------------------------------------------------------------
function mobf_path.switch_patrol(entity,pathowner,pathname)
	if pathowner ~= nil and
		pathname ~= nil and
		entity.data.patrol.state ~= nil then
		
		if entity.dynamic_data.patrol_state_before == nil then
		
			if entity.dynamic_data.state.current ~= entity.data.patrol.state then
				entity.dynamic_data.patrol_state_before = entity.dynamic_data.state.current
			else
				entity.dynamic_data.patrol_state_before = "default"
			end
			mob_state.lock(entity,true)
		end
		local new_state = mob_state.get_state_by_name(entity,entity.data.patrol.state)
		
		mobf_assert_backtrace(new_state ~= nil)
		mob_state.change_state(entity,new_state)
		entity.dynamic_data.p_movement.pathowner = pathowner
		entity.dynamic_data.p_movement.pathname = pathname
		entity.dynamic_data.p_movement.path = 
			mobf_rtd.path_data.users[pathowner].paths[pathname].points
		entity.dynamic_data.p_movement.next_path_index = 1
	else
		if entity.dynamic_data.patrol_state_before ~= nil then
			local new_state = mob_state.get_state_by_name(entity,entity.dynamic_data.patrol_state_before)
		
			mobf_assert_backtrace(new_state ~= nil)
			mob_state.change_state(entity,new_state)
			entity.dynamic_data.patrol_state_before = nil
			mob_state.lock(entity,false)
		end
	end
end


-------------------------------------------------------------------------------
-- name: getpoints(owner,name)
--
--! @brief get a path by owner and name
--! @ingroup mobf_path
--
--! @param pathowner player owning the path
--! @param pathname name of path
--! @return list of points
-------------------------------------------------------------------------------
function mobf_path.getpoints(pathowner,pathname)
	if mobf_rtd.path_data.users[pathowner] == nil then
		dbg_mobf.path_lvl2("MOBF: no paths for " .. dump(pathowner) .. " found")
		return nil
	end
	
	if mobf_rtd.path_data.users[pathowner].paths[pathname] == nil then
		dbg_mobf.path_lvl2(
			"MOBF: no path " .. dump(pathname) .. 
			" found for owner " .. pathowner ..
			" have paths: " .. dump(mobf_rtd.path_data.users[pathowner].paths))
		return nil
	end

	return mobf_rtd.path_data.users[pathowner].paths[pathname].points
end