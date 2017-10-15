local component = require('component')
local robot = require('robot')

local inventory = require('inventory')

local crafting = {}


--	[[
----	Prupose :	Free internal space for crafting componente
----	
----	params : 	Nothing
----
----	return :	true	crafting slot is now clear and ready to perform opperation
----				false	something wrong append, the inventory is maybe full, and the crafting slot are not clear     (pas sure : The crafting slot is already clear)
--]]
local function free_crafting_table()
	local slot

	slot = 1
	while slot <= 11 do
		if slot ~= 4 and slot ~= 8 then
			if component.inventory_controller.getStackInInternalSlot(slot) and not inventory.push_item_after_slot(slot, true) then
				return false
			end
		end
		slot = slot + 1
	end
	return true
end
crafting.free_crafting_table = free_crafting_table

----[[
----	prupose :
----
----	params :
----
----	return :
----]]

local function move_item_out_of_crafting_table(item, meta, search_from)
	local slot
	local data
    local retslot

	slot = 1
	while slot <= 11 do
		if slot ~= 4 and slot ~= 8 then
			data = component.inventory_controller.getStackInInternalSlot(slot)

			if data and data.name == item and (not meta or data.damage == meta) then
                retslot = inventory.push_item_after_slot(slot, true, search_from)

                if not retslot then
				    return false
                end
			end
		end
		slot = slot + 1
	end
	return retslot
end
crafting.move_item_out_of_crafting_table = move_item_out_of_crafting_table



----[[
----	prupose : 	put an item to a slot for crafting
----
----	params :	item,	required,	the unlocalized name of th item that you want to move, eg: "minecraft:dirt"
----				slot,	required,	the slot (from a vanilla crafting table) of the destination, must be a nuber between 1 and 9
----				meta,	optional,	meta data of the item (needed for specifique dye for exemple). If no metadata provided then all are matching.
----				amount, optional,	amount of items. By default 1.
----
----	return : 	true	item(s) is now on the selected slot
----				false 	item(s) cannot be transfered or does exist in inventory.
--]]

local function place_item_for_craft(item, to, meta, amount)
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
		print("ERROR: place_item_for_craft: slot can't be > than 9")
		os.exit()
	end
	if inventory.select_item_out_of_workbench(item, meta) and robot.transferTo(craft[to], amount) then
		return true
	end
	return false
end
crafting.place_item_for_craft = place_item_for_craft

----[[
----	prupose :	perform all needed opperation to craft a item
----
----	params : 	patern,	required, table,	the patern hold the patern of required craft
----											every element in the table is the requiried item for craft
----											each item was represented by his slot in thi craft patern (slot number from wanilla crafting table)
----											each item in the partern table are a array himself, with
----											["name"] : unlocalized name of the item, eg : "minecraft:dirt"
----											["meta"] : desired meta data, optional, if nil all meta data are accepted
----											["amount"] : stack amount, optional, one by default.
----
----	return : 	true	ready to craft
----				false	craft is impossible to prepare. One or more item is missing, or meta data doesn't exist.

----]]

local function prepare_craft(patern)
	local i
	local retval

	i = 1
	free_crafting_table()
	retval = true
	while i <= 9 do
		if retval and patern[i] and patern[i]['item'] then
			retval = place_item_for_craft(patern[i]['item'], i, patern[i]['meta'], patern[i]['amount'])
		elseif retval and patern[i] then
			retval = place_item_for_craft(patern[i], i)
		end
		i = i + 1
	end
	return retval
end
crafting.prepare_craft = prepare_craft


----[[
----	prupose :	craft block of an item while item exist in inventory and crafting slot is not full
----
----	params :	block_size,	required,	amount of item to craft a bloc, can be 4 (like quartz) or 9 (like iron)
----				item,		required,	item needed to craft his block version, must be the unlocalized name, eg :"minecraft:dirt"
----				meta,		optional,	metadata of item if needed, if nil every metadata is accepted
----
----	return :	true	craft block completes
----				false	craft block cannot be perfomed (block doesn't exist, or item is missing)
---]]

local function craft_bloc(bloc_size, item, meta)
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
crafting.craft_bloc = craft_bloc

----[[
----	prupose : 	perform all needed opperation to compact item into block
----
----	params : 	block_size,	required,	needed amount of item to craft bloc.
----				item,		required,	needed item to craft bloc, must be unlocalized name, eg: "minecraft:dirt".
----				meta,		optional,	metadata of item, if nil all metadata if accpeted
----
----	return :	Nothing
----]]

local function compact_item_to_bloc(bloc_size, item, meta)
	local amount

	amount = inventory.item_amount(item, meta)
	if amount >= bloc_size and free_crafting_table() then
		craft_bloc(bloc_size, item, meta)
		inventory.clean_inventory()
	end
end
crafting.compact_item_to_bloc = compact_item_to_bloc

----[[
----	Prupose :	compact all vanilla items into his block
----
----	params :	Nothing
----
----	return :	Nothing
----]]
local function compact_all_items_blocs()
	compact_item_to_bloc(9, "minecraft:dye", 4)
	inventory.repack_item("minecraft:dye", 4)
	compact_item_to_bloc(9, "minecraft:coal", 0)
	inventory.repack_item("minecraft:coal", 0)
	compact_item_to_bloc(9, "minecraft:redstone")
	inventory.repack_item("minecraft:redstone")
	compact_item_to_bloc(4, "minecraft:quartz")
	inventory.repack_item("minecraft:quartz")
	compact_item_to_bloc(4, "minecraft:glowstone_dust")
	inventory.repack_item("minecraft:glowstone_dust")
end
crafting.compact_all_items_blocs = compact_all_items_blocs

crafting.craft = component.crafting.craft
return crafting
