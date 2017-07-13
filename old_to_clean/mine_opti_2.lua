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


if arg and arg[1] and (arg[1] == "-v" or arg[1] == "--version") then
	print(tostring(version))
	os.exit()
end
if arg and arg[1] and (arg[1] == "-b" or arg[1] == "--build") then
	print(tostring(version))
	os.exit()
end
if arg and arg[1] and (arg[1] == "-nu" or arg[1] == "--no-update") then
	search_update = false
end

function init_shovel_blocs()
	table.insert(shovel_block, "minecraft:dirt")
	table.insert(shovel_block, "minecraft:gravel")
	table.insert(shovel_block, "minecraft:grass")
	table.insert(shovel_block, "minecraft:sand")
	table.insert(shovel_block, "minecraft:planks")
end
function init_essentials()
	table.insert(essentials, "minecraft:stone_pickaxe")
	table.insert(essentials, "minecraft:diamond_pickaxe")
	table.insert(essentials, "minecraft:coal")
	table.insert(essentials, "minecraft:log")
	table.insert(essentials, "minecraft:planks")
	table.insert(essentials, "minecraft:stick")
	table.insert(essentials, "minecraft:diamond")
	table.insert(essentials, "EnderStorage:enderChest")
	table.insert(essentials, "minecraft:cobblestone")
end
function init_diamond_requirered_blocs()
	table.insert(diamond_requirered_blocs, "minecraft:redstone_ore")
	table.insert(diamond_requirered_blocs, "minecraft:obsidian")
	table.insert(diamond_requirered_blocs, "minecraft:diamond_ore")
	table.insert(diamond_requirered_blocs, "minecraft:gold_ore")
	table.insert(diamond_requirered_blocs, "minecraft:emerald_ore")
	table.insert(diamond_requirered_blocs, "simpleores:mythril_ore")
	table.insert(diamond_requirered_blocs, "simpleores:adamantium_ore")
	table.insert(diamond_requirered_blocs, "simpleores:onyx_ore")
	table.insert(diamond_requirered_blocs, "IC2:blockOreUran")
	table.insert(diamond_requirered_blocs, "IC2:blockOreLead")
	table.insert(diamond_requirered_blocs, "minechem:tile.oreUranium")
	table.insert(diamond_requirered_blocs, "qCraft:quantumore")
	table.insert(diamond_requirered_blocs, "qCraft:quantumoreglowing")
	table.insert(diamond_requirered_blocs, "tc:oreTC")
	table.insert(diamond_requirered_blocs, "ProjRed|Exploration:projectred.exploration.ore")
	table.insert(diamond_requirered_blocs, "ThermalFoundation:Ore")
	table.insert(diamond_requirered_blocs, "SGCraft:naquadahOre")
end
function init()
	if search_update then
		check_update()
	end
	if not get_minerals() then
		print("Can't load config file\n")
		os.exit()
	end
	init_shovel_blocs()
	init_essentials()
	init_diamond_requirered_blocs()
	if not unequip() then
		error("I'm really full. Can't continue.")
	end
end
function my_split(inputstr, sep)
        if sep == nil then
                sep = "%s"
        end
        local t={} ; i=1
        for str in string.gmatch(inputstr, "([^"..sep.."]+)") do
                t[i] = str
                i = i + 1
				if i > 20 then
					return t
				end
        end
        return t
end
function check_update()
	local f
	local tmp
	local t = {}

	print("Checking updates...")
	shell.execute("pastebin get FuwV0wEv last_dmp_build.tmp.log")
	f = io.open("last_dmp_build.tmp.log",  "r")
	if not f then
		print("Can't check updates.")
		return false
	end
	tmp = f:read()
	f:close()
	t = my_split(tmp, " ")
	if t[2] == "build" and tonumber(t[4]) and tonumber(t[4]) > build then
		shell.execute("rm dmp")
		shell.execute("mv last_dmp_build.tmp.log dmp")
		shell.execute("rm " .. config_filename)
		print("Update found. Downloaded.")
		shell.execute("dmp --no-update")
		os.exit()
	end
	shell.execute("rm last_dmp_build.tmp.log")
	print("No updates found")
	return true
