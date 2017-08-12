local robot = require("robot")
local side = require("sides")
local component = require("component")

local utility = require('utilities')
local inventory = require('inventory')
local chest = {}

--[[
----	purpose: Suck an item from a chest
----
----  	params: name, 		requiered, 	name of item that must be suck, string. eg: 'minecraft:dirt'
----			meta, 		optional, 	metadata of the item, number. If no metadata provided then all are matching.
----			amount, 	optional, 	maximum amount of items to suck, number beteween 1 and 64.
----			chest_side	requiered,  where is the chest compared to the robot, number. eg 'side.left'
----
----	return: true		if at least one item was get from chest
----			false		if nothing moved
--]]
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
	while slot <= size do
		data = component.inventory_controller.getStackInSlot(chest_side, slot)

		if data and data.name == name and (not meta or data.damage == meta) then
			return component.inventory_controller.suckFromSlot(chest_side, slot, amount)
		end
		slot = slot + 1
	end
	return false
end
chest.get_item_from_chest = get_item_from_chest

--[[
----	purpose: Get first empty slot in a chest
----
----  	params: chest_side	requiered,  where is the chest compared to the robot, number. eg 'side.left'
----
----	return: slot:number	the firt empty slot
----			false		if no chest/inventory found or if chest have no empty slot.
--]]
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

--[[
----	purpose: Drop a robot slot in a chest in first(s) free emplacement(s) (empty or unfilled stack slot).
----
----  	params: chest_side	requiered,  where is the chest compared to the robot, number. eg 'side.left'
----  			from_slot, 	requiered, 	slot of robot to be drop.
----			amount, 	optional, 	maximum amount of items to suck.
----
----	return: true		if at least one item was drop to chest
----			false		if nothing moved
--]]
local function drop_slot_to_chest(chest_side, slot, amount)
	local data
	local slot_chest
	local inv_size
	local data_chest

	if not chest_side then
		chest_side = side.front
	end
	inv_size = component.inventory_controller.getInventorySize(chest_side)
	if not inv_size then
		print('Warning: No inventory found')
		return false
	end
	slot_chest = 1
	data = component.inventory_controller.getStackInInternalSlot(slot)
	robot.select(slot)
	while robot.count(slot) > 0 do
		data_chest = component.inventory_controller.getStackInSlot(chest_side, slot_chest)
		if not data_chest or (data_chest.name == data.name and data_chest.damage == data.damage) then
			component.inventory_controller.dropIntoSlot(chest_side, slot_chest, amount)
		end
		slot_chest = slot_chest + 1
		if slot_chest > inv_size then
			return false
		end
	end
	return robot.count(slot) == 0
end
chest.drop_slot_to_chest = drop_slot_to_chest

--[[
----	purpose: Drop a robot slot to a chest slot
----
----  	params: chest_side	requiered,  where is the chest compared to the robot, number. eg 'side.left'
----  			from_slot, 	requiered, 	slot of robot to be drop.
----			amount, 	optional, 	maximum amount of items to suck.
----			to_slot, 	optional, 	chest slot that will receive items. If no provided, then it will drop into the first empty/not fully stacked slot.
----
----	return: true		if at least one item was drop to chest
----			false		if nothing moved
--]]
local function drop_slot_to_chest_slot(chest_side, from_slot, amount, to_slot)

	if not chest_side then
		chest_side = side.front
	end
	if not to_slot then
		return drop_slot_to_chest(chest_side, from_slot, amount)
	end
	robot.select(from_slot)
	return component.inventory_controller.dropIntoSlot(chest_side, to_slot, amount)
end
chest.drop_slot_to_chest_slot = drop_slot_to_chest_slot

--[[
----	purpose: Drop all same item in a chest in first(s) free emplacement(s) (empty or unfilled stack slot).
----
----  	params: chest_side	requiered,  where is the chest compared to the robot, number. eg 'side.left'
----  			from_slot, 	requiered, 	slot of robot to be drop.
----			amount, 	optional, 	maximum amount of items to suck.
----			to_slot, 	optional, 	chest slot that will receive items. If no provided, then it will drop into the first empty/not fully stacked slot.
----
----	return: true		if at least one item was drop to chest
----			false		if nothing moved
--]]
local function drop_item_to_chest(item, meta, amount, chest_side)
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
			if not drop_slot_to_chest(chest_side, slot, amount) then
				return false
			end
		end
		slot = slot + 1
	end
	return true
end
chest.drop_item_to_chest = drop_item_to_chest

