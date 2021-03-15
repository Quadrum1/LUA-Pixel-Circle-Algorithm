--[[ 
LUA pixel circle algorithm -- by Quadrum

Returns array with tables of positions for a circle
All return values will be rounded integers

Use circle_circumference(radius), to get an array of positions, centered on x=0,y=0, for the outer area of the circle.
Use circle_volume(radius), to get an array of positions, centered on x=0,y=0, for the full area of the circle.

Position table --> {x=0,y=0}
]]



---Gets position at 'degree' on a circle with 'radius' using sin and cos
---@param {number} radius - Radius of circle
---@param {number} degree - Degree to get position
local function get_position(radius, degree)
	local x = math.floor(math.cos(math.rad(degree))*radius + 0.5)
	local y = math.floor(math.sin(math.rad(degree))*radius + 0.5)
	return {x=x, y=y}
end


---Removes duplicate values from an array full of positions
---@param {array} array - Array full of positions
---@returns {array} - Array full of positions without any repetitions
local function clean_table(array)
	local exists = {}
	local cleaned = {}
	
	for _,degree in pairs(array) do 
		if not exists[tostring(degree.x)..tostring(degree.y)] then
		
			-- Marks this position as being in the array
			exists[tostring(degree.x)..tostring(degree.y)] = true
			table.insert(cleaned,degree)
		end
	end
	
	return cleaned
end


--- Returns array of all positions between pos1 and pos2, not including pos1 and pos2
---@param {table} pos1 - Position 1 
---@param {table} pos2 - Position 2 

local function get_between(pos1, pos2)
	-- pos1 and pos2 are the same positions
	if pos1.x - pos2.x == 0 and pos1.y - pos2.y == 0 then return {} end
	
	-- Checks which way to count
	local steps = {x=1,y=1}
	if pos1.x > pos2.x then steps.x = -1 end
	if pos1.y > pos2.y then steps.y = -1 end
	
	
	local values_between = {}
	
	-- Take each position between pos1 and pos2 and add it to the array
	for _x = pos1.x, pos2.x, steps.x do
		for _y = pos1.y, pos2.y, steps.y do
			-- If not pos1 or pos2, adds it to array
			if not ((_x == pos1.x and _y == pos1.y) or (_x == pos2.x and _y == pos2.y)) then
				table.insert(values_between,{x=_x,y=_y})
			end
		end
	end

	return values_between
end

Public = {}



---Returns an array of positions on the outer edge of a circle
---@param {number} radius - Radius of circle
---@returns {array} - Positions of outer circle

function Public.circle_circumference(radius)
	-- A radius of <1 is just the starting position
	if radius < 1 then return {{x=0,y=0}} end
	
	local circle = {}
	
	-- Changing this will quicken the operation, but also induce more error
	-- Lowering this value will lead to more accurate results and more calculations
	local step = 1
	
	-- Check each degree of the circle
	for i = 1, 360, step do
		local pos = get_position(radius,i)
		table.insert(circle,pos)
	end
	
	-- Remove possible duplicate values
	circle = clean_table(circle)
	
	return circle
end



---Returns an array of positions of a full circle
---@param {number} radius - Radius of circle
---@returns {array} - Positions of full circle

function Public.circle_volume(radius)
	if radius < 1 then return {{x=0,y=0}} end
	-- Gets outer bounds
	local circle_c = Public.circle_circumference(radius)
	local circle_v = circle_c
	
	-- Checks each outer position
	for i = 1, #circle_c do
		local pos1 = circle_c[i]
		
		-- Mirror position at x axis
		local pos2 = {x=-1*pos1.x,y=1*pos1.y}
		
		-- Get connection points between pos1 and mirrored pos1 (Area in the circle)
		local connections = get_between(pos1,pos2)
		
		-- Add those connections to volume circle array
		for _,v in pairs(connections) do 
			table.insert(circle_v, v)
		end
	end
	
	-- Remove possible duplicate values
	circle_v = clean_table(circle_v)
	
	return circle_v
end

return Public
