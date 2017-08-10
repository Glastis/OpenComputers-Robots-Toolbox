local robot = require("robot")
local side = require("sides")

local movement = {}

local function forward(amount, force)
	local i

	i = amount
	if not amount then
		i = 1
	end
	while i > 0 do
		if robot.forward() then
			i = i - 1
		elseif force then
			robot.swing()
			os.sleep(0.5)
		else
			os.sleep(2)
			print("Can't forward. Please move this shit.")
		end
	end
end
movement.forward = forward

local function up(amount, force)
	if not amount then
		amount = 1
	end
	while amount > 0 do
		if robot.up() then
			amount = amount - 1
    elseif force then
      robot.swingUp()
      os.sleep(0.5)
		else
			os.sleep(2)
			print("Can't go up. Please move this shit.")
		end
	end
end
movement.up = up

local function down(amount, force)
	if not amount then
		amount = 1
	end
	while amount > 0 do
		if robot.down() then
			amount = amount - 1
    elseif force then
      robot.swingDown()
      os.sleep(0.5)
		else
			os.sleep(2)
			print("Can't go down. Please move this shit.")
		end
	end
end
movement.down = down

local function move_orientation(orientation)
	if orientation == side.left then
		robot.turnLeft()
	elseif orientation == side.right then
		robot.turnRight()
	elseif orientation == side.back then
		robot.turnRight()
		robot.turnRight()
	end
end
movement.move_orientation = move_orientation

local function move_orientation_revert(orientation)
	if orientation == side.left then
		robot.turnRight()
	elseif orientation == side.right then
		robot.turnLeft()
	elseif orientation == side.back then
		robot.turnLeft()
		robot.turnLeft()
	end
end
movement.move_orientation_revert = move_orientation_revert

local function move(amount, orientation, force)
	if orientation then
		move_orientation(orientation)
		if orientation == side.up then
			up(amount, force)
		elseif orientation == side.down then
			down(amount, force)
		else
			forward(amount, force)
		end
		move_orientation_revert(orientation)
	else
		forward(amount, force)
	end
end
movement.move = move

local function turn_bool(bool)
	if bool then
		robot.turnLeft()
	else
		robot.turnRight()
	end
end
movement.turn_bool = turn_bool

local function turn_left()
	robot.turnLeft()
end
movement.turn_left = turn_left

local function turn_right()
	robot.turnRight()
end
movement.turn_left = turn_right

local function turn_back()
	robot.turnRight()
	robot.turnRight()
end
movement.turn_back = turn_back

return movement