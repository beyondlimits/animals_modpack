-------------------------------------------------------------------------------
-- Mob Framework Mod by Sapier
-- 
-- You may copy, use, modify or do nearly anything except removing this
-- copyright notice. 
-- And of course you are NOT allowed to pretend you have written it.
--
--! @file error_handling.lua
--! @brief code required to do error handling
--! @copyright Sapier
--! @author Sapier
--! @date 2013-05-010
--!
-- Contact sapier a t gmx net
-------------------------------------------------------------------------------
--
-------------------------------------------------------------------------------
-- name: mobf_assert_backtrace(value)
--
--! @brief assert in case value is false
--
--! @param value to evaluate
-------------------------------------------------------------------------------
function mobf_assert_backtrace(value)
	if value == false then
		print(debug.traceback("Current Callstack:\n"))
		assert(value)
	end
end