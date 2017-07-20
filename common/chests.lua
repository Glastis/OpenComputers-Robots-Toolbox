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
