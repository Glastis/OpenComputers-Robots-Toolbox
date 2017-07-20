local robot = require("robot")
local side = require("sides")

function forward(amount, force)
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

function up(amount, force)
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

function down(amount, force)
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

function move_orientation(orientation)
	if orientation == side.left then
		robot.turnLeft()
	elseif orientation == side.right then
		robot.turnRight()
	elseif orientation == side.back then
		robot.turnRight()
		robot.turnRight()
	end
end

function move_orientation_revert(orientation)
	if orientation == robot.left then
		robot.turnRight()
	elseif orientation == robot.right then
		robot.turnLeft()
	elseif orientation == robot.back then
		robot.turnLeft()
		robot.turnLeft()
	end
end

function move(amount, orientation, force)
	if orientation then
		move_orientation(orientation)
		if orientation == up then
			up(amount, force)
		elseif orientation == down then
			down(amount, force)
		else
			forward(amount, force)
		end
		move_orientation_revert(orientation)
	else
		forward(amount, force)
	end
end
