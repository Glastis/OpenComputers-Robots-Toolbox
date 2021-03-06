local utilitie = require('utilities')
local chest = require('chest')
local inventory = require('inventory')
local net = require('net')

local component = require('component')
local robot = require('robot')
local side = require('sides')

local PASTE_URL = 'https://pastebin.com/raw/nSL5UAKp'
local FILEPATH = 'fortune'
local CHEST_SIDE_INPUT = side.up
local CHEST_SIDE_OUTPUT = side.down

local arg = {...}

local ore_list

--[[
----    INIT
--]]

function init()
    ore_list = {}
    ore_list[#ore_list + 1] = 'ProjRed|Exploration:projectred.exploration.ore'
    ore_list[#ore_list + 1] = 'qCraft:quantumore'
    ore_list[#ore_list + 1] = 'minecraft:coal_ore'
    ore_list[#ore_list + 1] = 'minecraft:diamond_ore'
end

--[[
----    INVENTORY FUNCTIONS
--]]

function get_ores()
    local i

    i = #ore_list
    while i > 0 do
        if chest.get_item_from_chest(ore_list[i], nil, nil, CHEST_SIDE_INPUT) then
            return i
        end
        i = i - 1
    end
    return false
end

function select_ore(ore_id)
    return inventory.select_item(ore_list[ore_id])
end

function drop_all_non_ore()
    local slot
    local data

    slot = robot.inventorySize()
    while slot > 0 do
        data = component.inventory_controller.getStackInInternalSlot(slot)
        if data and not utilitie.is_elem_in_list(ore_list, data.name) then
            chest.drop_slot_to_chest(CHEST_SIDE_OUTPUT, slot)
        end
        slot = slot - 1
    end
end

--[[
----    ENVIRONEMENT FUNCTIONS
--]]

function place_ore(ore_id)
    if not select_ore(ore_id) then
        return false
    end
    robot.place()
    return true
end

function place_and_mine_all_ores(ore_id)
    while place_ore(ore_id) do
        robot.swing()
    end
end

--[[
----    CORE FUNCTIONS
--]]

function core()
    local ore_id

    ore_id = get_ores()
    while ore_id do
        place_and_mine_all_ores(ore_id)
        drop_all_non_ore()
        ore_id = get_ores()
    end
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
core()