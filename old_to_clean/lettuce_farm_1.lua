local robot = require("robot")
local side = require("sides")
local component = require("component")
local shell = require("shell")
local computer = require("computer")

local field_size_x = 34
local field_size_z = 9

-- Robot movement encapsulations

function forward(amount)
	local i

	i = amount
	if not amount then
		i = 1
	end
	while i > 0 do
		if robot.forward() then
			i = i - 1
		else
			os.sleep(2)
			print("Can't forward. Please move this shit.")
		end
	end
end

function up(amount)
	if not amount then
		amount = 1
	end
	while amount > 0 do
		if robot.up() then
			amount = amount - 1
		else
			os.sleep(2)
			print("Can't go up. Please move this shit.")
		end
	end
end

function down(amount)
	if not amount then
		amount = 1
	end
	while amount > 0 do
		if robot.down() then
			amount = amount - 1
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

function move(amount, orientation)
	if orientation then
		move_orientation(orientation)
		if orientation == up then
			up(amount)
		elseif orientation == down then
			down(amount)
		else
			forward(amount)
		end
		move_orientation_revert(orientation)
	else
		forward(amount)
	end
end


-- Inventory gestion functions

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

function select_item(item, meta)
    local slot = 1
	local size = robot.inventorySize()

    while slot <= size do
        local data = component.inventory_controller.getStackInInternalSlot(slot)
        if data and data.name == item and (not meta or data.damage == meta) then
            robot.select(slot)
            return true
		end
        slot = slot + 1
	end
    return false
end

function select_next_item(slot, item, meta)
	local data
	local size = robot.inventorySize()

	while slot <= robot.inventorySize() do
		data = component.inventory_controller.getStackInInternalSlot(slot)
		if data and data.name == item and (not meta or meta == data.damage) then
			robot.select(slot)
			return true
		end
		slot = slot + 1
	end
	return false
end

function repack_item(item, meta)
	local slot = 1
	local data

	if item == "minecraft:stone_pickaxe" or item == "minecraft:diamond_pickaxe" then
		return true
	end
	while slot < robot.inventorySize() do
		data = component.inventory_controller.getStackInInternalSlot(slot)
		if not data or ((data.name == item and data.size < 64) and (not meta or meta == data.damage)) then
			if select_next_item(slot + 1, item, meta) then
				robot.transferTo(slot)
				data = component.inventory_controller.getStackInInternalSlot(slot)
			else
				return true
			end
		else
			slot = slot + 1
		end
	end
	return true
end

function empty_slot_amount()
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

function select_item_out_of_workbench(item, meta)
	local slot = 4
	local data
	local size = robot.inventorySize()

	while slot <= size do
		if slot == 5 or slot == 9 then
			slot = slot + 3
		end
		data = component.inventory_controller.getStackInInternalSlot(slot)
		if data and data.name == item and (not meta or data.damage == meta) then
			robot.select(slot)
			return true
		end
		slot = slot + 1
	end
	return false
end

function select_empty_slot()
	local slot = robot.inventorySize()

	while slot > 0 do
        if not component.inventory_controller.getStackInInternalSlot(slot) then
			robot.select(slot)
			return true
		end
        slot = slot - 1
	end
	return false
end

-- Crafting functions

function place_item_for_craft(item, to, meta, amount)
	local craft = {}

	if not amount then
		amount = 1
	end
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
	if select_item_out_of_workbench(item, meta) and robot.transferTo(craft[to], amount) then
		return true
	end
	return false
end

function free_crafting_table()
	local slot = 1
	local data
	local tried = false

	while slot <= 11 do
		if slot ~= 4 and slot ~= 8 then
			if component.inventory_controller.getStackInInternalSlot(slot) and not push_item_after_slot(slot) and not tried then
				clean_inventory()
				tried = true
			elseif component.inventory_controller.getStackInInternalSlot(slot) and not push_item_after_slot(slot) then
				return false
			end
		end
		slot = slot + 1
	end
	return true
end


-- External storage gestion functions

