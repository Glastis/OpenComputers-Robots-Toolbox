local build = 45
--[[
		Seriously, who cares of headers ?
		License ? Well, consider that script is on MIT license and do whateaver you want with it. I don't care.
									- Link712011
]]--


local version = "2.0.1.2"
local robot = require("robot")
local side = require("sides")
local component = require("component")
local shell = require("shell")
local computer = require("computer")

local config_filename = "dmp_whitelist.conf"
local stockpile_filename = "stock_whitelist.conf"
local last_changelog=""
local offset = { x = 0, y = 0, z = 0 }
local errno = "unknown error"
local minerals = {}
local diamond_requirered_blocs = {}
local stockpile = {}
local shovel_block = {}
local essentials = {}
local search_update = true
local ender_chest_damage_fuel = 1092 -- yellow yellow yellow
local ender_chest_damage_log = 3822 -- red red red
local ender_chest_damage_dump = 3003 -- blue blue blue
local arg = {...}
local inventory_checker_counter = 0

function place_enderchest(number)
	local try

	select_item_failsafe("EnderStorage:enderChest", 3, number)
	try = 0
	while not robot.place() do
		smart_swing(true)
		select_item_failsafe("EnderStorage:enderChest", 3, number)
		if robot.place() then
			break
		end
		print("Can't place enderchest, waiting 5 secs before retrying.")
		try = try + 1
		while not robot.up() do
			smart_swingUp()
			os.sleep(0.5)
		end
		if try > 10 then
			computer.shutdown()
		end
		os.sleep(5)
	end
	return try
end
function get_fuel_from_enderchest(amount)
	local bloc
	local try

	robot.turnLeft()
	robot.turnLeft()
	bloc = component.geolyzer.analyze(side.front)
	if not bloc or bloc.metadata ~= ender_chest_damage_fuel then
		try = place_enderchest(ender_chest_damage_fuel)
	end
	if (amount and not get_item_from_chest("minecraft:coal", 1, amount)) or not get_item_from_chest("minecraft:coal", 1) then
		smart_swing()
		robot.turnRight()
		robot.turnRight()
		return false
	end
	smart_swing(true)
	while try > 0 do
		while not robot.down() do
			smart_swingDown()
			os.sleep(0.5)
		end
		try = try - 1
	end
	robot.turnRight()
	robot.turnRight()
	return true
end
function check_fuel()
	local data
	local cleaned

	cleaned = false
	if component.generator.count() >= 16 and computer.energy() >= 10000 then
		return true
	end
	while not select_empty_case() do
		clean_inventory()
		cleaned = true
	end
	component.generator.remove()
	data = component.inventory_controller.getStackInInternalSlot()
	if not cleaned then
		clean_inventory()
	elseif data then
		repack_item(data.name, data.meta)
	end
	select_fuel()
	component.generator.insert()
	if computer.energy() < 10000 then
		print("Need generating fuel before continue. Waiting 1 minute.")
		os.sleep(60)
		return check_fuel()
	end
	return true
end
function equip_pickaxe(bloc_name, force)
	local pick_name = nil
	local other_pick = nil
	local material

	if is_in_list(bloc_name, diamond_requirered_blocs) then
		pick_name = "minecraft:diamond_pickaxe"
		other_pick = "minecraft:stone_pickaxe"
		material = "minecraft:diamond"
	elseif not is_in_list(bloc_name, shovel_block) then
		pick_name = "minecraft:stone_pickaxe"
		other_pick = "minecraft:diamond_pickaxe"
		material = "minecraft:cobblestone"
	end
	if not pick_name then
		return true
	end
	while not select_item(pick_name) do
		if force and select_item(other_pick) then
			break
		end
		print("Can't select pickaxe")
		if not craft_pickaxe(material) then
			print(errno .. "\nWaiting 5 secs before retrying...")
			os.sleep(5)
		end
	end
	component.inventory_controller.equip()
	robot.select(1)
	return true
end

function check_and_extract()
	local success, dir
	success, dir = check_filon()

	if success then
		extract_filon(dir)
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
function select_lava_filler_bloc()
	if select_item("minecraft:netherrack") or select_item("minecraft:stone") or (not is_in_list("minecraft:dirt", minerals) and select_item("minecraft:dirt")) or (item_amount("minecraft:cobblestone") > 10 and ("minecraft:cobblestone")) then
		return true
	end
	return false
