--------------------------------------------------------------------------------
-- Mob Framework Settings Mod by Sapier
--
-- You may copy, use, modify or do nearly anything except removing this
-- copyright notice.
-- And of course you are NOT allowed to pretend you have written it.
--
--! @file tab_statistics.lua
--! @brief settings gui for mobf
--! @copyright Sapier
--! @author Sapier
--! @date 2014-05-30
--
-- Contact sapier a t gmx net
--------------------------------------------------------------------------------

---------------------------------------------------------------------------------
local function get_formspec(tabview, name, tabdata)
	local adv_stats  = adv_spawning.get_statistics()
	local statistics = mobf_get_statistics()

	local retval =
		mobf_settings.printfac("Facility",
			{
				current = "Current",
				maxabs  = "Abs.Max (ms)",
				max     = "Maximum"
			},
			"0","%s") ..
		"box[0.75,0.5;6.75,0.05;#FFFFFF]" ..
		mobf_settings.printfac("Total",          statistics.data.total,       "0.5", "%2.2f%%") ..
		mobf_settings.printfac("Onstep",         statistics.data.onstep,      "1",   "%2.2f%%") ..
		mobf_settings.printfac("Job processing", statistics.data.queue_load,  "1.5", "%2.2f%%") ..
		mobf_settings.printfac("ABM",            statistics.data.abm,         "2",   "%.2f%%") ..
		mobf_settings.printfac("MapGen",         statistics.data.mapgen,      "2.5", "%2.2f%%") ..
		mobf_settings.printfac("Spawn onstep",   statistics.data.spawn_onstep,"3",   "%2.2f%%") ..
		mobf_settings.printfac("Activate",       statistics.data.activate,    "3.5", "%2.2f%%") ..
		mobf_settings.printfac("User 1",         statistics.data.user_1,      "6.5", "%2.2f%%") ..
		mobf_settings.printfac("User 2",         statistics.data.user_2,      "7",   "%2.2f%%") ..
		mobf_settings.printfac("User 3",         statistics.data.user_3,      "7.5", "%2.2f%%") ..
		mobf_settings.printfac("Adv.Spawning",
			{
				current = adv_stats.load.cur,
				maxabs  = adv_stats.step.max,
				max     = adv_stats.load.max
			},
			"4","%2.2f%%")

	return retval
end

mobf_settings_tab_statistics = {
	name = "statistics",
	caption = fgettext("Statistics"),
	cbf_formspec = get_formspec
	}