local robot = require("robot")
local side = require("sides")
local component = require("component")

local utility = require('utilities')
local inventory = require('inventory')
local chest = {}

local function get_item_from_chest(name, meta, amount, chest_side)
	local slot
	local data
	local size

	slot = 1
	if not chest_side then
		chest_side = side.front
	end
	size = component.inventory_controller.getInventorySize(chest_side)
	if not size then
		print('Warning: No inventory found')
		return false
	end
	if (amount and amount <= 0) or not component.inventory_controller.getInventorySize(chest_side) then
		return false
	end
	while slot <= size do
		data = component.inventory_controller.getStackInSlot(chest_side, slot)
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
chest.get_item_from_chest = get_item_from_chest

local function get_free_slot_in_chest(chest_side)
	local slot
	local inv_size
	local data

	slot = 1
	if not chest_side then
		chest_side = side.front
	end
	inv_size = component.inventory_controller.getInventorySize(chest_side)
	if not inv_size then
		print('Warning: No inventory found')
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
chest.get_free_slot_in_chest = get_free_slot_in_chest

local function drop_slot_to_chest_slot(chest_side, from_slot, amount, to_slot)

	if not chest_side then
		chest_side = side.front
	end
	if not to_slot then
		to_slot = get_free_slot_in_chest(chest_side)
		if not to_slot then
			return false
		end
	end
	robot.select(from_slot)
	if not amount then
		component.inventory_controller.dropIntoSlot(chest_side, to_slot)
	else
		component.inventory_controller.dropIntoSlot(chest_side, to_slot, amount)
	end
	return true
end
chest.drop_slot_to_chest_slot = drop_slot_to_chest_slot

local function drop_slot_to_chest(chest_side, slot)
	local data
	local slot_chest
	local inv_size
	local data_chest

	if not chest_side then
		chest_side = side.front
	end
	slot_chest = 1
	data = component.inventory_controller.getStackInInternalSlot(slot)
	inv_size = component.inventory_controller.getInventorySize(chest_side)
	if not inv_size then
		print('Warning: No inventory found')
		return false
	end
	robot.select(slot)
	while robot.count(slot) > 0 do
		data_chest = component.inventory_controller.getStackInSlot(chest_side, slot_chest)
		if not data_chest or (data_chest.name == data.name and data_chest.damage == data.damage) then
			component.inventory_controller.dropIntoSlot(chest_side, slot_chest)
		end
		slot_chest = slot_chest + 1
		if slot_chest > inv_size then
			return false
		end
	end
	return robot.count(slot) == 0
end
chest.drop_slot_to_chest = drop_slot_to_chest

local function drop_item_to_chest(item, meta, chest_side)
	local slot = 1
	local size

	size = robot.inventorySize()
	if not chest_side then
		chest_side = side.front
	end
	while slot <= size do
		local data

		data = component.inventory_controller.getStackInInternalSlot(slot)
		if data and data.name == item and (not meta or data.damage == meta) then
			if not drop_slot_to_chest(chest_side, slot) then
				return false
			end
		end
		slot = slot + 1
	end
	return true
end
chest.drop_item_to_chest = drop_item_to_chest

local function is_full(chest_side)
	local slot
	local data

	if not chest_side then
		chest_side = side.front
	end
	slot = component.inventory_controller.getInventorySize(chest_side)
	if not slot then
		print("Warning: No chest found")
		return true
	end
	while slot > 0 do
		data = component.inventory_controller.getStackInInternalSlot(slot)
		if not data then
			return false
		end
		slot = slot - 1
	end
	return true
end
chest.is_full = is_full


local function select_last_item(chest_side, item, meta, max)
	local slot
	local data

	if not chest_side then
		chest_side = side.front
	end
	slot = component.inventory_controller.getInventorySize(chest_side)
	if not slot then
		print("Warning: No chest found")
		return false
	end
	if max and max < slot then
		slot = max
	end
	while slot > 0 do
		data = component.inventory_controller.getStackInInternalSlot(slot)
		if data and data.name == item and data.damage == meta then
			return slot
		end
		slot = slot - 1
	end
	return false
end
chest.select_last_item = select_last_item

local function repack_item(chest_side, item, meta, from_slot)
	local slot
	local data
	local size

	if not chest_side then
		chest_side = side.front
	end
	if not from_slot then
		from_slot = 1
	end
	size = component.inventory_controller.getInventorySize(chest_side)
	if not size then
		print("Warning: No chest found")
		return false
	end
	if not inventory.select_free_slot() then
		return false
	end
	slot = chest.select_last_item(chest_side, item, meta)
	while from_slot < slot do
		slot = chest.select_last_item(chest_side, item, meta, slot)
		component.inventory_controller.suckFromSlot(chest_side, slot)
		component.inventory_controller.dropIntoSlot(chest_side, from_slot)
		data = component.inventory_controller.getStackInInternalSlot(from_slot)
		while data or data.size == data.maxSize or data.name ~= item or data.damage ~= meta do
			from_slot = from_slot + 1
		end
	end
end
chest.repack_item = repack_item

local function repack_chest(chest_side)
	local slot
	local data
	local size
	local done = {}

	done['name'] = {}
	done['meta'] = {}
	if not chest_side then
		chest_side = side.front
	end
	size = component.inventory_controller.getInventorySize(chest_side)
	slot = 1
	if not size then
		print("Warning: No chest found")
		return false
	end
	while slot <= size do
		data = component.inventory_controller.getStackInInternalSlot(slot)
		if data and data.size < data.maxSize and not utility.is_elem_in_list(done['name'], data.name) and not utility.is_elem_in_list(done['meta'], data.damage) then
			repack_item(chest_side, data.name, data.damage, slot)
			done['name'][#done['name'] + 1] = data.name
			done['meta'][#done['meta'] + 1] = data.damage
		end
	end
	return true
end
chest.repack_chest = repack_chest

return chest