end
function check_filon()
	local bloc

	bloc = component.geolyzer.analyze(side.left)
	if (bloc.name == "minecraft:flowing_lava" or bloc.name == "minecraft:lava") and select_lava_filler_bloc() then
		robot.turnLeft()
		robot.place()
		robot.turnRight()
	elseif is_in_list(bloc.name, minerals) then
		return true, side.left
	end
	bloc = component.geolyzer.analyze(side.right)
	if (bloc.name == "minecraft:flowing_lava" or bloc.name == "minecraft:lava") and select_lava_filler_bloc() then
		robot.turnRight()
		robot.place()
		robot.turnLeft()
	elseif is_in_list(bloc.name, minerals) then
		return true, side.right
	end
	bloc = component.geolyzer.analyze(side.up)
	if (bloc.name == "minecraft:flowing_lava" or bloc.name == "minecraft:lava") and select_lava_filler_bloc() then
		robot.placeUp()
	elseif is_in_list(bloc.name, minerals) then
		return true, side.up
	end
	bloc = component.geolyzer.analyze(side.down)
	if (bloc.name == "minecraft:flowing_lava" or bloc.name == "minecraft:lava") and select_lava_filler_bloc() then
		robot.placeDown()
	elseif is_in_list(bloc.name, minerals) then
		return true, side.down
	end
	bloc = component.geolyzer.analyze(side.back)
	if (bloc.name == "minecraft:flowing_lava" or bloc.name == "minecraft:lava") and select_lava_filler_bloc() then
		robot.turnRight()
		robot.turnRight()
		robot.place()
		robot.turnLeft()
		robot.turnLeft()
	elseif is_in_list(bloc.name, minerals) then
		return true, side.back
	end
	if robot.detect() then
		bloc = component.geolyzer.analyze(side.front)
		if (bloc.name == "minecraft:flowing_lava" or bloc.name == "minecraft:lava") and select_lava_filler_bloc() then
			robot.place()
		elseif is_in_list(bloc.name, minerals) then
			return true, side.front
		end
	end
	return false, nil
end
function extract_filon(direction)
	local success, dir

	if empty_cases_amount() < 11 then
		clean_inventory()
	end
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



function clean_inventory()
	local slot
	local data
	local cobble = false
	local garbage = {}
	local try

	robot.turnLeft()
	robot.turnLeft()
	if empty_cases_amount() > 10 then
		compact_all()
	end
	try = place_enderchest(ender_chest_damage_dump)
	repack_item("minecraft:cobblestone")
	slot = 1
	while slot <= robot.inventorySize() do
		data = component.inventory_controller.getStackInInternalSlot(slot)
		if data then
			if not is_in_list(data.name, essentials) or data.name == "minecraft:diamond" then
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
function smart_swing(force)
	local bloc

	bloc = component.geolyzer.analyze(side.front)
	if not bloc then
		return true
	end
	equip_pickaxe(bloc.name, force)
	robot.swing()
	if not unequip() then
		return false
	end
	return true
end
function smart_swingUp()
	local bloc

	bloc = component.geolyzer.analyze(side.top)
	equip_pickaxe(bloc.name)
	robot.swingUp()
	if not unequip() then
		return false
	end
	return true
end
function smart_swingDown()
	local bloc

	bloc = component.geolyzer.analyze(side.bottom)
	equip_pickaxe(bloc.name)
	robot.swingDown()
	if not unequip() then
		return false
	end
	return true
end
function avance()
	errno = "Unknown error"
	check_fuel()
	while item_amount("minecraft:log") < 10 do
		print("No/Few logs left in robot. Retreiving...")
		ender_chest_get_item(ender_chest_damage_log, "minecraft:log")
		os.sleep(2)
	end
	if inventory_checker_counter >= 2 and empty_cases_amount() < 13 then
		clean_inventory()
		inventory_checker_counter = 0
	else
		inventory_checker_counter = inventory_checker_counter + 1
	end
	check_and_extract()
	while not robot.forward() do
		smart_swing()
		os.sleep(0.5)
	end
	while not robot.up() do
		smart_swingUp()
		os.sleep(0.5)
	end
	check_and_extract()
	while not robot.down() do
		smart_swingDown()
		os.sleep(0.5)
	end
	while not robot.down() do
		smart_swingDown()
		os.sleep(0.5)
	end
	check_and_extract()
	while not robot.up() do
		smart_swingUp()
		os.sleep(0.5)
	end
