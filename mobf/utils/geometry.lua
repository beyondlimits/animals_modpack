-------------------------------------------------------------------------------
-- Mob Framework Mod by Sapier
-- 
-- You may copy, use, modify or do nearly anything except removing this
-- copyright notice. 
-- And of course you are NOT allow to pretend you have written it.
--
--! @file geometry.lua
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

-------------------------------------------------------------------------------
-- name: mobf_calc_distance(pos1,pos2)
--
--! @brief calculate 3d distance between to points
--
--! @param pos1 first position
--! @param pos2 second position
--! @retval scalar value, distance
-------------------------------------------------------------------------------
function mobf_calc_distance(pos1,pos2)
	return math.sqrt( 	math.pow(pos1.x-pos2.x,2) + 
				math.pow(pos1.y-pos2.y,2) +
				math.pow(pos1.z-pos2.z,2))
end

-------------------------------------------------------------------------------
-- name: mobf_calc_distance_2d(pos1,pos2)
--
--! @brief calculate 2d distance between to points
--
--! @param pos1 first position
--! @param pos2 second position
--! @return scalar value, distance
-------------------------------------------------------------------------------
function mobf_calc_distance_2d(pos1,pos2)
	return math.sqrt( 	math.pow(pos1.x-pos2.x,2) + 
				math.pow(pos1.z-pos2.z,2))
end

-------------------------------------------------------------------------------
-- name: mobf_calc_scalar_speed(speedx,speedz)
--
--! @brief calculate scalar speed
--
--! @param speedx speed in direction x
--! @param speedz speed in direction z
--
--! @return scalar speed value
-------------------------------------------------------------------------------
function mobf_calc_scalar_speed(speedx,speedz)
	return math.sqrt(math.pow(speedx,2)+
	                          math.pow(speedz,2))
end

-------------------------------------------------------------------------------
-- name: mobf_calc_vector_components(dir_radians,absolute_speed)
--
--! @brief calculate calculate x and z components of a directed speed
--
--! @param dir_radians direction of movement radians
--! @param absolute_speed speed in direction
--
--! @return {x,z}
-------------------------------------------------------------------------------
function mobf_calc_vector_components(dir_radians,absolute_speed)

	local retval = {x=0,z=0}
	
	retval.x = absolute_speed * math.cos(dir_radians)
	retval.z = absolute_speed * math.sin(dir_radians)

	return retval
end

-------------------------------------------------------------------------------
-- name: mobf_get_direction(pos1,pos2)
--
--! @brief get normalized direction from pos1 to pos2
--
--! @param pos1 source point
--! @param pos2 destination point
--! @return xyz direction
-------------------------------------------------------------------------------
function mobf_get_direction(pos1,pos2)

	local x_raw = pos2.x -pos1.x
	local y_raw = pos2.y -pos1.y
	local z_raw = pos2.z -pos1.z


	local x_abs = math.abs(x_raw)
	local y_abs = math.abs(y_raw)
	local z_abs = math.abs(z_raw)

	if 	x_abs >= y_abs and
		x_abs >= z_abs then

		y_raw = y_raw * (1/x_abs)
		z_raw = z_raw * (1/x_abs)

		x_raw = x_raw/x_abs

	end

	if 	y_abs >= x_abs and
		y_abs >= z_abs then


		x_raw = x_raw * (1/y_abs)
		z_raw = z_raw * (1/y_abs)

		y_raw = y_raw/y_abs

	end

	if 	z_abs >= y_abs and
		z_abs >= x_abs then

		x_raw = x_raw * (1/z_abs)
		y_raw = y_raw * (1/z_abs)

		z_raw = z_raw/z_abs

	end

	return {x=x_raw,y=y_raw,z=z_raw}

end

-------------------------------------------------------------------------------
-- name: mobf_calc_yaw(x,z)
--
--! @brief calculate radians value of a 2 dimendional vector
--
--! @param x vector component 1
--! @param z vector component 2
--
--! @return radians value
-------------------------------------------------------------------------------
function mobf_calc_yaw(x,z)
	local direction = math.atan2(z,x)
				
	while direction < 0 do
		direction = direction + (2* math.pi)
	end
	
	while direction > (2*math.pi) do
		direction = direction - (2* math.pi)
	end
				
	return direction
end

--!@}