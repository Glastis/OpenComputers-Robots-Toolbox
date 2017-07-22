local side = require("sides")
local component = require("component")

function get_item_from_chest(name, meta, amount, orientation)
	local slot
	local data = {}

	slot = 1
  if not orientation then
    orientation = side.front
  end
	if (amount and amount <= 0) or not component.inventory_controller.getInventorySize(orientation) then
		return false
	end
	while slot <= component.inventory_controller.getInventorySize(orientation) do
		data = component.inventory_controller.getStackInSlot(orientation, slot)
		if data and data.name == name and (not meta or data.damage == meta) then
			if amount then
				component.inventory_controller.suckFromSlot(orientation, slot, amount)
			else
				component.inventory_controller.suckFromSlot(orientation, slot)
			end
			return true
		end
		slot = slot + 1
	end
	return false
end

function get_free_slot_in_chest(chest_side)
	local slot
	local inv_size
	local data

	slot = 1
	if not chest_side then
		chest_side = side.front
	end
	inv_size = component.inventory_controller.getInventorySize(chest_side)
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
