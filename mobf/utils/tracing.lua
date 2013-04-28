-------------------------------------------------------------------------------
-- Mob Framework Mod by Sapier
-- 
-- You may copy, use, modify or do nearly anything except removing this
-- copyright notice. 
-- And of course you are NOT allow to pretend you have written it.
--
--! @file tracing.lua
--! @brief generic functions used in many different places
--! @copyright Sapier
--! @author Sapier
--! @date 2013-02-04
--!
-- Contact sapier a t gmx net
-------------------------------------------------------------------------------

--! @defgroup gen_func Generic functions
--! @brief functions for various tasks
--! @ingroup framework_int
--! @{

callback_statistics = {}

-------------------------------------------------------------------------------
-- name: mobf_warn_long_fct(starttime,fctname,facility)
--
--! @brief alias to get current time
--
--! @param starttime time fct started
--! @param fctname name of function
--! @param facility name of facility to add time to
--
--! @return current time in seconds
-------------------------------------------------------------------------------
function mobf_warn_long_fct(starttime,fctname,facility)
	local currenttime = mobf_get_time_ms()
	local delta = currenttime - starttime
	
	if minetest.setting_getbool("mobf_enable_socket_trace_statistics") then
		if facility == nil then
			facility = "generic"
		end
		
		if callback_statistics[facility] == nil then
			callback_statistics[facility] = {
				upto_005ms = 0,
				upto_010ms = 0,
				upto_020ms = 0,
				upto_050ms = 0,
				upto_100ms = 0,
				upto_200ms = 0,
				more       = 0,
				valcount   = 0,
				sum        = 0,
				last_time  = 0,
			}
		end
		
		callback_statistics[facility].valcount = callback_statistics[facility].valcount +1
		callback_statistics[facility].sum = callback_statistics[facility].sum + delta
		
		if callback_statistics[facility].valcount == 1000 then
			callback_statistics[facility].valcount = 0
			local deltatime = currenttime - callback_statistics[facility].last_time
			callback_statistics[facility].last_time = currenttime
			
			minetest.log(LOGLEVEL_ERROR,"Statistics for: " .. facility .. ": " .. 
										callback_statistics[facility].upto_005ms .. "," ..
										callback_statistics[facility].upto_010ms .. "," ..
										callback_statistics[facility].upto_020ms .. "," ..
										callback_statistics[facility].upto_050ms .. "," ..
										callback_statistics[facility].upto_100ms .. "," ..
										callback_statistics[facility].upto_200ms .. "," ..
										callback_statistics[facility].more .. 
										" (".. callback_statistics[facility].sum .. " / " .. deltatime .. ") " ..
										tostring(math.floor((callback_statistics[facility].sum/deltatime) * 100)) .. "%")
										
			callback_statistics[facility].sum = 0
		end
		
		if delta < 5 then
			callback_statistics[facility].upto_005ms = callback_statistics[facility].upto_005ms +1
			return
		end
		if delta < 10 then
			callback_statistics[facility].upto_010ms = callback_statistics[facility].upto_010ms +1
			return
		end
		if delta < 20 then
			callback_statistics[facility].upto_020ms = callback_statistics[facility].upto_020ms +1
			return
		end
		if delta < 50 then
			callback_statistics[facility].upto_050ms = callback_statistics[facility].upto_050ms +1
			return
		end
		if delta < 100 then
			callback_statistics[facility].upto_100ms = callback_statistics[facility].upto_100ms +1
			return
		end
		
		if delta < 200 then
			callback_statistics[facility].upto_200ms = callback_statistics[facility].upto_200ms +1
			return
		end
		
		callback_statistics[facility].more = callback_statistics[facility].more +1
	end
	
	if delta >200 then
		minetest.log(LOGLEVEL_ERROR,"MOBF: function " .. fctname .. " took too long: " .. delta .. " ms")
	end
end

-------------------------------------------------------------------------------
-- name: mobf_bug_warning()
--
--! @brief make bug warnings configurable
--
--! @param level bug severity level to use for minetest.log
--! @param text data to print to log
-------------------------------------------------------------------------------
function mobf_bug_warning(level,text)
	if minetest.setting_getbool("mobf_log_bug_warnings") then
		minetest.log(level,text)
	end
end

--!@}