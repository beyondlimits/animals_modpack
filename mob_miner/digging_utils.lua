
function mob_miner_calc_digtime(tool, nodename)

    local nodedef = core.registered_nodes[nodename]
    
    if (nodedef == nil) then
        return -1
    end
    
    local candig = false
    local result_time = 7200
    local result_wear = 0
    local leveldiff = 0
    
    local nodelevel = 0
    if (nodedef.groups["level"] ~= nil) then
        nodelevel = nodedef.groups["level"]
    end
    
    print("Checking node: " .. nodename .. " level=" .. nodelevel)
    
    for groupcapname, parameters in pairs(tool.tool_capabilities.groupcaps) do
        
        local rating = 0
        if (nodedef.groups[groupcapname] ~= nil) then
            rating = nodedef.groups[groupcapname]
        end
        
        if parameters.times[rating] ~= nil then
            local leveldiff = parameters.maxlevel - nodelevel
            print("maxlevel: " .. parameters.maxlevel .. " Level: " .. nodelevel)
            local digtime = parameters.times[rating] / math.max(1, leveldiff)
            local wear = 65535 * (1 / parameters.uses / math.pow(3.0, leveldiff))
            print("digtime: " .. digtime .. " resulting from: " .. parameters.times[rating] .. " wear: " .. wear)
            candig = true
            if result_time == nil or (digtime < result_time) then
                result_time = digtime
                result_wear = wear
            end
        else
        end
    end
    
    if not candig then
        return -1
    end
    
    return result_time, result_wear
end

function miner_is_dig_safe(pos)

    return true
end


function miner_calc_wear(tooldef, node)

end