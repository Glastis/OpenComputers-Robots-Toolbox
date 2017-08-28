local move = require('movement')
local utilitie = require('utilities')
local energy = require('energy')
local chest = require('chest')
local inventory = require('inventory')
local environement = require('environement')
local net = require('net')

local component = require('component')
local robot = require('robot')
local side = require('sides')
local redstone = component.redstone
local generator = component.generator

local CRITICAL_ENERGY_PERCENT = 20
local CRITICAL_ENERGY_LEVEL
local ENERGY_CHECK_FREQ = 25
local INVENTORY_CHECK_FREQ = 10
local TOOL_ENERGY_FREQ = 200
local EMPTY_LAST_SLOTS_BEFORE_FULL = 3
local ENDERCHEST_INVENTORY_ID = 4082
local ENDERCHEST_TOOL_RECHARGE_ID = 4084
local ENDERCHEST_DROP_ID = 3003
local PASTE_URL = 'https://pastebin.com/raw/WYAwEyZ7'
local FILEPATH = 'mine'

local arg = {...}
local garbage_list = {}
local keep_list = {}
local offset = {}
local all_side = {}
local energy_check_act
local tool_check_act
local inventory_check_act

--[[
----    TOOL RECHARGING
--]]

function check_tool(force)
    local y

    if tool_check_act > TOOL_ENERGY_FREQ or force then
        y = place_bloc_down('EnderStorage:enderChest', ENDERCHEST_TOOL_RECHARGE_ID)
        if y then
            inventory.unequip()
            inventory.select_item('TConstruct:pickaxe')
            robot.dropDown()
            os.sleep(10)
            while not robot.suckDown() do
                os.sleep(5)
            end
            inventory.equip('TConstruct:pickaxe')
            robot.swingDown()
            move.move(y, side.up, true)
        end
        tool_check_act = 0
        return true
    end
    tool_check_act = tool_check_act + 1
    return false
end

--[[
----    ENERGY
--]]

function place_recharge_base()
    local y

    y = place_bloc_down('ThermalExpansion:Tesseract')
    if not y then
        return false
    end
    move.move(1, side.front, true)
    place_bloc_down('OpenComputers:charger')
    return y
end

function remove_recharge_base(y)
    robot.swingDown()
    move.move(1, side.back, true)
    robot.swingDown()
    move.move(y, side.up)
end

function activate_charger()
    redstone.setOutput(side.down, 15)
end

