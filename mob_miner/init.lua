-------------------------------------------------------------------------------
-- Mob Framework Mod by Sapier
--
-- You may copy, use, modify or do nearly anything except removing this
-- copyright notice.
-- And of course you are NOT allow to pretend you have written it.
--
--! @file init.lua
--! @brief npc implementation
--! @copyright Sapier
--! @author Sapier
--! @date 2015-12-20
--
-- Contact sapier a t gmx net
-------------------------------------------------------------------------------

--!path of mod
local miner_modpath = minetest.get_modpath("mob_miner")

local max_tunnel_size = 5
local SOUND_INTERVAL = 0.6

--include debug trace functions
dofile (miner_modpath .. "/digging_utils.lua")

-- Boilerplate to support localized strings if intllib mod is installed.
local S
if (minetest.get_modpath("intllib")) then
  dofile(minetest.get_modpath("intllib").."/intllib.lua")
  S = intllib.Getter(minetest.get_current_modname())
else
  S = function ( s ) return s end
end

minetest.log("action","MOD: mob_miner mod loading ...")

local version = "0.0.1"
local miner_groups = {
						not_in_creative_inventory=1
					}

local hand_tooldef = {
        tool_capabilities = 
            {
                full_punch_interval = 0.9,
                max_drop_level = 0,
                groupcaps = {
                  crumbly = {times={[2]=3.00, [3]=0.70}, uses=0, maxlevel=1},
                  snappy = {times={[3]=0.40}, uses=0, maxlevel=1},
                  oddly_breakable_by_hand = {times={[1]=3.50,[2]=2.00,[3]=0.70}, uses=0}
                },
                damage_groups = {fleshy=1},
            }
        }

					
local miner_activate = function(entity)
    local mydata = entity:get_persistent_data()

    if (mydata.control == nil ) then
        mydata.control = {
            digstate = "idle",
        }
    end
    
    if (mydata.inventory == nil) then
        mydata.inventory = {}
    end
    
    if type(mydata.control.digpos) ~= "table" then
        mydata.control.digpos= nil
    end
    
    if (mydata.control.digstate == "idle_nothing_to_dig") then
        mydata.control.digstate = "idle"
    end
    
    if (mydata.control.digstate == "idle") then
        entity:set_state("default")
    elseif (mydata.control.digstate == "digging") then
        entity:set_state("digging")
    end
    
    if mydata.name == nil then
        mydata.name = "Nobody"
    end
    
    if mydata.inventory == nil then
        mydata.inventory = {}
    end
    
    if mydata.inventory.tools == nil then
        mydata.inventory.tools = {}
    end
    
    if mydata.inventory.digged == nil then
        mydata.inventory.digged = {}
    end
    
    if mydata.digspec == nil or 
       #mydata.digspec ~= max_tunnel_size then
        mydata.digspec = {}
    end
    
    for x = 1, max_tunnel_size, 1 do
        if mydata.digspec[x] == nil or 
           #mydata.digspec[x] ~= max_tunnel_size then
            mydata.digspec[x] = {}
            
            for y = 1, max_tunnel_size, 1 do
              mydata.digspec[x][y] = false
            end
        end
    end
    
    mydata.digspec[3][1] = true
    mydata.digspec[3][2] = true
    
    if  mydata.control.soundtime == nil then
        mydata.control.soundtime = 0
    end
    
    mydata.unique_entity_id = string.gsub(tostring(entity),"table: ","")
    entity.dynamic_data.miner_formspec_data = {}
end

