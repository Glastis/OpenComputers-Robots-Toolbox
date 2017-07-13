local robot = require("robot")
local side = require("sides")
local component = require("component")

local config_filename = "dmp_whitelist.conf"
local offset = { x = 0, y = 0, z = 0 }
local errno = "unknown error"
local inventory_checker_counter = 0
local tree_field_size = 26

function equip_classic_axe()
	if not select_item("minecraft:wooden_axe") and not craft_axe() and not select_item("minecraft:wooden_axe") then
		print(errno)
		os.exit()
		return false
	end
	component.inventory_controller.equip()
	robot.select(1)
	return true
end
function unequip()
	if not select_empty_case() then
		clean_inventory()
		if not select_empty_case() then
			return false
		end
	end
	component.inventory_controller.equip()
	return true
end
function check_and_extract()
	local success, dir
	success, dir = check_tree()

	if success then
		cut_tree(dir)
	end
end
function back_to_origin()
	robot.turnRight()
	while offset.x > 0 do
		while not robot.forward() do
			smart_swing()
		end
		offset.x = offset.x - 1
	end
	robot.turnLeft()
	robot.turnLeft()
	while offset.x < 0 do
		while not robot.forward() do
			smart_swing()
		end
		offset.x = offset.x + 1
	end
	robot.turnRight()
	while offset.y < 0 do
		while not robot.up() do
			smart_swingUp()
		end
		offset.y = offset.y + 1
	end
	while offset.y > 0 do
		while not robot.down() do
			smart_swingDown()
		end
		offset.y = offset.y - 1
	end
	robot.turnLeft()
	robot.turnLeft()
	while offset.z < 0 do
		while not robot.forward() do
			smart_swing()
		end
		offset.z = offset.z + 1
	end
	robot.turnRight()
	robot.turnRight()
	while offset.z > 0 do
		while not robot.forward() do
			smart_swing()
		end
		offset.z = offset.z - 1
	end
end
function check_tree()
	local bloc

	bloc = component.geolyzer.analyze(side.left)
	if bloc.name == "minecraft:log" then
		return true, side.left
	end
	bloc = component.geolyzer.analyze(side.right)
	if bloc.name == "minecraft:log" then
		return true, side.right
	end
	bloc = component.geolyzer.analyze(side.up)
	if bloc.name == "minecraft:log" then
		return true, side.up
	end
	bloc = component.geolyzer.analyze(side.down)
	if bloc.name == "minecraft:log" then
		return true, side.down
	end
	bloc = component.geolyzer.analyze(side.back)
	if bloc.name == "minecraft:log" then
		return true, side.back
	end
	bloc = component.geolyzer.analyze(side.front)
	if bloc.name == "minecraft:log" then
		return true, side.front
	end
	return false, nil
end
function cut_tree(direction)
	local success, dir

	if direction == side.front then
		while not robot.forward() do
			smart_swing()
		end
		check_and_extract()
		robot.turnRight()
		robot.turnRight()
		while not robot.forward() do
			smart_swing()
		end
		robot.turnLeft()
		robot.turnLeft()
		elseif direction == side.left then
		robot.turnLeft()
		while not robot.forward() do
			smart_swing()
		end
		robot.turnRight()
		check_and_extract()
		robot.turnRight()
		while not robot.forward() do
			smart_swing()
		end
		robot.turnLeft()
		elseif direction == side.right then
		robot.turnRight()
		while not robot.forward() do
			smart_swing()
		end
		robot.turnLeft()
		check_and_extract()
		robot.turnLeft()
		while not robot.forward() do
			smart_swing()
		end
		robot.turnRight()
		elseif direction == side.up then
		while not robot.up() do
			smart_swingUp()
		end
		check_and_extract()
		while not robot.down() do
			smart_swingDown()
		end
		elseif direction == side.down then
		while not robot.down() do
			smart_swingDown()
		end
		check_and_extract()
		while not robot.up() do
			smart_swingUp()
		end
		elseif direction == side.back then
		robot.turnLeft()
		robot.turnLeft()
		while not robot.forward() do
			smart_swing()
		end
		robot.turnRight()
		robot.turnRight()
		check_and_extract()
		while not robot.forward() do
			smart_swing()
		end
	end
	check_and_extract()
end
function select_item(item)
    local slot = 1
	local size = robot.inventorySize()
	local data

	errno = "unknown error"
	data = component.inventory_controller.getStackInInternalSlot(robot.select())
	if data and data.name == item then
		return true
	end
    while slot <= size do
        data = component.inventory_controller.getStackInInternalSlot(slot)
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
	local sapling = false

	repack_item("minecraft:sapling")
	while slot <= robot.inventorySize() do
		data = component.inventory_controller.getStackInInternalSlot(slot)
		if data and (data.name == "minecraft:log" or data.name == "minecraft:planks" or data.name == "minecraft:stick" or data.name == "minecraft:wooden_axe") then
			repack_item(data.name)
			elseif not sapling and data.name == "minecraft:sapling" then
			sapling = true
			elseif data then
			robot.select(slot)
			robot.drop()
		end
		slot = slot + 1
	end