end
function line(i)
	while i > 0 do
		avance()
		i = i - 1
	end
	if robot.detectUp() then
		smart_swingUp()
	end
	if robot.detectDown() then
		smart_swingDown()
	end
end
function turn(bool)
	if bool then
		robot.turnRight()
		else
		robot.turnLeft()
	end
end

function core(xmax, tunmax, dir)
	local bool = true
	local first = true

	if dir == "left" then
		bool = false
	end
	while tunmax > 0 do
		line(xmax)
		if not first then
			turn(xor_bool(bool))
			line(4)
			turn(bool)
			turn(bool)
			line(8)
			turn(bool)
		else
			turn(bool)
			line(4)
			turn(bool)
			first = false
		end
		bool = xor_bool(bool)
		tunmax = tunmax - 1
		os.sleep(1)
		print("Tunnel(s) restant(s): " .. tostring(tunmax))
	end
end

function craft_pickaxe(material)
	if item_amount("minecraft:stick") < 2 and not craft_sticks() then
		return false
	end
	if free_crafting_table() then
		place_item_for_craft(material, 1)
		place_item_for_craft(material, 2)
		place_item_for_craft(material, 3)
		place_item_for_craft("minecraft:stick", 5)
		place_item_for_craft("minecraft:stick", 8)
		return component.crafting.craft(1)
	end
	errno = "Error when crafting " .. material
	return false
end
function craft_sticks()
	if item_amount("minecraft:planks") < 2 and not craft_planks() then
		return false
	end
	if free_crafting_table() then
		place_item_for_craft("minecraft:planks", 1)
		place_item_for_craft("minecraft:planks", 4)
		return component.crafting.craft(1)
	end
	errno = "Error when crafting sticks"
	return false
end
function craft_planks()
	if item_amount("minecraft:log") < 1 then
		return false
	end
	if free_crafting_table() then
		place_item_for_craft("minecraft:log", 1)
		return component.crafting.craft(1)
	end
	errno = "Error when crafting sticks"
	return false
end
function pickaxe_materials()
	local wood, material = false, false
	local stick = 0
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
			elseif data and not material and (data.name == "minecraft:cobblestone" or data.name == "minecraft:iron_ingot") and data.size >= 3 then
			material = true
		end
		slot = slot + 1
	end
	if material and not wood then
		return craft_sticks()
		elseif wood and material then
		return true
	end
	return false
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




function stock_minerals()
	local slot = 1

	dump_to_ender_chest()
	if empty_cases_amount() < 15 and select_item("minecraft:chest") then
		robot.place()
		while slot < robot.inventorySize() do
			local data = component.inventory_controller.getStackInInternalSlot(slot)

			if data and is_in_list(data.name, stockpile) and not is_in_list(data.name, essentials) then
				robot.select(slot)
				robot.drop()
			end
			slot = slot + 1
		end
	end
end


function dump_to_ender_chest()
	local slot = 1
	local dump_slot
	local try

	try = place_enderchest(ender_chest_damage_dump)
	while slot < robot.inventorySize() do
		data = component.inventory_controller.getStackInInternalSlot(slot)
		if data and not is_in_list(data.name, essentials) then
			if data.name == "minecraft:diamond" and data.size > 3 then
				dump_slot_to_chest(side.front, slot, data.size - 3)
			elseif data.name ~= "minecraft:diamond" then
				dump_slot_to_chest(side.front, slot, data.size)
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
end
function ender_chest_get_item(ender_chest, name, id, amount)
	local try

	try = place_enderchest(ender_chest)
	if id then
		if (amount and not get_item_from_chest(name, id, amount)) or not get_item_from_chest(name, id) then
			smart_swing()
			return false
		end
		smart_swing()
		return true
	end
	if (amount and not get_item_from_chest(name, id, amount)) or not get_item_from_chest(name, id) then
		smart_swing()
		return false
	end
	smart_swing(true)
	while try > 0 do
		while not robot.down() do
			smart_swingDown()
			os.sleep(0.5)
		end
		try = try - 1
	end
	return true
end

local lenght, amount, direction

init()

print("Robot energy left:" .. computer.energy())

print("Tunnel lenght ?")
lenght = tonumber(io.read())
print("Amount of parallels tunels ?")
amount = tonumber(io.read())
if amount > 1 then
	print("To the left or right ?")
	direction = io.read()
	if direction ~= "left" and direction ~= "right" then
		error("Unknown direction: " .. direction)
	end
	else
	direction = "right"
end

core(lenght, amount, direction)
