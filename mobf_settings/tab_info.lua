--------------------------------------------------------------------------------
-- Mob Framework Settings Mod by Sapier
--
-- You may copy, use, modify or do nearly anything except removing this
-- copyright notice.
-- And of course you are NOT allowed to pretend you have written it.
--
--! @file tab_info.lua
--! @brief settings gui for mobf
--! @copyright Sapier
--! @author Sapier
--! @date 2014-05-30
--
-- Contact sapier a t gmx net
--------------------------------------------------------------------------------

-------------------------------------------------------------------------------
local function get_formspec(tabview, name, tabdata)
	local adv_stats    = adv_spawning.get_statistics()
	local mobs_offline = spawning.total_offline_mobs()
	local statistics   = mobf_get_statistics()

	local retval =
		"label[0.75,0.25;Timesource:]" ..
		"label[2.75,0.25;" .. mobf_fixed_size_string(mobf_rtd.timesource,30) .. "]" ..
		"label[0.75,0.75;Mobs spawned by internal mapgen this session:]" ..
		"label[6,0.75;" .. string.format("%10d",mobf_rtd.total_spawned) .. "]" ..
		"label[0.75,1.25;Mobs spawned by adv_spawning this session:]" ..
		"label[6,1.25;" .. string.format("%10d",adv_stats.session.entities_created) .. "]" ..
		mobf_settings.printfac("Type",{current="cur count",maxabs="",max="max count"},2,"%s") ..
		"box[0.75,2.5;6.75,0.05;#FFFFFF]" ..
		mobf_settings.printfac("Active mobs",statistics.data.mobs,2.5,"%6d") ..
		mobf_settings.printfac("Offline mobs",{current=mobs_offline,maxabs="",max=-1},3,"%6d") ..
		mobf_settings.printfac("Jobs in queue",statistics.data.queue,3.5,"%6d") ..
		"label[0.75,5.0;Daytime:]" ..
		"label[2.5,5.0;" .. string.format("%5d",minetest.get_timeofday()*24000) .. "]"

	return retval
end

mobf_settings_tab_info = {
	name = "info",
	caption = fgettext("Info"),
	cbf_formspec = get_formspec
	}