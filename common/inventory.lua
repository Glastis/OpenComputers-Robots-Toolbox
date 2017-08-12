local robot = require("robot")
local component = require("component")

local inventory = {}

local function select_item(item, meta)
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
inventory.select_item = select_item

local function select_item_failsafe(item, trymax, meta, sleeptime)
	local try = 0

	if not sleeptime then
		sleeptime = 30
	end
	while not select_item(item, meta) do
		if meta then
			print("Can't select " .. item .. " with meta: " .. meta .. "\nWaiting 30 secs before retrying.")
		else
			print("Can't select " .. item .. "\nWaiting 30 secs before retrying.")
		end
		try = try + 1
		if try > trymax then
			computer.shutdown()
		end
		os.sleep(sleeptime)
	end
end
inventory.select_item_failsafe = select_item_failsafe

local function equip(item, meta)
	local success

	success = true
	if item then
		success = select_item(item, meta)
	end
	component.inventory_controller.equip()
	return success
end
inventory.equip = equip

local function select_free_slot()
	local slot
	local data

	slot = robot.inventorySize()
	while slot >= 1 do
		data = component.inventory_controller.getStackInInternalSlot(slot)
		if not data then
			robot.select(slot)
			return true
		end
		slot = slot - 1
	end
	return false
end
inventory.select_free_slot = select_free_slot

local function unequip()
	if not select_free_slot() then
		return false
	end
	component.inventory_controller.equip()
	return true
end
inventory.unequip = unequip

local function select_next_item(slot, item, meta)
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
inventory.select_next_item = select_next_item

local function repack_item(item, meta)
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
inventory.repack_item = repack_item

local function push_item_after_slot(from)
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
inventory.push_item_after_slot = push_item_after_slot

local function free_slots_amount()
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
inventory.free_slots_amount = free_slots_amount

local function select_item_out_of_workbench(item, meta)
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
inventory.select_item_out_of_workbench = select_item_out_of_workbench

local function item_amount(item, meta)
    local slot = 1
	local size = robot.inventorySize()
	local amount = 0

    while slot <= size do
        local data = component.inventory_controller.getStackInInternalSlot(slot)
        if data and data.name == item and (not meta or data.damage == meta) then
			amount = amount + data.size
		end
        slot = slot + 1
	end
    return amount
end
inventory.item_amount = item_amount

return inventory