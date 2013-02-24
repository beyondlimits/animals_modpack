function debug_print_g_pos(g_pos)

	print("DIRS:")
	print("   " .. mobf_fixed_size_string(g_pos.zp_weight,3) .. "   ")
	print(mobf_fixed_size_string(g_pos.xm_weight,3) .. "   " .. mobf_fixed_size_string(g_pos.xp_weight,3))
	print("   " .. mobf_fixed_size_string(g_pos.zm_weight,3) .. "   ")
end

minetest.register_chatcommand("find_path",
		{
			params		= "pos1, pos2",
			description = "find a path between pos1 and pos2" ,
			privs		= {},

			
			func = function(name,param)
								--evaluate param
								print("name: " .. name .. " param: " .. dump(param))
	
								local parameters = param:split(" ")
								
								if #parameters < 2 then
									print("invalid parameter count")
									return
								end
								
								local pos1_strings = parameters[1]:split(",")
								local pos2_strings = parameters[2]:split(",")
								
								if #pos1_strings ~= 3 then
									print("pos1 invalid")
									return
								end
								
								if #pos2_strings ~= 3 then
									print("pos2 invalid")
									return
								end
							
								local pos1 = {
													x=tonumber(pos1_strings[1]),
													y=tonumber(pos1_strings[2]),
													z=tonumber(pos1_strings[3])
													}
													
								local pos2 = {
													x=tonumber(pos2_strings[1]),
													y=tonumber(pos2_strings[2]),
													z=tonumber(pos2_strings[3])
													}
													
								local path = find_path(pos1,pos2,1,2,1,5,parameters[3])
								
								if path ~= nil then
									for i=1,#path,1 do
										print(mobf_fixed_size_string(i,2) .. ": " ..printpos(path[i]))
									end
								end
								
								print("Done!")
							end,
		})
		
function debug_print_area_paths(data)
	print("Pathlength:")
	local head = "" .. mobf_fixed_size_string("",3) .. "  "
	local head2 = "-----"
	for x=1,#data.grid[1],1 do
		head = head .. " " .. 
				mobf_fixed_size_string(tostring(x),3) 
				.. " "
		head2 = head2 .. "-----"
	end
	print(head)
	print(head2)

	for i=1,#data.grid,1 do
	local line = "" .. mobf_fixed_size_string(tostring(i),3) .. ": "
	for j=1,#data.grid[i],1 do
		if data.grid[i][j].pathlength ~= nil then
			if data.grid[i][j].istarget then
				line = line .. "  T  "
			else
				line = line .. " " .. 
					mobf_fixed_size_string(tostring(data.grid[i][j].pathlength),3) 
					.. " "
			end
		else
			line = line .. " nil "
		end
	end
		print(line)
	end
	
	print("")
end

function debug_print_zp_weight(data)
	
	print("ZP weight:")
	local head = "" .. mobf_fixed_size_string("",3) .. "  "
	local head2 = "-----"
	for x=1,#data.grid[1],1 do
		head = head .. " " .. 
				mobf_fixed_size_string(tostring(x),3) 
				.. " "
		head2 = head2 .. "-----"
	end
	print(head)
	print(head2)

	for i=1,#data.grid,1 do
	local line = "" .. mobf_fixed_size_string(tostring(i),3) .. ": "
	for j=1,#data.grid[i],1 do
		if data.grid[i][j].pathlength ~= nil then
			line = line .. " " .. 
				mobf_fixed_size_string(tostring(data.grid[i][j].zp_weight),3) 
				.. " "
		else
			line = line .. " nil "
		end
	end
		print(line)
	end
	print("")
end