local miner_show_formspec = function(playername, entity, data)

    local storageid = mobf_global_data_store(entity)
    
    local formname = "mobf_miner:" ..storageid
    
    entity.dynamic_data.miner_formspec_data.tools_inventory =
        core.create_detached_inventory(data.unique_entity_id,
          {
            allow_put   = function(inv, listname, index, stack, player)
                if (listname == "tools") then
                    if (stack:get_tool_capabilities() == nil ) then
                       
                        return 0
                    else
                        return 1
                    end
                else
                    return 0
                end
            end,
          })
          
    local inv = entity.dynamic_data.miner_formspec_data.tools_inventory
        
    entity.dynamic_data.miner_formspec_data.tools_inventory:set_size("tools",4)
    
    for i,v in ipairs(data.inventory.tools) do
        inv:set_stack("tools", i, ItemStack(v))
    end
    
    entity.dynamic_data.miner_formspec_data.tools_inventory:set_size("digged",12)
    
    for i,v in ipairs(data.inventory.digged) do
        inv:set_stack("digged", i, ItemStack(v))
    end
    
    local miner_formspec = "size[10,8.5;]" ..
      "label[1,0;"..S("Miner %s"):format(data.name).."]" ..
      "label[0,1;"..S("Tools:").."]"..
      "label[5,1;"..S("Tunnel shape:").."]" ..
      "label[0,2.5;"..S("Minerinventory:").."]"..
      "list[detached:" .. data.unique_entity_id .. ";tools;0,1.5;4,1;]" ..
      "list[detached:" .. data.unique_entity_id .. ";digged;0,3;4,3;]" ..
      "list[current_player;main;1,7.5;8,1;]" ..
      "field[0.25,7;2,0.5;te_digdepth;Dig depth;1]" ..
      "button_exit[2,6.8;2,0.25;btn_start_digging;" .. S("start digging") .. "]"
      
      for x = 1, max_tunnel_size, 1 do
          for y = max_tunnel_size, 1, -1 do
              if ( x == 3 ) and (y == 1) or
                 ( x == 3 ) and (y == 2) then
                  --! miners size
              else
                  if data.digspec[x][y] then
                    miner_formspec = miner_formspec .. 
                      "image_button[" .. ((x*0.825)+4) .. "," .. (6- (y*0.9)) .. ";1,1;" ..
                      "blank.png;" .. 
                      "btn_tunnelshape_" .. x .. "x" .. y .. ";;" .. 
                      "false;false;crack_anylength.png]"
                  else
                    miner_formspec = miner_formspec ..
                      "image_button[" .. ((x*0.825)+4) .. "," .. (6-(y*0.9)) .. ";1,1;" ..
                      "default_stone.png;" .. 
                      "btn_tunnelshape_" .. x .. "x" .. y .. ";;" .. 
                      "false;false;crack_anylength.png]"
                  end
              end
          end
      end
      
    core.show_formspec(playername, formname, miner_formspec)
end