--[[
----	purpose: Tell if there is at least one empty slot in a chest (regardless of unfilled stacks).
----
----  	params: chest_side	requiered,  where is the chest compared to the robot, number. eg 'side.left'
----
----	return: true		chest have no empty slot
----			false		chest have at least one empty slot
--]]
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
		data = component.inventory_controller.getStackInSlot(chest_side, slot)
		if not data then
			return false
		end
		slot = slot - 1
	end
	return true
end
chest.is_full = is_full

--[[
----	purpose: Return number of matching item in chest.
----
----  	params: item, 		requiered, 	name of item that must be suck, string. eg: 'minecraft:dirt'
----			meta, 		optional, 	metadata of the item, number. If no metadata provided then all are matching.
----			chest_side	optional,  where is the chest compared to the robot, number. eg 'side.left'. Default is 'side.front'
----
----	return: amount:number	amount of matching item
----			false			no valid inventory found at side
--]]
local function get_item_amount(chest_side, item, meta)
	local slot
	local data
	local amount

	amount = 0
	if not chest_side then
		chest_side = side.front
	end
	slot = component.inventory_controller.getInventorySize(chest_side)
	if not slot then
		print("Warning: No chest found")
		return false
	end
	while slot > 0 do
		data = component.inventory_controller.getStackInSlot(chest_side, slot)
		if data and data.name == item and (not meta or data.damage == meta) then
			amount = amount + data.size
		end
		slot = slot - 1
	end
	return amount
end
chest.get_item_amount = get_item_amount


--[[
----	purpose: Get last slot occuped by provided item in chest
----
----  	params: chest_side	requiered,  where is the chest compared to the robot, number. eg 'side.left'
----			item, 		requiered, 	name of item that must be suck, string. eg: 'minecraft:dirt'
----			meta, 		requiered, 	metadata of the item, number. If no metadata provided then all are matching.
----			max, 		optional, 	maximum slot to begin research (optimisation stuff). If no maximum provided, using the inventory size instead.
----
----	return: slot:number	the last slot with matching item
----			false		no matching item or no inventory found
--]]
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
		data = component.inventory_controller.getStackInSlot(chest_side, slot)
		if data and data.name == item and data.damage == meta then
			return slot
		end
		slot = slot - 1
	end
	return false
end
chest.select_last_item = select_last_item

--[[
----	purpose: Stack all unfiled stacks of matching item
----
----  	params: chest_side	requiered,  where is the chest compared to the robot, number. eg 'side.left'
----			item, 		requiered, 	name of item that must be suck, string. eg: 'minecraft:dirt'
----			meta, 		requiered, 	metadata of the item, number. If no metadata provided then all are matching.
----			from_slot, 	optional, 	minimum slot to begin research (optimisation stuff). If no minimum provided, using the first inventory slot.
----
----	return: true		if succeed
----			false		if no chest/inventory found or if robot don't have an empty slot to swap.
--]]
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
	slot = select_last_item(chest_side, item, meta)
	while slot and from_slot < slot do
		slot = chest.select_last_item(chest_side, item, meta, slot)
		component.inventory_controller.suckFromSlot(chest_side, slot)
		component.inventory_controller.dropIntoSlot(chest_side, from_slot)
		data = component.inventory_controller.getStackInSlot(chest_side, from_slot)
		while data and (data.size == data.maxSize or data.name ~= item or data.damage ~= meta) do
			from_slot = from_slot + 1
			data = component.inventory_controller.getStackInSlot(chest_side, from_slot)
		end
	end
	return true
end
chest.repack_item = repack_item

--[[
----	purpose: Stack all unfiled stacks in chest (can be long, especialy with a huge inventory, due to chest parsing)
----
----  	params: chest_side	requiered,  where is the chest compared to the robot, number. eg 'side.left'
----
----	return: true		if succeed
----			false		if no chest/inventory found or if robot don't have an empty slot to swap.
--]]
local function repack_chest(chest_side)
	local slot
	local data
	local size
	local retval
	local tmp
	local done = {}

	retval = true
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
		data = component.inventory_controller.getStackInSlot(chest_side, slot)
		if data and data.size < data.maxSize and not utility.is_elem_in_list(done['name'], data.name) and not utility.is_elem_in_list(done['meta'], data.damage) then
			tmp = repack_item(chest_side, data.name, data.damage, slot)
			if not tmp then
				retval = false
			end
			done['name'][#done['name'] + 1] = data.name
			done['meta'][#done['meta'] + 1] = data.damage
		end
		slot = slot + 1
	end
	return retval
end
chest.repack_chest = repack_chest

return chest