function debug_print_zm_weight(data)
	
	print("ZM weight:")
	local head = "" .. mobf_fixed_size_string("",3) .. "  "
	local head2 = "-----"
	for x=1,#data.grid[1],1 do
		head = head .. " " .. 
				mobf_fixed_size_string(tostring(x),3) 
				.. " "
		head2 = head2 .. "-----"
	end
	print(head)
	print(head2)

	for i=1,#data.grid,1 do
	local line = "" .. mobf_fixed_size_string(tostring(i),3) .. ": "
	for j=1,#data.grid[i],1 do
		if data.grid[i][j].pathlength ~= nil then
			line = line .. " " .. 
				mobf_fixed_size_string(tostring(data.grid[i][j].zm_weight),3) 
				.. " "
		else
			line = line .. " nil "
		end
	end
		print(line)
	end
	print("")
end

function debug_print_xp_weight(data)
	print("XP weight:")
	local head = "" .. mobf_fixed_size_string("",3) .. "  "
	local head2 = "-----"
	for x=1,#data.grid[1],1 do
		head = head .. " " .. 
				mobf_fixed_size_string(tostring(x),3) 
				.. " "
		head2 = head2 .. "-----"
	end
	print(head)
	print(head2)

	for i=1,#data.grid,1 do
	local line = "" .. mobf_fixed_size_string(tostring(i),3) .. ": "
	for j=1,#data.grid[i],1 do
		if data.grid[i][j].pathlength ~= nil then
			line = line .. " " .. 
				mobf_fixed_size_string(tostring(data.grid[i][j].xp_weight),3) 
				.. " "
		else
			line = line .. " nil "
		end
	end
		print(line)
	end
	
	print("")
end

function debug_print_xm_weight(data)
	print("XM weight:")
	local head = "" .. mobf_fixed_size_string("",3) .. "  "
	local head2 = "-----"
	for x=1,#data.grid[1],1 do
		head = head .. " " .. 
				mobf_fixed_size_string(tostring(x),3) 
				.. " "
		head2 = head2 .. "-----"
	end
	print(head)
	print(head2)

	for i=1,#data.grid,1 do
	local line = "" .. mobf_fixed_size_string(tostring(i),3) .. ": "
	for j=1,#data.grid[i],1 do
		if data.grid[i][j].pathlength ~= nil then
			line = line .. " " .. 
				mobf_fixed_size_string(tostring(data.grid[i][j].xm_weight),3) 
				.. " "
		else
			line = line .. " nil "
		end
	end
		print(line)
	end
	
	print("")
end

function debug_print_height(data)
	print("height:")
	local head = "" .. mobf_fixed_size_string("",3) .. "  "
	local head2 = "-----"
	for x=1,#data.grid[1],1 do
		head = head .. " " .. 
				mobf_fixed_size_string(tostring(x),3) 
				.. " "
		head2 = head2 .. "-----"
	end
	print(head)
	print(head2)

	for i=1,#data.grid,1 do
	local line = "" .. mobf_fixed_size_string(tostring(i),3) .. ": "
	for j=1,#data.grid[i],1 do
		if data.grid[i][j].pathlength ~= nil then
			line = line .. " " .. 
				mobf_fixed_size_string(tostring(data.grid[i][j].pos.y),3) 
				.. " "
		else
			line = line .. " nil "
		end
	end
		print(line)
	end
	
	print("")
end

function debug_print_path(data)
	print("path:")
	local head = "" .. mobf_fixed_size_string("",3) .. "  "
	local head2 = "-----"
	for x=1,#data.grid[1],1 do
		head = head .. " " .. 
				mobf_fixed_size_string(tostring(x),3) 
				.. " "
		head2 = head2 .. "-----"
	end
	print(head)
	print(head2)

	for i=1,#data.grid,1 do
	local line = "" .. mobf_fixed_size_string(tostring(i),3) .. ": "
	for j=1,#data.grid[i],1 do
		if data.grid[i][j].pathlength ~= nil then
			line = line .. " " .. 
				mobf_fixed_size_string(tostring(data.grid[i][j].iselement),3) 
				.. " "
		else
			line = line .. " nil "
		end
	end
		print(line)
	end
	
	print("")
end