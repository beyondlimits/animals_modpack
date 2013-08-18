-------------------------------------------------------------------------------
-- Mob Framework Mod by Sapier
-- 
-- You may copy, use, modify or do nearly anything except removing this
-- copyright notice. 
-- And of course you are NOT allow to pretend you have written it.
--
--! @file job_queue.lua
--! @brief asynchronous job queue
--! @copyright Sapier
--! @author Sapier
--! @date 2013-08-18
--
-- Contact sapier a t gmx net
-------------------------------------------------------------------------------


mobf_job_queue = {}

mobf_job_queue.queue = {}
mobf_job_queue.current_interval = 0
mobf_job_queue.queue_interval = 0.040

-------------------------------------------------------------------------------
-- name: add_job(job)
--
--! @brief queue a job to asynchronous job handling
--
--! @param job to do
-------------------------------------------------------------------------------
function mobf_job_queue.add_job(job)
	table.insert(mobf_job_queue.queue, job)
	statistics.data.queue.maxabs = MAX(statistics.data.queue.maxabs,#mobf_job_queue.queue)
end

-------------------------------------------------------------------------------
-- name: process(dtime)
--
--! @brief job processing handler
--
--! @param dtime time since last call
-------------------------------------------------------------------------------
function mobf_job_queue.process(dtime)
	--print("Queue handler: " .. dtime .. 
	--		" CI: " .. mobf_job_queue.current_interval ..
	--		" QI: " .. mobf_job_queue.queue_interval)
	mobf_job_queue.current_interval = mobf_job_queue.current_interval + dtime
	
	local processing_enabled = minetest.world_setting_get("mobf_queue_processing")
	
	if mobf_job_queue.current_interval < mobf_job_queue.queue_interval or 
		not minetest.world_setting_get("mobf_queue_processing") then
		return
	end
	
	mobf_job_queue.current_interval = 0

	local starttime = mobf_get_time_ms()
	local jobs_processed = 0
	
	local jobs_before = #mobf_job_queue.queue
	
	while (#mobf_job_queue.queue > 0) and 
			(mobf_get_time_ms() - starttime) < 20 do
		local action = table.remove(mobf_job_queue.queue)
		
		mobf_assert_backtrace(type(action.callback) == "function")
		action.callback(action.data)
		jobs_processed = jobs_processed + 1
	end

--	print("Queue processed " .. jobs_processed .. " of " .. jobs_before 
--			.. " jobs in " .. string.format("%4.2f",(mobf_get_time_ms() - starttime)) .. "ms")
end


--register async handler to global step
minetest.register_globalstep(mobf_job_queue.process)