function get_free_slot_in_chest(chest_side)
	local slot
	local inv_size
	local data
	local reason

	slot = 1
	inv_size, reason = component.inventory_controller.getInventorySize(chest_side)
	if not inv_size then
		print("Failed to get free slot in chest: " .. reason)
		return false
	end
	while slot < inv_size do
		data = component.inventory_controller.getStackInSlot(chest_side, slot)
		if not data then
			return slot
		end
		slot = slot + 1
	end
	return false
end

function dump_slot_to_chest(chest_side, from_slot, amount, to_slot)
	if not to_slot then
		to_slot = get_free_slot_in_chest(chest_side)
		if not to_slot then
			return false
		end
	end
	robot.select(from_slot)
	if not amount then
		component.inventory_controller.dropIntoSlot(side.front, to_slot)
	else
		component.inventory_controller.dropIntoSlot(side.front, to_slot, amount)
	end
	return true
end

function drop_item_to_chest(chest_side, item, meta)
	while select_item(item, meta) do
		if not dump_slot_to_chest(chest_side, robot.select()) then
			return false
		end
	end
	return true
end

function get_item_from_chest(chest_side, name, meta, amount)
	local slot
	local data = {}
	local chest_size

	chest_size = component.inventory_controller.getInventorySize(chest_side)
	slot = 1
	if not chest_size or chest_size <= 0 then
		return false
	end
	while slot <= chest_size do
		data = component.inventory_controller.getStackInSlot(side.front, slot)
		if data and data.name == name and (not meta or data.damage == meta) then
			if amount then
				component.inventory_controller.suckFromSlot(chest_side, slot, amount)
			else
				component.inventory_controller.suckFromSlot(chest_side, slot)
			end
			return true
		end
		slot = slot + 1
	end
	return false
end


-- World interations functions

function get_bloc(orientation)
	local bloc = {}

	bloc["bloc"] = component.geolyzer.analyze(orientation)
	bloc["side"] = orientation
	return bloc
end

function get_blocs_around()
	local bloc = {}

	bloc[1] = get_bloc(side.front)
	bloc[2] = get_bloc(side.back)
	bloc[3] = get_bloc(side.up)
	bloc[4] = get_bloc(side.down)
	bloc[5] = get_bloc(side.left)
	bloc[6] = get_bloc(side.right)
	return bloc
end

function can_drop_in_chest()
	local i

	i = 1
	bloc = get_blocs_around()
	while i <= #bloc do
		if bloc[i]["bloc"].name == "ironchest:BlockIronChest" or bloc[i]["bloc"].name == "minecraft:chest" then
			return bloc[i]["side"]
		end
		i = i + 1
	end
	return false
end

function craft_and_store_food()
	local chest_side

	chest_side = can_drop_in_chest()
	if not chest_side then
		print("No chest found")
		return false
	end
	drop_item_to_chest(chest_side, "harvestcraft:lettuceItem")
	if not free_crafting_table() or not place_item_for_craft("harvestcraft:potItem", 1, 0) then
		return false
	end
	get_item_from_chest(chest_side, "harvestcraft:lettuceItem", nil, 21)
	while place_item_for_craft("harvestcraft:lettuceItem", 2, 0, 21) do
		component.crafting.craft()
		select_empty_slot()
		drop_item_to_chest(chest_side, "harvestcraft:stockItem")
		get_item_from_chest(chest_side, "harvestcraft:lettuceItem", nil, 21)
	end
	return true
end


-- Core functions

function line(amount)
	robot.placeDown()
	while amount > 0 do
		forward()
		robot.placeDown()
		amount = amount - 1
	end
end

function core(max_x, max_z)
	local i

	i = 0
	if not select_item("harvestcraft:potItem") then
		return false
	end
	while i < max_z do
		line(max_x)
		if i < max_z - 1 then
			if i % 2 == 0 then
				robot.turnLeft()
			else
				robot.turnRight()
			end
			forward()
			if i % 2 == 0 then
				robot.turnLeft()
			else
				robot.turnRight()
			end
		end
		i = i + 1
	end
	move_orientation(side.back)
	forward(max_x)
	move_orientation(side.left)
	forward(max_z - 1)
	move_orientation(side.left)
	move_orientation(side.back)
	craft_and_store_food()
	move_orientation(side.back)
end
while true do
	core(field_size_x, field_size_z)
	os.sleep(200)
end