function go_recharging()
    local y
    local needs = {}

    needs[#needs + 1] = {}
    needs[#needs]['name'] = 'OpenComputers:charger'
    needs[#needs + 1] = {}
    needs[#needs]['name']  = 'ThermalExpansion:Tesseract'

    get_item_from_enderchest_inventory(needs)
    y = place_recharge_base()
    redstone.setOutput(side.down, 15)
    energy.wait_charging(activate_charger)
    redstone.setOutput(side.down, 0)
    remove_recharge_base(y)
    place_item_to_enderchest_inventory(needs)
    robot.select(1)
end

function check_energy(force)
    if energy_check_act < ENERGY_CHECK_FREQ and not force then
        energy_check_act = energy_check_act + 1
        return false
    end
    if energy.get_level() < CRITICAL_ENERGY_LEVEL or force then
        if generator.count == 0 and inventory.select_fuel() then
            generator.insert()
            robot.select(1)
        end
        check_inventory()
        go_recharging()
    end
    energy_check_act = 0
    return true
end

--[[
----    INVENTORY
--]]

function last_slots_filled()
    local slot
    local min

    min = robot.inventorySize() - EMPTY_LAST_SLOTS_BEFORE_FULL
    slot = robot.inventorySize()
    while slot >= min do
        if component.inventory_controller.getStackInInternalSlot(slot) then
            return true
        end
        slot = slot - 1
    end
    return false
end

function drop_inventory()
    local slot
    local data

    slot = robot.inventorySize()
    while slot >= 1 do
        data = component.inventory_controller.getStackInInternalSlot(slot)
        if data then
            if utilitie.is_elem_in_list(garbage_list, data.name) then
                robot.select(slot)
                robot.drop()
            elseif not utilitie.is_elem_in_list(keep_list, data.name) then
                robot.select(slot)
                robot.dropDown()
            end
        end
        slot = slot - 1
    end
end

function check_inventory(force)
    local i

    if inventory_check_act > INVENTORY_CHECK_FREQ or force then
        if last_slots_filled() or force then
            i = place_bloc_down('EnderStorage:enderChest', ENDERCHEST_DROP_ID)
            if i then
                drop_inventory()
            end
            robot.select(1)
            robot.swingDown()
            move.move(i, side.up, true)
        end
        inventory_check_act = 0
        return true
    end
    inventory_check_act = inventory_check_act + 1
    return false
end

function get_item_from_enderchest_inventory(item_list)
    local i
    local y
    local retval

    retval = true
    y = place_bloc_down('EnderStorage:enderChest', ENDERCHEST_INVENTORY_ID)
    if not y then
        return false
    end
    i = 1
    while i <= #item_list do
        if not chest.get_item_from_chest(item_list[i]['name'], item_list[i]['id'], nil, side.down) then
            retval = false
        end
        i = i + 1
    end
    robot.swingDown()
    move.move(y, side.up, true)
    return retval
end

function place_item_to_enderchest_inventory(item_list)
    local i
    local y
    local retval

    retval = true
    y = place_bloc_down('EnderStorage:enderChest', ENDERCHEST_INVENTORY_ID)
    if not y then
        return false
    end
    i = 1
    while i <= #item_list do
        if not inventory.select_item(item_list[i]['name'], item_list[i]['id']) then
            retval = false
        else
            robot.dropDown()
        end
        i = i + 1
    end
    robot.swingDown()
    move.move(y, side.up, true)
    robot.select(1)
    return retval
end

--[[
----    ENVIRONEMENT
--]]

function place_bloc_down(name, meta)
    local i

    i = 0
    if not inventory.select_item(name, meta) then
        return false
    end
    while not robot.placeDown() do
        robot.swingDown()
        if robot.placeDown() then
            robot.select(1)
            return i
        end
        move.move(1, side.down, true)
        i = i + 1
    end
    robot.select(1)
    return i
end

function check_ore(from_side)
    local i
    local tmp
    local ore_side = {}

    i = 0
    while i < #all_side do
        if not from_side or (all_side[i] ~= from_side) then
            tmp = environement.get_bloc(all_side[i])
            if tmp and not utilitie.is_elem_in_list(garbage_list, tmp) then
                ore_side[#ore_side + 1] = all_side[i]
            end
        end
        i = i + 1
    end
    return ore_side
end

function extract_ore(from_side, offset_rec)
    local ore_side
    local act_offset = {}
    local tmp
    local multi

    multi = false
    ore_side = check_ore(from_side)
    act_offset.x = 0
    act_offset.y = 0
    act_offset.z = 0
    while #ore_side > 1 do
        if not multi then
            tmp = environement.get_bloc(ore_side[1])
        end
        if not multi or (tmp and not utilitie.is_elem_in_list(garbage_list, tmp)) then
            act_offset.x = 0
            act_offset.y = 0
            act_offset.z = 0
            print('loop')
            print('side: ' .. ore_side[1])
            print('bloc: ' .. tostring(tmp))
            move.move(1, ore_side[1], true)
            act_offset =  add_to_offset(1, ore_side[1], act_offset)
            extract_ore(ore_side[1], act_offset)
        end
        table.remove(ore_side, 1)
        check_all_status()
        multi = true
    end
    if #ore_side == 1 then
        if multi then
            tmp = environement.get_bloc(ore_side[1])
        end
        if not multi or (tmp and not utilitie.is_elem_in_list(garbage_list, tmp)) then
            print('rec')
            print('side: ' .. ore_side[1])
            print('bloc: ' .. tostring(tmp))
            move.move(1, ore_side[1], true)
            if not offset_rec then
                act_offset.x = 0
                act_offset.y = 0
                act_offset.z = 0
                offset_rec = act_offset
            end
            offset_rec =  add_to_offset(1, ore_side[1], offset_rec)
            check_all_status()
            return extract_ore(ore_side[1], offset_rec)
        end
    end
    if not offset_rec then
        return true
    end
    return_to_origin(offset_rec)
    return true
end

--[[
----    OFFSET
--]]

function return_to_origin(offset_act)
    if offset_act.x >= 0 then
        move.move(offset_act.x, side.back, true, extract_ore)
    else
        move.move(-offset_act.x, side.front, true, extract_ore)
    end
    if offset_act.y >= 0 then
        move.move(offset_act.y, side.down, true, extract_ore)
    else
        move.move(-offset_act.y, side.up, true, extract_ore)
    end
    if offset_act.z >= 0 then
        move.move(offset_act.z, side.right, true, extract_ore)
    else
        move.move(-offset_act.z, side.left, true, extract_ore)
    end
end

function add_to_offset(number_moves, direction, offset_act)
    if direction == side.up then
        offset_act.y = offset_act.y + number_moves
    elseif direction == side.down then
        offset_act.y = offset_act.y - number_moves
    elseif direction == side.front then
        offset_act.x = offset_act.x + number_moves
    elseif direction == side.back then
        offset_act.x = offset_act.x - number_moves
    elseif direction == side.left then
        offset_act.z = offset_act.z + number_moves
    elseif direction == side.right then
        offset_act.z = offset_act.z - number_moves
    end
    return offset_act
end

--[[
----    MOVE
--]]

function move_and_extract(len, dir)
    while len > 0 do
        move.move(1, dir, true)
        extract_ore(move.get_orientation_revert(dir))
        len = len - 1
    end
end

function case()
    extract_ore(side.back)
    if offset.y > 0 then
        move_and_extract(2, side.down)
        offset.y = offset.y - 2
    elseif offset.y < 0 then
        move_and_extract(2, side.up)
        offset.y = offset.y + 2
    else
        move_and_extract(1, side.up)
        move.move(2, side.down, true)
        extract_ore(side.up)
        offset.y = offset.y - 1
    end
end

function line(max)
    case()
    while offset.x < max do
        move.move(1, side.front, true)
        offset.x = offset.x + 1
        case()
        check_all_status()
    end
end

function core(len, amount, dir)
    dir = not dir
    check_all_status(true)
    while amount > 0 do
        offset.x = 0
        line(len)
        move.turn_bool(dir)
        offset.x = 0
        line(3)
        move.turn_bool(dir)
        move.turn_bool(dir)
        offset.x = 0
        move.move(3, side.forward, true)
        line(4)
        dir = not dir
        move.turn_bool(dir)
        amount = amount - 1
    end
end

--[[
----    MAIN
--]]

function check_all_status(force)
    check_inventory(force)
    check_tool(force)
    check_energy(force)
end

function init()
    offset.x = 0
    offset.y = 0
    offset.z = 0

    energy_check_act = 0
    tool_check_act = 0
    inventory_check_act = 0

    all_side[#all_side + 1] = side.front
    all_side[#all_side + 1] = side.up
    all_side[#all_side + 1] = side.down
    all_side[#all_side + 1] = side.left
    all_side[#all_side + 1] = side.right
    all_side[#all_side + 1] = side.back

    garbage_list[#garbage_list + 1] = 'minecraft:stone'
    garbage_list[#garbage_list + 1] = 'minecraft:air'
    garbage_list[#garbage_list + 1] = 'minecraft:dirt'
    garbage_list[#garbage_list + 1] = 'minecraft:gravel'
    garbage_list[#garbage_list + 1] = 'chisel:limestone'
    garbage_list[#garbage_list + 1] = 'chisel:marble'
    garbage_list[#garbage_list + 1] = 'ProjRed|Exploration:projectred.exploration.stone'
    garbage_list[#garbage_list + 1] = 'minecraft:stonebrick'
    garbage_list[#garbage_list + 1] = 'minecraft:water'
    garbage_list[#garbage_list + 1] = 'minecraft:cobblestone'
    garbage_list[#garbage_list + 1] = 'minecraft:lava'
    garbage_list[#garbage_list + 1] = 'minecraft:mossy_cobblestone'
    garbage_list[#garbage_list + 1] = 'minecraft:nether_brick_stairs'
    garbage_list[#garbage_list + 1] = 'minecraft:netherrack'
    garbage_list[#garbage_list + 1] = 'minecraft:netherbrick'
    garbage_list[#garbage_list + 1] = 'minecraft:nether_brick'

    keep_list[#keep_list + 1] = 'TConstruct:pickaxe'
    keep_list[#keep_list + 1] = 'EnderStorage:enderChest'
    keep_list[#keep_list + 1] = 'OpenComputers:charger'
    keep_list[#keep_list + 1] = 'ThermalExpansion:Tesseract'

    CRITICAL_ENERGY_LEVEL = math.floor((energy.get_max_energy() * CRITICAL_ENERGY_PERCENT) / 100)
end

function get_user_args()
    local len
    local amount
    local dir

    print("Tunnel lenght ?")
    len = tonumber(io.read())
    print("Amount of parallels tunels ?")
    amount = tonumber(io.read())
    if amount > 1 then
        print("To the left or right ?")
        dir = io.read()
        if dir ~= "left" and dir ~= "right" then
            error("Unknown direction: " .. dir)
        end
    else
        dir = "right"
    end
    dir = false
    if dir == "left" then
        dir = true
    end
    return len, amount, dir
end

function update()
    print('Updating...')
    if net.get_page_to_file(PASTE_URL, FILEPATH) then
        print('Updated successfully.')
        return true
    end
    print('Failed to update.')
    return false
end

if arg[1] and (arg[1] == '-u' or arg[1] == '--update') then
    return update()
end

init()
core(get_user_args())