end
function smart_swing()
	if not equip_classic_axe() then
		return false
	end
	robot.swing()
	if not unequip() then
		return false
	end
	return true
end
function smart_swingUp()
	if not equip_classic_axe() then
		return false
	end
	robot.swingUp()
	if not unequip() then
		return false
	end
	return true
end
function smart_swingDown()
	if not equip_classic_axe() then
		return false
	end
	robot.swingDown()
	if not unequip() then
		return false
	end
	return true
end
function is_inventory_full()
	local slot = 1
	local data

	while slot <= robot.inventorySize() do
		data = component.inventory_controller.getStackInInternalSlot(slot)
		if not data then
			return false
		end
		slot = slot + 1
	end
	return true
end
function try_replant()
	select_item("minecraft:sapling")
	robot.turnLeft()
	robot.place()
	robot.turnRight()
	robot.turnRight()
	robot.place()
	robot.turnLeft()
end
function avance()
	if inventory_checker_counter == 5 and is_inventory_full() then
		clean_inventory()
		inventory_checker_counter = 0
		else
		inventory_checker_counter = inventory_checker_counter + 1
	end
	check_and_extract()
	try_replant()
	while not robot.forward() do
		smart_swing()
		os.sleep(0.5)
	end
	check_and_extract()
	try_replant()
end
function line(i)
	while i > 0 do
		avance()
		i = i - 1
	end
end
function turn(bool)
	if bool then
		robot.turnRight()
		else
		robot.turnLeft()
	end
end
function xor_bool(bool)
	if bool then
		return false
		else
		return true
	end
end
function core()
	local bool = true

	while true do
		check_saplings()
		line(tree_field_size)
		bool = xor_bool()
		drop_wood_in_chest()
		turn(bool)
		turn(bool)
		os.sleep(80)
	end
end
function drop_wood_in_chest()
	local curent

	repack_item("minecraft:log")
	if select_item("minecraft:log") then
		curent = robot.select()
		while select_next_item(curent + 1, "minecraft:log") do
			robot.drop()
			curent = robot.select()
		end
	end
end
function check_saplings()
	local current
	local data

	repack_item("minecraft:sapling")
	select_item("minecraft:sapling")
	data = component.inventory_controller.getStackInInternalSlot(robot.select())
	if data and data.size == 64 then
		current = robot.select()
		while select_next_item(current + 1, "minecraft:sapling") do
			robot.dropDown()
			robot.drop()
			current = robot.select()
		end
		return true
	end
	if data and data.size < 64 then
		if not get_item_from_chest("minecraft:sapling", side.bottom) then
			print("Can't get saplings from chest")
		end
	end
	if data and data.size == 0 then
		print("No saplings left")
		os.exit()
	end
	return true
end
function get_item_from_chest(item, side)
	local size = component.inventory_controller.getInventorySize(side)
	local slot = 1
	local data

	while size and slot <= size do
		data = component.inventory_controller.getStackInSlot(side, slot)
		if data and data.name == item then
			return component.inventory_controller.suckFromSlot(side, slot)
		end
		slot = slot + 1
	end
	return false
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
function select_item_out_of_workbench(item)
	local slot = 4
	local data
	local size = robot.inventorySize()

	while slot <= size do
		if slot == 5 or slot == 9 then
			slot = slot + 3
		end
		data = component.inventory_controller.getStackInInternalSlot(slot)
		if data and data.name == item then
			robot.select(slot)
			return true
		end
		slot = slot + 1
	end
	return false
end
function place_item_for_craft(item, to)
	local craft = {}

	craft[1] = 1
	craft[2] = 2
	craft[3] = 3
	craft[4] = 5
	craft[5] = 6
	craft[6] = 7
	craft[7] = 9
	craft[8] = 10
	craft[9] = 11
	if to > 9 then
		print("place_item_for_craft: slot can't be > than 9")
		os.exit()
	end
	if select_item_out_of_workbench(item) and robot.transferTo(craft[to], 1) then
		return true
	end
	return false
end
function craft_axe()
	local i = 1

	if empty_cases_amount() <= 10 then
		clean_inventory()
	end
	if empty_cases_amount() >= 10 and axe_materials() and free_crafting_table() then
		if place_item_for_craft("minecraft:stick", 5)  and place_item_for_craft("minecraft:stick", 8) and place_item_for_craft("minecraft:planks", 2) and place_item_for_craft("minecraft:planks", 3)  and place_item_for_craft("minecraft:planks", 6) then
			return component.crafting.craft()
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
function axe_materials()
	local wood, material = false, false
	local stick = 0
	local planks = 0
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
			elseif data and data.name == "minecraft:planks" then
			planks = planks + data.size
			if planks >= 3 then
				material = true
			end
		end
		slot = slot + 1
	end
	if not wood and planks >= 5 then
		return craft_sticks()
		elseif not wood and material then
		return craft_planks() and craft_sticks()
		elseif not wood and not material then
		return craft_planks() and craft_planks() and craft_sticks()
		elseif not material then
		return craft_planks()
	end
	return true
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
function init()
	if not unequip() then
		return false
	end
	return true
end

if init() then
	core()
end
