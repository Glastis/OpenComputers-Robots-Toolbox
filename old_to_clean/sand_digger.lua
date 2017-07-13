local robot = require("robot")
local side = require("sides")
local component = require("component")

local robot = require("robot")
local side = require("sides")
local component = require("component")

local errno = "unknown error"

function equip_classic_pickaxe()
	while true do
		if not select_item("minecraft:stone_pickaxe") and not select_item("minecraft:iron_pickaxe") and not craft_pickaxe() then
			print(errno)
			print("Waiting user before continuing job...")
			io.read()
	elseif not select_item("minecraft:stone_pickaxe") and not select_item("minecraft:iron_pickaxe") then
		print(errno)
		print("Waiting user before continuing job...")
			io.read()
	else
			component.inventory_controller.equip()
			robot.select(1)
			return true
		end
	end
end
function unequip()
	if not select_empty_case() then
		clean_inventory()
		if not select_empty_case() then
			return false
		end
	end
	component.inventory_controller.equip()
	robot.select(1)
	return true
end
function select_item(item)
    local slot = 1
	local size = robot.inventorySize()

	errno = "unknown error"
    while slot <= size do
        local data = component.inventory_controller.getStackInInternalSlot(slot)
        if data and data.name == item then
            robot.select(slot)
            return true
		end
        slot = slot + 1
	end
	errno = "Can't select: " .. item
    return false
end
function select_next_item(slot, item)
	local data
	local size = robot.inventorySize()

	while slot <= robot.inventorySize() do
		data = component.inventory_controller.getStackInInternalSlot(slot)
		if data and data.name == item then
			robot.select(slot)
			return true
		end
		slot = slot + 1
	end
	return false
end
function repack_item(item)
	local slot = 1
	local data
	local size = robot.inventorySize()

	while slot < size do
		data = component.inventory_controller.getStackInInternalSlot(slot)
		if not data or (data.name == item and data.size < 64) then
			if select_next_item(slot + 1, item) then
				robot.transferTo(slot)
				data = component.inventory_controller.getStackInInternalSlot(slot)
				else
				return true
			end
		end
		if data and ((data.name == item and data.size == 64) or data.name ~= item) then
			slot = slot + 1
		end
	end
	return true
end
function clean_inventory()
	local slot = 1
	local data
	local cobble = false

	repack_item("minecraft:cobblestone")
	while slot <= robot.inventorySize() do
		data = component.inventory_controller.getStackInInternalSlot(slot)
		if data and (data.name == "minecraft:sand" or data.name == "minecraft:stone_pickaxe" or data.name == "minecraft:log" or data.name == "minecraft:planks" or data.name == "minecraft:stick") then
			repack_item(data.name)
			elseif data and not cobble and data.name == "minecraft:cobblestone" then
			cobble = true
			elseif data then
			robot.select(slot)
			robot.drop()
		end
		slot = slot + 1
	end
end
function smart_swing()
	local bloc

	bloc = component.geolyzer.analyze(side.front)
	if bloc.name == "minecraft:dirt" or bloc.name == "minecraft:sand" or bloc.name == "minecraft:grass" then
		unequip()
	elseif not equip_classic_pickaxe() then
			return false
	end
	robot.swing()
	if not unequip() then
		return false
	end
	return true
end
function smart_swingUp()
	local bloc

	bloc = component.geolyzer.analyze(side.top)
	if bloc.name == "minecraft:dirt" or bloc.name == "minecraft:sand" or bloc.name == "minecraft:grass" then
		unequip()
	elseif not equip_classic_pickaxe() then
			return false
	end
	robot.swingUp()
	if not unequip() then
		return false
	end
	return true
end
function smart_swingDown()
	local bloc

	bloc = component.geolyzer.analyze(side.bottom)
	if bloc.name == "minecraft:dirt" or bloc.name == "minecraft:sand" or bloc.name == "minecraft:grass" then
		unequip()
	elseif not equip_classic_pickaxe() then
			return false
	end
	robot.swingDown()
	if not unequip() then
		return false
	end
	return true
end
function is_inventory_full()
	local slot = robot.inventorySize()
	local data

	while slot > 0 do
		data = component.inventory_controller.getStackInInternalSlot(slot)
		if not data then
			return false
		end
		slot = slot - 1
	end
	return true
end
function push_item_after_slot(from)
	local slot = from + 1

	robot.select(from)
	while slot < robot.inventorySize() and component.inventory_controller.getStackInInternalSlot(slot) do
		slot = slot + 1
	end
	if slot < robot.inventorySize() and robot.transferTo(slot) then
		return true
	end
	return false
end
function free_crafting_table()
	local slot = 1
	local data

	while slot <= 11 do
		if slot ~= 4 and slot ~= 8 then
			if component.inventory_controller.getStackInInternalSlot(slot) and not push_item_after_slot(slot) then
				return false
			end
		end
		slot = slot + 1
	end
	return true
end
function craft_pickaxe()
	local material
	local i = 1

	if empty_cases_amount() <= 10 then
		clean_inventory()
	end
	if empty_cases_amount() >= 10 and pickaxe_materials() and free_crafting_table() then
		if select_item("minecraft:iron_ingot") then
			material = "minecraft:iron_ingot"
			elseif select_item("minecraft:cobblestone") then
			material = "minecraft:cobblestone"
			else
			return false
		end
		if select_next_item(1, "minecraft:stick") and robot.transferTo(6, 1) and select_item("minecraft:stick") and (robot.select() ~= 6 or select_next_item(7, "minecraft:stick")) and robot.transferTo(10, 1) then
			while i <= 3 do
				if not select_next_item(4, material) or not robot.transferTo(i, 1) then
					return false
				end
				i = i + 1
			end
			if material == "minecraft:iron_ingot" then
				return component.crafting.craft(), "minecraft:iron_pickaxe"
				elseif material == "minecraft:iron_ingot" then
				return component.crafting.craft(), "minecraft:stone_pickaxe"
			end
			return component.crafting.craft(), nil
		end
	end
	errno = "No crafing components or no empty space"
	return false
