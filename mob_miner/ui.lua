-------------------------------------------------------------------------------
-- Mob Framework Mod by Sapier
--
-- You may copy, use, modify or do nearly anything except removing this
-- copyright notice.
-- And of course you are NOT allow to pretend you have written it.
--
--! @file ui.lua
--! @brief ui functions for miner mob
--! @copyright Sapier
--! @author Sapier
--! @date 2015-12-20
--
-- Contact sapier a t gmx net
-------------------------------------------------------------------------------

mobf_assert_backtrace(core.global_exists("mob_miner"))

-- Boilerplate to support localized strings if intllib mod is installed.
local S
if (minetest.get_modpath("intllib")) then
  dofile(minetest.get_modpath("intllib").."/intllib.lua")
  S = intllib.Getter(minetest.get_current_modname())
else
  S = function ( s ) return s end
end


mob_miner.show_formspec = function(playername, entity, data)

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

    local digdepth = data.last_digdepth or 1

    local miner_formspec = "size[10,8.5;]" ..
      "label[1,0;"..S("Miner %s"):format(data.name).."]" ..
      "label[0,1;"..S("Tools:").."]"..
      "label[5,1;"..S("Tunnel shape:").."]" ..
      "label[0,2.5;"..S("Minerinventory:").."]"..
      "list[detached:" .. data.unique_entity_id .. ";tools;0,1.5;4,1;]" ..
      "list[detached:" .. data.unique_entity_id .. ";digged;0,3;4,3;]" ..
      "list[current_player;main;1,7.5;8,1;]" ..
      "field[0.25,7;2,0.5;te_digdepth;Dig depth;" .. digdepth .."]" ..
      "button_exit[2,6.8;2,0.25;btn_start_digging;" .. S("start digging") .. "]"
      
      for x = 1, MINER_MAX_TUNNEL_SIZE, 1 do
          for y = MINER_MAX_TUNNEL_SIZE, 1, -1 do
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


mob_miner.formspec_handler = function(player, formname, fields)
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
                mydata.control.digdepth = tonumber(fields["te_digdepth"]) or 0
                mydata.last_digdepth = mydata.control.digdepth
              
                entity:set_state("digging")
            end
            
            local update_spec = false
            
            for x = 1, MINER_MAX_TUNNEL_SIZE, 1 do
                for y = 1, MINER_MAX_TUNNEL_SIZE, 1 do
                    if (fields["btn_tunnelshape_" .. x .. "x" .. y]) then
                        mydata.digspec[x][y] = not mydata.digspec[x][y]
                        update_spec = true
                    end
                end
            end
            
            
            if (update_spec) then
                mob_miner.show_formspec(player:get_player_name(), entity, mydata)
            end
        end
    end
end

mob_miner.rightclick_control_label = function(entity)
    local mydata = entity:get_persistent_data()
    
    if mydata.control.digstate == "idle" then
      local basepos = entity:getbasepos()
      local direction = entity:getDirection()
      local nodestodig  = mob_miner.filter_nodes(
      						mob_miner.get_pos2dig_list(direction,basepos, mydata.digspec),
      						{ "air", "default:torch"}
      						)
      
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

mob_miner.rightclick_control = function(entity, player)
    local mydata = entity:get_persistent_data()

    if mydata.control.digstate == "idle" then
        mob_miner.show_formspec(player:get_player_name(), entity, mydata )
    elseif mydata.control.digstate == "idle_nothing_to_dig" then
        miner_stepforward(entity)
        mydata.control.digstate = "idle"
    else
        mydata.control.digstate = "idle"
        entity:set_state("default")
    end
end