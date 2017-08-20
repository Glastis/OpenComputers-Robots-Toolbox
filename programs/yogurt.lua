local move = require('movement')
local utilitie = require('utilities')
local energy = require('energy')
local chest = require('chest')
local inventory = require('inventory')
local environement = require('environement')
local crafting = require('crafting')

local component = require('component')
local robot = require('robot')
local side = require('sides')

local YOGURT_PRODUCTION_STACK_AMOUNT = 0.25
local MILK_CRAFT_MULTIPLIER = 4
local SLEEP_MODE_TIMOUT_SECONDS = 120
local BUCKET_NOT_FOUND_SLEEP = 5

function draw_milk(amount)
    local min_slot

    min_slot = 1
    if not chest.get_item_from_chest('minecraft:bucket', nil, nil, side.down) then
        print('Bucket not found, can\'t craft milk.')
        os.sleep(BUCKET_NOT_FOUND_SLEEP)
        return false
    end
    if amount / 64 > robot.inventorySize() - 10 then
        amount = (robot.inventorySize() - 10) * 64
    end
    crafting.free_crafting_table()
    while amount > 0 do
        environement.fill_bucket(robot.front, true, true)
        crafting.place_item_for_craft('minecraft:milk_bucket', 1)
        crafting.craft()
        crafting.free_crafting_table()
        amount = amount - 1
    end
    chest.drop_item_to_chest('minecraft:bucket', nil, nil, side.down)
    return true
end

function craft_yogurt()
    local min_slot

    min_slot = 1
    if not draw_milk(YOGURT_PRODUCTION_STACK_AMOUNT * 64) or not chest.get_item_from_chest('harvestcraft:plainyogurtItem', nil, nil, side.down) then
        return false
    end
    crafting.free_crafting_table()
    while crafting.place_item_for_craft('harvestcraft:plainyogurtItem', 1, nil, 64) and crafting.place_item_for_craft('harvestcraft:freshmilkItem', 2, nil, 64) do
        component.crafting.craft()
        min_slot = crafting.move_item_out_of_crafting_table('harvestcraft:plainyogurtItem', min_slot)
    end
    inventory.select_item('harvestcraft:plainyogurtItem')
    robot.dropDown()
    chest.drop_item_to_chest('harvestcraft:plainyogurtItem', nil, nil, side.up)
    return true
end

function drop_or_wait()
    while inventory.select_item('harvestcraft:plainyogurtItem') do
        while not chest.is_empty(side.up) do
            print('Sleeping...')
            os.sleep(SLEEP_MODE_TIMOUT_SECONDS)
            print('Checking...')
        end
        chest.drop_item_to_chest('harvestcraft:plainyogurtItem', nil, nil, side.up)
    end
end

function core()
    while true do
        drop_or_wait()
        craft_yogurt()
    end
end

core()