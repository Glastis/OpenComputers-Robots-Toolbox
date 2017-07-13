local robot = require("robot")
local side = require("sides")
local component = require("component")

local offset = { x = 0, y = 0, z = 0 }
local errno = "unknown error"
local minerals = {}
local unwanted = {}

function init()
	get_minerals()
	get_unwanted_minerals()
end
function move_up(x)
	if not x then
		local x = 1
	end
	local i = 0

	while i < x do
		if not robot.up() then
			smart_swingUp()
		else
			i = i + 1
		end

	end
end
function move_down(x)
	if not x then
		local x = 1
	end
	local i = 0

	while i < x do
		if not robot.down() then
			smart_swingDown()
		else
			i = i + 1
		end

	end
end
function get_minerals()
	table.insert(minerals, "minecraft:no_one")
end
function get_unwanted_minerals()
	table.insert(unwanted, "minecraft:diamond_ore")
	table.insert(unwanted, "minecraft:iron_ore")
	table.insert(unwanted, "minecraft:gold_ore")
	table.insert(unwanted, "minecraft:quartz_ore")
	table.insert(unwanted, "minecraft:emerald_ore")
	table.insert(unwanted, "minecraft:lapis_ore")
	table.insert(unwanted, "minecraft:redstone_ore")
	table.insert(unwanted, "minecraft:obsidian")
end
function is_mineral(bloc)
	local i = 1

	while i <= #minerals do
		if bloc == minerals[i] then
			return true
		end
		i = i + 1
	end
	return false
end
function is_unwanted_mineral(bloc)
	local i = 1

	while i <= #unwanted do
		if bloc == unwanted[i] then
			return true
		end
		i = i + 1
	end
	return false
end
function equip_diamond_pickaxe()
	if select_item("minecraft:diamond_pickaxe") and component.inventory_controller.equip() then
		robot.select(1)
		return true
	end
	robot.select(1)
	return false
end
function equip_classic_pickaxe()
	if not select_item("minecraft:stone_pickaxe") and not select_item("minecraft:iron_pickaxe") and not craft_pickaxe() then
		print(errno)
		while robot.down() do end
		os.exit()
		return false
	elseif not select_item("minecraft:stone_pickaxe") and not select_item("minecraft:iron_pickaxe") then
		print(errno)
		os.exit()
		return false
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
function check_filon()
	local bloc

	bloc = component.geolyzer.analyze(side.left)
	if is_mineral(bloc.name) then
		return true, side.left
	end
	bloc = component.geolyzer.analyze(side.right)
	if is_mineral(bloc.name) then
		return true, side.right
	end
	bloc = component.geolyzer.analyze(side.up)
	if is_mineral(bloc.name) then
		return true, side.up
	end
	bloc = component.geolyzer.analyze(side.down)
	if is_mineral(bloc.name) then
		return true, side.down
	end
	bloc = component.geolyzer.analyze(side.back)
	if is_mineral(bloc.name) then
		return true, side.back
	end
	bloc = component.geolyzer.analyze(side.front)
	if is_mineral(bloc.name) then
		return true, side.front
	end
	return false, nil
end
function extract_filon(direction)
	local success, dir

	if is_inventory_full() then
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
function select_item(item)
    local slot = 1
	local size = robot.inventorySize()

	errno = "unknown error"
    while slot <= size do
        local data = component.inventory_controller.getStackInInternalSlot(slot)
        if data and data.name == item then
            robot.select(slot)
            return true
        end
        slot = slot + 1
    end
	errno = "Can't select: " .. item
    return false
end
function select_next_item(slot, item)
	local data
	local size = robot.inventorySize()

	while slot <= robot.inventorySize() do
		data = component.inventory_controller.getStackInInternalSlot(slot)
		if data and data.name == item then
			robot.select(slot)
			return true
		end
		slot = slot + 1
	end
	return false
end
function repack_item(item)
	local slot = 1
	local data
	local size = robot.inventorySize()

	while slot < size do
		data = component.inventory_controller.getStackInInternalSlot(slot)
		if not data or (data.name == item and data.size < 64) then
			if select_next_item(slot + 1, item) then
				robot.transferTo(slot)
				data = component.inventory_controller.getStackInInternalSlot(slot)
			else
				return true
			end
		end
		if data and ((data.name == item and data.size == 64) or data.name ~= item) then
			slot = slot + 1
		end
	end
	return true
end
function clean_inventory()
	local slot = 1
	local data
	local cobble = false

	repack_item("minecraft:cobblestone")
	while slot <= robot.inventorySize() do
		data = component.inventory_controller.getStackInInternalSlot(slot)
		if data and (is_mineral(data.name) or data.name == "minecraft:diamond" or data.name == "minecraft:emerald" or data.name == "minecraft:iron_ingot" or (data.name == "minecraft:dye" and data.damage == 4) or data.name == "minecraft:diamond_pickaxe" or data.name == "minecraft:stone_pickaxe" or data.name == "minecraft:iron_pickaxe" or data.name == "minecraft:log" or data.name == "minecraft:planks" or data.name == "minecraft:stick") then
			repack_item(data.name)
		elseif data and not cobble and data.name == "minecraft:cobblestone" then
			cobble = true
		elseif data then
			robot.select(slot)
			robot.drop()
		end
		slot = slot + 1
	end