end
function load_config(name)
	local f
	local i = 1
	local tab = {}

	f = io.open(name,"r")
	if not f then
		return false
	end
	for line in f:lines() do
		tab[i] = line
		i = i + 1
	end
	f:close()
	return tab
end
function write_default_config(name, text)
	local f

	print(name .. " not foud. Creating default one.")
	f = io.open(name,"w")
	if not f then
		return false
	end
	f:write(text)
	f:close()
	return true
end
function file_exists(name)
	local f

	f=io.open(name,"r")
	if f then
		io.close(f)
		return true
	end
	return false
end
function get_minerals()
	if not file_exists(config_filename) and not write_default_config(config_filename, "minecraft:diamond_ore\nminecraft:iron_ore\nminecraft:gold_ore\nminecraft:emerald_ore\nminecraft:lapis_ore\nminecraft:dye\nminecraft:iron_ingot\nminecraft:emerald\nminecraft:diamond\nminecraft:diamond_block\nminecraft:coal_block\nminecraft:lapis_block\nminecraft:redstone_block\nminecraft:glowstone\nminecraft:glowstone_dust\nminecraft:quartz\nminecraft:quartz_ore\nminecraft:quartz_block\nminecraft:chest\nminecraft:diamond_pickaxe\nminecraft:stone_pickaxe\nminecraft:iron_pickaxe\nminecraft:log\nminecraft:planks\nminecraft:stick\nEnderStorage:enderChest\nsimpleores:copper_ore\nsimpleores:tin_ore\nsimpleores:mythril_ore\nsimpleores:adamantium_ore\nsimpleores:onyx_ore\nIC2:blockOreCopper\nIC2:blockOreTin\nIC2:blockOreUran\nIC2:blockOreLead\nminechem:tile.oreUranium\nqCraft:quantumore\nqCraft:quantumoreglowing\ntc:oreTC\nProjRed|Exploration:projectred.exploration.ore\nminecraft:redstone\nminecraft:coal_ore\nminecraft:coal\nThermalFoundation:Ore\nminecraft:redstone_ore\nqCraft:dust\nBigReactors:YelloriteOre\ntc:oreTC\nThermalFoundation:Ore\nSGCraft:naquadahOre\nProjRed|Core:projected.core.part\n") then
		return false
	end
	if not file_exists(stockpile_filename) and not write_default_config(stockpile_filename, "minecraft:diamond_ore\nminecraft:iron_ore\nminecraft:gold_ore\nminecraft:emerald_ore\nminecraft:lapis_ore\nminecraft:dye\nminecraft:iron_ingot\nminecraft:emerald\nminecraft:diamond\nminecraft:diamond_block\nminecraft:coal_block\nminecraft:lapis_block\nminecraft:redstone_block\nminecraft:glowstone\nminecraft:quartz_ore\nminecraft:quartz_block\n") then
		return false
	end
	minerals = load_config(config_filename)
	stockpile = load_config(stockpile_filename)
	if not minerals or not stockpile then
		return false
	end
	print(config_filename .. " loaded !")
	return true
end
function is_in_list(name, list)
	local i = 1

	while i <= #list do
		if name == list[i] then
			return true
		end
		i = i + 1
	end
	return false
end
function get_item_from_chest(name, meta, amount)
	local slot
	local data = {}

	slot = 1
	if (amount and amount <= 0) or not component.inventory_controller.getInventorySize(side.front) then
		return false
	end
	while slot <= component.inventory_controller.getInventorySize(side.front) do
		data = component.inventory_controller.getStackInSlot(side.front, slot)
		if data and data.name == name and (not meta or data.damage == meta) then
			if amount then
				component.inventory_controller.suckFromSlot(side.front, slot, amount)
			else
				component.inventory_controller.suckFromSlot(side.front, slot)
			end
			return true
		end
		slot = slot + 1
	end
	return false
end
function select_item_failsafe(item, trymax, meta)
	local try = 0

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
		os.sleep(30)
	end
end
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
function xor_bool(bool)
	if bool then
		return false
		else
		return true
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
function empty_cases_amount()
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
