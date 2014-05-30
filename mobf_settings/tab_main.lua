--------------------------------------------------------------------------------
-- Mob Framework Settings Mod by Sapier
--
-- You may copy, use, modify or do nearly anything except removing this
-- copyright notice.
-- And of course you are NOT allowed to pretend you have written it.
--
--! @file tab_main.lua
--! @brief settings gui for mobf
--! @copyright Sapier
--! @author Sapier
--! @date 2014-05-30
--
-- Contact sapier a t gmx net
--------------------------------------------------------------------------------

local function get_formspec(tabview, name, tabdata)
	return "label[0.75,0.25;" ..
		fgettext("Add some description and helpfull information here.")
		.. "]"
end

mobf_settings_tab_main = {
	name = "main",
	caption = fgettext("Main"),
	cbf_formspec = get_formspec
	}