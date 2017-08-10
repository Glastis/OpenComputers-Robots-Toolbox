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

function place_item_for_craft(item, to, meta)
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
	if select_item_out_of_workbench(item, meta) and robot.transferTo(craft[to], 1) then
		return true
	end
	return false
end

function craft_all_blocs(bloc_size, item, meta)
	if bloc_size == 9 then
		while 	place_item_for_craft(item, 1, meta) and
				place_item_for_craft(item, 2, meta) and
				place_item_for_craft(item, 3, meta) and
				place_item_for_craft(item, 4, meta) and
				place_item_for_craft(item, 5, meta) and
				place_item_for_craft(item, 6, meta) and
				place_item_for_craft(item, 7, meta) and
				place_item_for_craft(item, 8, meta) and
				place_item_for_craft(item, 9, meta) do
			os.sleep(0.1)
		end
	elseif bloc_size == 4 then
		while 	place_item_for_craft(item, 1, meta) and
				place_item_for_craft(item, 2, meta) and
				place_item_for_craft(item, 4, meta) and
				place_item_for_craft(item, 5, meta) do
			os.sleep(0.1)
		end
	end
	return component.crafting.craft()
end

local function compact_item(bloc_size, item, meta)
	local amount = item_amount(item, meta)

	if amount >= bloc_size and free_crafting_table() then
		craft_all_blocs(bloc_size, item, meta)
		clean_inventory()
	end
end

local function compact_all()
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
