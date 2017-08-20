local move = require('movement')
local utilitie = require('utilities')
local energy = require('energy')
local chest = require('chest')
local inventory = require('inventory')
local environement = require('environement')
local crafting = require('crafting')
local computer = require('computer')

local component = require('component')
local robot = require('robot')
local side = require('sides')

local arg = {...}

local CRITICAL_ENERGY_LEVEL = 10000
local CHECK_FUEL_FREQ = 10
local CHECK_INV_FREQ = 32

local offset = {}
local check_fuel_act = 0
local check_inv_act = 0

--[[
----    INVENTORY
--]]

function update()

end

function equip_pick()
    inventory.equip('ExtraUtilities:destructionpickaxe')
end

function place_chest()
    local i

    i = 0
    if not inventory.select_item('EnderStorage:enderChest', 3003) then
        return false
    end
    while not robot.place() and move.move(1, side.down, true) do
        i = i + 1
    end
    move.move(i, side.up, true)
    return true
end

function get_inventory_map()
    local i
    local size
    local inv_map = {}
    local tmp

    size = robot.inventorySize()
    i = 1
    while i <= size do
        tmp = component.inventory_controller.getStackInInternalSlot(i)
        if not tmp then
            return false
        end
        inv_map[#inv_map + 1] = tmp
        i = i + 1
    end
end

function drop_all(inv_map)
    local i

    i = 1
    place_chest()
    while i <= #inv_map do
        if inv_map[i].name == 'minecraft:cobblestone' then
            robot.select(i)
            robot.dropDown()
        elseif inv_map[i] then

        end
    end
end

function check_inventory()
    local inv_map

    if check_inv_act > CHECK_INV_FREQ then
        inv_map = get_inventory_map()
        if not inv_map then
            place_chest()
            drop_all(inv_map)
        end
        check_inv_act = 0
    else
        check_inv_act = check_inv_act + 1
    end
end

--[[
----    FUEL
--]]

function check_fuel()
    if check_fuel_act > CHECK_FUEL_FREQ then
        if computer.energy() < CRITICAL_ENERGY_LEVEL then
            go_refuel()
        end
        check_fuel_act = 0
    else
        check_fuel_act = check_fuel_act + 1
    end
end

function go_refuel()
    go_mining_to_refuel()
    energy.wait_charging()
    go_refuel_to_mining(sav)
end

function go_mining_to_refuel()
    if offset.side == side.left then
        move.move(offset.z, side.right, true)
    else
        move.move(offset.z, side.left, true)
    end
    move.move(offset.y, side.down, true)
    move.move(offset.x, side.back, true)
end

function go_refuel_to_mining()
    move.move(offset.x, side.front, true)
    move.move(offset.y, side.up, true)
    move.move(offset.z, offset.side, true)
end

--[[
----    MINE
--]]

function column(maxy, offset_bkp)
    while (offset_bkp == 0 and maxy > offset.y) or (offset_bkp > 0 and offset.y > 0) do
        if offset_bkp == 0 then
            move.move(1, side.up, true)
            offset.y = offset.y + 1
        else
            move.move(1, side.down, true)
            offset.y = offset.y - 1
        end
        check_fuel()
        check_inventory()
    end
end

function slice(maxx, maxy, offset_bkp)
    column(maxy, offset.y)
    while (offset_bkp == 0 and maxx > offset.x) or (offset_bkp > 0 and offset.x > 0) do
        if offset_bkp == 0 and maxx > offset.x + 1 then
            move.move(1, side.front, true)
            offset.x = offset.x + 1
        else
            move.move(1, side.back, true)
            offset.x = offset.x - 1
        end
        column(maxy, offset.y)
        check_fuel()
        check_inventory()
    end
end

function cube(maxx, maxy, maxz)
    local turn_left

    turn_left = false
    if offset.side == side.left then
        turn_left = true
    end
    while maxz > offset.z do
        slice(maxx, maxy, offset.x)
        move.move(1, offset.side, true)
        offset.z = offset.z + 1
        check_fuel()
        check_inventory()
    end
    if offset.y > 0 then
        move.move(offset.y, side.down, true)
    end
end

--[[
----    MAIN
--]]

function init()
    local dir = {}

    dir['left'] = side.left
    dir['right'] = side.right
    offset.x = 0
    offset.y = 0
    offset.z = 0
    offset.side = dir[arg[4]]
end

function core()
    init()
    cube(tonumber(arg[1]), tonumber(arg[2]), tonumber(arg[3]))
end

if not arg[1] or not arg[2] or not arg[3] or (tonumber(arg[3]) > 1 and (not arg[4] or (arg[4] ~= 'left' and arg[4] ~= 'right'))) then
    print('./dig x y z direction')
    return false
end
core()
return true