end
function craft_sticks()
	if not free_crafting_table() then
		return false
	end
	if not select_item("minecraft:planks") and not craft_planks() then
		return false
	end
	if not free_crafting_table() then
		return false
	end
	if select_item("minecraft:planks") then
		robot.transferTo(1, 1)
		if select_next_item(3, "minecraft:planks") then
			robot.transferTo(5, 1)
			else
			return false
		end
		return component.crafting.craft(1)
	end
	return false

end
function craft_planks()
	if not free_crafting_table() or not select_item("minecraft:log") then
		return false
	end
	if robot.transferTo(1, 1) then
		return component.crafting.craft(1)
	end
	return false
end
function pickaxe_materials()
	local wood, material = false, false
	local stick = 0
	local data
	local inv_size = robot.inventorySize()
	local slot = 1

	while slot <= inv_size and (not wood or not material) do
		data = component.inventory_controller.getStackInInternalSlot(slot)
		if data and not wood and data.name == "minecraft:stick" then
			stick = data.size + stick
			if stick >= 2 then
				wood = true
			end
			elseif data and not material and (data.name == "minecraft:cobblestone" or data.name == "minecraft:iron_ingot") and data.size >= 3 then
			material = true
		end
		slot = slot + 1
	end
	if material and not wood then
		return craft_sticks()
		elseif wood and material then
		return true
	end
	return false
end
function empty_cases_amount()
	local slot = 1
	local empty_slots = 0
	local size = robot.inventorySize()

	while slot <= size do
        if not component.inventory_controller.getStackInInternalSlot(slot) then
			empty_slots = empty_slots + 1
		end
        slot = slot + 1
	end
	return empty_slots
end
function select_empty_case()
	local slot = 1

	while slot <= robot.inventorySize() do
        if not component.inventory_controller.getStackInInternalSlot(slot) then
			robot.select(slot)
			return true
		end
        slot = slot + 1
	end
	return false
end
function is_blocs_at_top()
	local arr = component.geolyzer.scan(0, 0)
	local x = 34

	while x <= 64 do
		if arr[x] and arr[x] ~= 0 then
			return true, x - 32
		end
		x = x + 1
	end
	return false
end
function check_column_bottom()
	local bloc
	local offset = 0

	while true do
		bloc = component.geolyzer.analyze(side.bottom)
		if bloc and (bloc.name == "minecraft:sand" or bloc.name == "minecraft:dirt") then
			smart_swingDown()
			while not robot.down() do
				os.sleep(1)
				smart_swingDown()
			end
			offset = offset + 1
		elseif offset > 0 then
			while not robot.up() do
				os.sleep(1)
				smart_swingUp()
			end
			offset = offset - 1
		else
			return true
		end
	end
end
function check_column_up(y)
	local bloc

	while robot.up() and is_blocs_at_top() do
		robot.suckUp()
		y = y + 1
	end
	bloc = component.geolyzer.analyze(side.up)
	if not bloc and is_blocs_at_top() then
		sleep(1)
		return check_column_up(y)
	end
	if bloc then
		smart_swingUp()
		robot.suckUp()
	end
	if is_blocs_at_top() then
		return check_column_up(y)
	end
	while y > 0 do
		if robot.down() then
			y = y - 1
		else
			os.sleep(1)
			smart_swingDown()
		end
	end
end
function check_column()
	check_column_bottom()
	if is_blocs_at_top() then
		check_column_up(0)
	end
end
function turn_bool(bool)
	if bool then
		robot.turnRight()
	else
		robot.turnLeft()
	end
end
function avance()
	local count

	robot.suck()
	robot.turnLeft()
	robot.suck()
	robot.turnRight()
	robot.turnRight()
	robot.suck()
	robot.turnLeft()
	check_column()
	count = 0
	check_column()
	robot.turnRight()
	robot.turnRight()
	robot.suck()
	robot.turnLeft()
	robot.turnLeft()
	while not robot.forward() do
		smart_swing()
		count = count + 1
		if count > 10 then
			os.sleep(1)
		end
	end
	if is_inventory_full() then
		clean_inventory()
	end
end
function line(x)
	while x > 0 do
		avance()
		x = x - 1
	end
end
function xor_bool(bool)
	if bool then
		return false
	end
	return true
end
function main(x, z, dir)
	local bool = false

	if dir == "right" then
		bool = true
	end
	while z > 0 do
		line(x)
		turn_bool(bool)
		avance()
		turn_bool(bool)
		bool = xor_bool(bool)
		z = z - 1
	end
end
local lenght, amount, direction

print("Numbers of blocs to mine in front of ?")
lenght = tonumber(io.read())
print("Numbers of blocs to mine in a side ?")
amount = tonumber(io.read())
if amount > 1 then
	print("To the left or right ?")
	direction = io.read()
	if direction ~= "left" and direction ~= "right" then
		print("Unknown direction: " .. direction)
		os.exit()
	end
	else
	direction = "right"
end
main(lenght, amount, direction)