end
function smart_swing()
	local bloc

	bloc = component.geolyzer.analyze(side.front)
	if is_mineral(bloc.name) or is_unwanted_mineral(bloc.name) then
		if not equip_diamond_pickaxe() then
			-- error("No diamond pickaxe found !")
			return false
		end
	else
		if not equip_classic_pickaxe() then
			-- error("No pickaxe can be crafted: " .. errno)
			return false
		end
	end
	robot.swing()
	if not unequip() then
		return false
	end
	return true
end
function smart_swingUp()
	local bloc

	bloc = component.geolyzer.analyze(side.top)
	if is_mineral(bloc.name) or is_unwanted_mineral(bloc.name) then
		if not equip_diamond_pickaxe() then
			error("No diamond pickaxe found !")
			return false
		end
	else
		if not equip_classic_pickaxe() then
			error("No pickaxe can be crafted: " .. errno)
			return false
		end
	end
	robot.swingUp()
	if not unequip() then
		return false
	end
	return true
end
function smart_swingDown()
	local bloc

	bloc = component.geolyzer.analyze(side.bottom)
	if is_mineral(bloc.name) or is_unwanted_mineral(bloc.name) then
		if not equip_diamond_pickaxe() then
			error("No diamond pickaxe found !")
			return false
		end
	else
		if not equip_classic_pickaxe() then
			error("No pickaxe can be crafted: " .. errno)
			return false
		end
	end
	robot.swingDown()
	if not unequip() then
		return false
	end
	return true
end
function is_inventory_full()
	local slot = 1
	local data

	while slot <= robot.inventorySize() do
		data = component.inventory_controller.getStackInInternalSlot(slot)
		if not data then
			return false
		end
		slot = slot + 1
	end
	return true
end
function avance()
	if is_inventory_full() then
		clean_inventory()
	end
	while not robot.forward() do
		smart_swing()
	end
end
function line(i)
	while i > 0 do
		avance()
		i = i - 1
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
function dig_slice(xmax, ymax)
	local boule = false
	local ymax_bkp = ymax

	while ymax > 0 do
		line(xmax)
		robot.turnLeft()
		robot.turnLeft()
		boule = xor_bool(boule)
		if ymax == 1 and boule == true then
			line(xmax)
			robot.turnLeft()
			robot.turnLeft()
		elseif ymax ~= 1 then
			move_up(1)
		end
		ymax = ymax - 1
	end
	move_down(ymax_bkp - 1)
end
function core(xmax, ymax, zmax, dir)
	while zmax > 0 do
		dig_slice(xmax, ymax)
		if zmax > 1 and dir == "left" then
			robot.turnLeft()
			line(1)
			robot.turnRight()
		elseif zmax > 1 then
			robot.turnRight()
			line(1)
			robot.turnLeft()
		end
		zmax = zmax - 1
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

	while slot <= 11 do
		if slot ~= 4 and slot ~= 8 then
			if component.inventory_controller.getStackInInternalSlot(slot) and not push_item_after_slot(slot) then
				return false
			end
		end
		slot = slot + 1
	end
	return true
end
function craft_pickaxe()
	local material
	local i = 1

	if empty_cases_amount() <= 10 then
		clean_inventory()
	end
	if empty_cases_amount() >= 10 and pickaxe_materials() and free_crafting_table() then
		if select_item("minecraft:iron_ingot") then
			material = "minecraft:iron_ingot"
		elseif select_item("minecraft:cobblestone") then
			material = "minecraft:cobblestone"
		else
			return false
		end
		if select_next_item(1, "minecraft:stick") and robot.transferTo(6, 1) and select_item("minecraft:stick") and (robot.select() ~= 6 or select_next_item(7, "minecraft:stick")) and robot.transferTo(10, 1) then
			while i <= 3 do
				if not select_next_item(4, material) or not robot.transferTo(i, 1) then
					return false
				end
				i = i + 1
			end
			if material == "minecraft:iron_ingot" then
				return component.crafting.craft(), "minecraft:iron_pickaxe"
			elseif material == "minecraft:iron_ingot" then
				return component.crafting.craft(), "minecraft:stone_pickaxe"
			end
			return component.crafting.craft(), nil
		end
	end
	errno = "No crafing components or no empty space"
	return false
end
function craft_sticks()
	if not free_crafting_table() then
		return false
	end
	if not select_item("minecraft:planks") and not craft_planks() then
		return false
	end
	if not free_crafting_table() then
		return false
	end
	if select_item("minecraft:planks") then
		robot.transferTo(1, 1)
		if select_next_item(3, "minecraft:planks") then
			robot.transferTo(5, 1)
		else
			return false
		end
		return component.crafting.craft(1)
	end
	return false

end
function craft_planks()
	if not free_crafting_table() or not select_item("minecraft:log") then
		return false
	end
	if robot.transferTo(1, 1) then
		return component.crafting.craft(1)
	end
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

local arg = {...}
if not arg or not arg[1] or not arg[2] or not arg[3] or not arg[4] or arg[4] ~= "left" and arg[4] ~= "right" then
	print("mic [x max] [y max] [z max] [left or right]")
	os.exit()
end
init()
core(tonumber(arg[1]), tonumber(arg[2]), tonumber(arg[3]), arg[4])