local miner_get_nodes_to_dig = function(direction, basepos, digspec)

    local nodelist = {}
    
    local offset = 0;
    
    if (direction == "xplus") or (direction == "zplus") then
      offset = 1
    elseif (direction == "xminus") or (direction == "zminus") then
      offset = -1
    end
    
    local horiz_offset = math.floor(#digspec /2)    
    local xidx = function(addon, direction, digspecsize)
        if direction == "zminus" or direction == "xplus" then
          return digspecsize - (addon + horiz_offset)
        elseif direction == "zplus" or direction == "xminus" then
          return  addon + horiz_offset +1;
        end
    end
    
    if (direction == "zplus") or (direction == "zminus") then
      for yaddon = 0 , #digspec[1], 1  do
          for xaddon = -horiz_offset , horiz_offset, 1  do
          
            if digspec[xidx(xaddon,direction,#digspec)][yaddon +1] then
                table.insert(nodelist, {x=basepos.x+xaddon, y=basepos.y+yaddon, z=basepos.z+offset})
            end
          end
      end
    elseif (direction == "xplus") or (direction == "xminus") then
      for yaddon = 0 , #digspec[1], 1  do
          for zaddon = -horiz_offset , horiz_offset, 1  do
            if digspec[xidx(zaddon,direction,#digspec)][yaddon +1] then
                table.insert(nodelist, {x=basepos.x+offset, y=basepos.y+yaddon, z=basepos.z+zaddon})
            end
          end
      end
    end
    
    return nodelist

end

local miner_get_diggable_nodes = function(nodelist)
    local retval = {}
    
    for i, v in ipairs(nodelist) do
      local nodeat = core.get_node(v)
      
      if (nodeat.name ~= "air") then
          table.insert(retval, v)
          break
      end
    end
    
    return retval
end

local miner_getdir =function(entity)
        local basepos = entity:getbasepos()
        
        local yaw = entity.object:getyaw()
        
        local direction = "ukn"
        
        while (yaw > (2*math.pi)) do
          yaw = yaw -(2*math.pi)
        end
        
        if (yaw < ((2*math.pi)/8)) then
          direction = "zplus"
        elseif (yaw < (3*((2*math.pi)/8))) then
          direction = "xminus"
        elseif (yaw < (5*((2*math.pi)/8))) then
          direction =  "zminus"
        elseif (yaw < (7*((2*math.pi)/8))) then
          direction = "xplus"
        elseif (yaw <= (2*math.pi)) then
          direction = "zplus"
        end
        
        return direction
end

local miner_stepforward = function(entity)
    local pos = entity.object:getpos()
    local basepos = entity:getbasepos()
    local direction = miner_getdir(entity)
    
    local targetpos = pos
    local targetbasepos = basepos
    
    if (direction == "xplus") then
        targetpos = {x=pos.x+1, z=pos.z, y=pos.y}
        targetbasepos = {x=basepos.x+1, z=basepos.z, y=basepos.y}
    elseif(direction == "xminus") then
        targetpos = {x=pos.x-1, z=pos.z, y=pos.y}
        targetbasepos = {x=basepos.x-1, z=basepos.z, y=basepos.y}
    elseif (direction == "zplus") then
        targetpos = {x=pos.x, z=pos.z+1, y=pos.y}
        targetbasepos = {x=basepos.x, z=basepos.z+1, y=basepos.y}
    elseif (direction == "zminus") then
        targetpos = {x=pos.x, z=pos.z-1, y=pos.y}
        targetbasepos = {x=basepos.x, z=basepos.z-1, y=basepos.y}
    end
    
    if (environment.pos_is_ok(targetbasepos,entity,true) == "ok") then
       entity.object:moveto( targetpos, true)
       return true
    end

    return false
end

local miner_add_wear = function(toolname, wear, tool_inventory)

    --! digging using hand
    if (toolname == "") then
        return true
    end

    local done = false

    for i = 1, #tool_inventory, 1 do
        if (tool_inventory[i] ~= nil) then
            if (tool_inventory[i].name == toolname) then
                tool_inventory[i].wear = tool_inventory[i].wear + wear
                done = true
                if (tool_inventory[i].wear > 65535) then
                    tool_inventory[i] = nil
                end
                break
            end
        end
    end
    
    return done
end

local miner_add_to_inventory = function(itemname, diged_inventory)

    local done = false
    
    local temp_stack =  ItemStack( { name=itemname })
    local stack_max = temp_stack:get_stack_max()

    for i = 1, #diged_inventory, 1 do
        if (diged_inventory[i].name == itemname) then
           
            if (diged_inventory[i].count < stack_max) then
                diged_inventory[i].count = diged_inventory[i].count +1
                done = true
            end
        end
    end
    
    if not done and #diged_inventory < 16 then
        table.insert(diged_inventory, temp_stack:to_table())
        done = true
    end
    
    return done
end

local miner_update_digpos = function(entity, data)

    local basepos = entity:getbasepos()
    local direction = miner_getdir(entity)
    local non_air_node_detected = false
    local digpositions = miner_get_nodes_to_dig(direction, basepos, data.digspec)
            
    for i, v in ipairs(digpositions) do
      local nodeat = core.get_node(v)
      
      if (nodeat.name ~= "air") then
          non_air_node_detected = true;
          --! use hand time as reference
          local digtime, wear, group = mob_miner_calc_digtime(hand_tooldef, nodeat.name)
          local used_tool = ""
          
          
          for i=1, #data.inventory.tools, 1 do
              if (data.inventory.tools[i] ~= nil) then
                local toolname = data.inventory.tools[i].name
                local tooldef = core.registered_tools[toolname]
            
                if ( tooldef ~= nil) then
                    local tooldigtime, toolwear, toolgroup = mob_miner_calc_digtime(tooldef, nodeat.name)
                    
                    if (digtime < 0) or 
                        ((tooldigtime > 0) and (tooldigtime < digtime)) then
                        used_tool = toolname
                        digtime = tooldigtime
                        wear = toolwear
                        group = toolgroup
                    end
                end
              end
          end
          
          if (digtime > 0) then
              data.control.digpos = v
              data.control.digtime = 0
              if (data.control.soundtime < 0) or (data.control.soundtime == nil) then
                  data.control.soundtime = SOUND_INTERVAL
              end
              data.control.used_tool = used_tool
              data.control.diggroup = group
              
              print("Using " .. used_tool .. " to dig " .. nodeat.name .. " in " .. digtime .. " seconds group is: " .. group)
              data.control.timetocomplete = digtime
              data.control.add_wear_oncomplete = wear
              break
          else
              local description = core.registered_nodes[nodeat.name].description
              if (description ~= nil) then
                core.chat_send_player(entity:owner(), data.name .. ": " .. 
                  S("I don't have a tool to dig ") .. S(description))
              end
          end
      end
    end

    return non_air_node_detected
end

local miner_complete_dig = function(data)

    local nodeat = core.get_node(data.control.digpos)
    local nodedef = core.registered_nodes[nodeat.name]
    local tooldef = core.registered_tools[data.control.used_tool]
          
    if (miner_add_wear(data.control.used_tool,
                   data.control.add_wear_oncomplete,
                   data.inventory.tools)) then
    
      core.set_node(data.control.digpos, {name="air"})
      
      local toadd = nodeat.name
      
      if (nodedef.drop ~= nil) then
        toadd = nodedef.drop
      end
      
      if (not miner_add_to_inventory(toadd,data.inventory.digged)) then
          core.add_item(data.control.digpos, toadd)
      end
    else
        print("BUG: Minder didn't find the tool we're supposed to digging with")
    end
    data.control.add_wear_on_complete = nil
    data.control.digpos = nil

end

local miner_onstep = function(entity, now, dtime)

    local mydata = entity:get_persistent_data()
    
    if (mydata.control.digstate == "digging") then

        local non_air_node_found = false
        if (mydata.control.digpos == nil) then
            non_air_node_found = miner_update_digpos(entity, mydata)
            
        else
            mydata.control.digtime = mydata.control.digtime + dtime
            mydata.control.soundtime = mydata.control.soundtime + dtime
        end
        
        if (not miner_is_dig_safe(mydata.control.digpos)) then
            --! TODO send message to owner
            core.chat_send_player(entity:owner(), mydata.name .. ": " .. 
              S("I won't continue to dig here there's something bad behind!"))
            mydata.control.digpos = nil
        end
        
        --! stop digging if we reached the requested depth
        if (mydata.control.digdepth <= 0) then
            mydata.control.digstate = "idle"
            print ("Miner: reached requested depth nothing to do setting to idle")
            entity:set_state("default")
            return
        end
        
        --! move ahead if we don't have any node left to dig
        if (mydata.control.digpos == nil) and (not non_air_node_found) then
            mydata.control.digdepth = mydata.control.digdepth -1
            
            if (miner_stepforward(entity)) then
                return
            end
        end
        --! stop digging if there ain't any node left
        if (mydata.control.digpos == nil) then
            mydata.control.digstate = "idle"
            mydata.control.soundtime = -1
            print ("Miner: no diggable node found setting to idle")
            entity:set_state("default")
            return
        end
        
        --! check if dig is completed
        if (mydata.control.digtime ~= nil) and 
            (mydata.control.timetocomplete ~= nil) and
            (mydata.control.digtime > mydata.control.timetocomplete) then
            
            miner_complete_dig(mydata)
        end
        
        if ((mydata.control.soundtime >= SOUND_INTERVAL) and (mydata.control.diggroup ~= nil)) then
            local soundspec = 
              { name="default_dig_" .. mydata.control.diggroup, gain=1.0, max_hear_distance=10 }
        
            sound.play(mydata.control.digpos, soundspec )
            mydata.control.soundtime = mydata.control.soundtime - SOUND_INTERVAL
        end
    end
end

local miner_rightclick = function(entity, player)
    local mydata = entity:get_persistent_data()

    if mydata.control.digstate == "idle" then
        miner_show_formspec(player:get_player_name(), entity, mydata )
    elseif mydata.control.digstate == "idle_nothing_to_dig" then
        miner_stepforward(entity)
        mydata.control.digstate = "idle"
    else
        mydata.control.digstate = "idle"
        entity:set_state("default")
    end
end

local miner_rightclick_label = function(entity)
    local mydata = entity:get_persistent_data()
    
    if mydata.control.digstate == "idle" then
      local basepos = entity:getbasepos()
      local direction = miner_getdir(entity)
      local nodestodig  = miner_get_diggable_nodes(miner_get_nodes_to_dig(direction,basepos, mydata.digspec))
      
      if #nodestodig ~= 0 then
        return S("give orders")
      else
        mydata.control.digstate = "idle_nothing_to_dig"
        return S("move ahead")
      end
    elseif (mydata.control.digstate == "idle_nothing_to_dig") then
        return S("move ahead")
    else
      return S("stop digging")
    end
end


local miner_formspec_handler = function(player, formname, fields)
    if formname:find("mobf_miner:") == 1 then
        local storageid =  formname:sub(12)
        local entity = mobf_global_data_get(storageid)
        
        if entity ~= nil then
            local mydata = entity:get_persistent_data()
            local minerinv = entity.dynamic_data.miner_formspec_data.tools_inventory
            
            local toolinv = minerinv:get_list("tools")
            
            mydata.inventory.tools = {}
            
            for i,v in ipairs (toolinv) do
                table.insert(mydata.inventory.tools, v:to_table())
            end
            
            
            local inventory = minerinv:get_list("digged")
            
            mydata.inventory.digged = {}
       
            for i,v in ipairs (inventory) do
                table.insert(mydata.inventory.digged, v:to_table())
            end
            
            if fields["btn_start_digging"] ~= nil and 
              tonumber(fields["te_digdepth"]) ~=  nil then
              
                mydata.control.digstate = "digging"
                mydata.control.digtime = 0
                mydata.control.digpos = nil
                mydata.control.digdepth = tonumber(fields["te_digdepth"])
              
                entity:set_state("digging")
            end
            
            local update_spec = false
            
            for x = 1, max_tunnel_size, 1 do
                for y = 1, max_tunnel_size, 1 do
                    if (fields["btn_tunnelshape_" .. x .. "x" .. y]) then
                        mydata.digspec[x][y] = not mydata.digspec[x][y]
                        update_spec = true
                    end
                end
            end
            
            
            if (update_spec) then
                miner_show_formspec(player:get_player_name(), entity, mydata)
            end
        end
    end
end

local miner_precatch_check = function(entity)
    
    local mydata = entity:get_persistent_data()
    
    for t1 = 1, #mydata.inventory.tools, 1 do
        if (mydata.inventory.tools[t1] ~= nil ) then
            core.chat_send_player(entity:owner(), mydata.name .. ":" .. 
                S("I've still got tools!"))
            return false
        end
    end
    
    for t1 = 1, #mydata.inventory.digged, 1 do
        if (mydata.inventory.digged[t1] ~= nil ) then
            core.chat_send_player(entity:owner(), mydata.name .. ": " .. 
                S("I've still got some nodes!"))
            return false
        end
    end
    return true
end

miner_prototype = {
		name="miner",
		modname="mob_miner",

		factions = {
			member = {
				"npc",
				"hireling"
				}
			},

		generic = {
					description= S("Miner"),
					base_health=40,
					kill_result="",
					armor_groups= {
						fleshy=20,
					},
					groups = miner_groups,
					envid="simple_air",
					stepheight = 0.51,
					
					custom_on_activate_handler = miner_activate,
					custom_on_step_handler = miner_onstep,
					
					on_rightclick_callbacks = {
            {
              handler = miner_rightclick,
              name = "miner_control_rightclick",
              visiblename = miner_rightclick_label
            }
          }
				},
		movement =  {
					guardspawnpoint = true,
					teleportdelay = 60,
					min_accel=0.3,
					max_accel=0.7,
					max_speed=1.5,
					min_speed=0.01,
					pattern="stop_and_go",
					canfly=false,
					follow_speedup=10,
					max_distance=0.2,
					},
		catching = {
					tool="animalmaterials:contract",
					consumed=true,
					can_be_cought = miner_precatch_check,
					},
		states = {
				{
				name = "default",
				movgen = "none",
				typical_state_time = 180,
				chance = 1.00,
				animation = "stand",
				state_mode = "auto",
				graphics_3d = {
					visual = "mesh",
					mesh = "character.b3d",
					textures = {"character.png"},
					collisionbox = {-0.3,-1.0,-0.3, 0.3,0.8,0.3},
					visual_size= {x=1, y=1},
					},
				},
        {
        name = "digging",
        movgen = "none",
        typical_state_time = 180,
        chance = 0,
        animation = "dig",
        state_mode = "user_def",
        graphics_3d = {
          visual = "mesh",
          mesh = "character.b3d",
          textures = {"character.png"},
          collisionbox = {-0.3,-1.0,-0.3, 0.3,0.8,0.3},
          visual_size= {x=1, y=1},
          },
        },
			},
		animation = {
		    stand = {
          start_frame = 0,
          end_frame   = 80,
          },
				walk = {
					start_frame = 168,
					end_frame   = 188,
					basevelocity = 18,
					},
        dig = {
          start_frame = 189,
          end_frame = 199,
        },
        digwalk = {
          start_frame = 200,
          end_frame = 220,
          basevelocity = 18
        }
			},
	}
	
minetest.register_on_player_receive_fields(miner_formspec_handler)

minetest.log("action","\tadding mob " .. miner_prototype.name)
mobf_add_mob(miner_prototype)
minetest.log("action","MOD: mob_miner mod                version " .. version .. " loaded")
