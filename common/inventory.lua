local component = require("component")

function select_item_failsafe(item, trymax, meta, sleeptime)
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

function select_fuel()
	while item_amount("minecraft:coal", 1) < 16 do
		if not get_fuel_from_enderchest(amount) then
			print("Fail to retreive fuel from enderchest. Retring in 30 secondes...")
			os.sleep(30)
		end
	end
	select_item("minecraft:coal", 1)
	select_item("minecraft:coal", 1)
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

function select_item(item, meta)
    local slot = 1
	local size = robot.inventorySize()

	errno = "unknown error"
    while slot <= size do
        local data = component.inventory_controller.getStackInInternalSlot(slot)
        if data and data.name == item and (not meta or data.damage == meta) then
            robot.select(slot)
            return true
		end
        slot = slot + 1
	end
	errno = "Can't select: " .. item
	if meta then
		errno = errno .. " with metadata: "  .. meta
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

function compact_all()
	compact_item(9, "minecraft:dye", 4)
	repack_item("minecraft:dye", 4)
	compact_item(9, "minecraft:coal", 0)
	repack_item("minecraft:coal", 0)
	compact_item(9, "minecraft:redstone")
	repack_item("minecraft:redstone")
	compact_item(4, "minecraft:quartz")
	repack_item("minecraft:quartz")
	compact_item(4, "minecraft:glowstone_dust")
	repack_item("minecraft:glowstone_dust")
end

function free_slots_amount()
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

function compact_item(bloc_size, item, meta)
	local amount = item_amount(item, meta)

	if amount >= bloc_size and free_crafting_table() then
		craft_all_blocs(bloc_size, item, meta)
		clean_inventory()
	end
end

function item_amount(item, meta)
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

function clean_inventory(items_to_keep)
	local slot
	local data

	if items_to_keep and not type(items_to_keep) == "table" then
		print("Warning: Clean inventory, 'items_to_keep' should be a table with ['item'] (and optionnaly ['meta'])"
	end
	slot = 1
	while slot <= robot.inventorySize() do
		data = component.inventory_controller.getStackInInternalSlot(slot)
		if data then
			if items_to_keep and not is_in_list(data.name, essentials) or data.name == "minecraft:diamond" then
				if data.name == "minecraft:diamond" and data.size > 3 then
					dump_slot_to_chest(side.front, slot, data.size - 3)
				elseif is_in_list(data.name, minerals) and data.name ~= "minecraft:diamond" then
					dump_slot_to_chest(side.front, slot, data.size)
				elseif data.name ~= "minecraft:diamond" then
					table.insert(garbage, slot)
				end
			elseif is_in_list(data.name, essentials) and data.name ~= "minecraft:cobblestone" then
				repack_item(data.name, data.damage)
			elseif not cobble and data.name == "minecraft:cobblestone" then
				cobble = true
			else
				table.insert(garbage, slot)
			end
		end
		slot = slot + 1
	end
	smart_swing(true)
	while try > 0 do
		while not robot.down() do
			smart_swingDown()
			os.sleep(0.5)
		end
		try = try - 1
	end
	slot = 1
	while slot <= #garbage do
		robot.select(garbage[slot])
		robot.drop()
		slot = slot + 1
	end
	robot.turnRight()
	robot.turnRight()
end