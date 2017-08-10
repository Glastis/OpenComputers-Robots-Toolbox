local move = require('common.movement')
local utilitie = require('common.utilities')
local energy = require('common.energy')
local chest = require('common.chest')
local inventory = require('common.inventory')
local environement = require('common.environement')
local robot = require("robot")
local side = require("sides")

local PASTE_ID = 'KzP5EAya'
local SCRIPT_NAME = 'foody'
local FIELD_X_SIZE = 9
local FIELD_Y_SIZE = 9
local FIELD_DIRECTION = 'right'
local FIELD_AMOUNT = 5
local FIELD_WHEAT_NUMBER = 3
local MAIN_LOOP_MINUTES_SLEEP = 2
local MAIN_LOOP_SECONDS_SLEEP = MAIN_LOOP_MINUTES_SLEEP * 60
local args = {... }


-- Will be harverst one time every FREQUENCY loop.
local FREQUENCY_CHEST_DROP = 5
local FREQUENCY_APPLE = 10

local last_field = 4

function update()
    os.execute('rm ' .. SCRIPT_NAME)
    utilitie.download_file(PASTE_ID, SCRIPT_NAME, true)
end

function harvest_apples()
    move.move(2, side.up)
    move.move(4, side.back)
    move.move(7, side.right)
    robot.useUp()
    move.move(1, side.right)
    robot.useUp()
    move.move(3, side.left)
    move.move(1, side.back)
    robot.useUp()
    move.move(1, side.left)
    robot.useUp()
    move.move(4, side.left)
    move.move(5, side.front)
    move.move(2, side.down)
end

function harvest_plant(plant)
    if plant and plant == "minecraft:wheat" then
        local data

        if environement.get_bloc_meta(side.down) == 7 then
            robot.swingDown()
        end
        if inventory.select_item('minecraft:wheat_seeds') then
            robot.placeDown()
        end
    else
        robot.useDown()
    end
end

function check_seeds(plant)
    if plant and plant == 'minecraft:wheat' then
        robot.turnLeft()
        chest.get_item_from_chest('minecraft:wheat_seeds')
        robot.turnRight()
    end
    return true
end

function place_seeds(plant)
    if plant and plant == 'minecraft:wheat' then
        robot.turnLeft()
        if not chest.drop_item_to_chest('minecraft:wheat_seeds') then
            inventory.repack_item('minecraft:wheat_seeds')
        end
        robot.turnRight()
    end
    return true
end

function harvest_field(maxx, maxy, direction, plant)
    local sav = {}
    local bool

    bool = false
    if direction and direction == "left" then
        bool = true
    end
    sav['bool'] = bool
    sav['x'] = maxx
    sav['y'] = maxy
    check_seeds(plant)
    harvest_plant(plant)
    while maxy > 0 do
        move.forward()
        maxx = maxx - 1
        harvest_plant(plant)
        if maxx <= 1 then
            maxy = maxy - 1
            maxx = sav['x']
            if maxy > 0 then
                move.turn_bool(bool)
                move.forward()
                harvest_plant(plant)
                move.turn_bool(bool)
                bool = not bool
            else
                if sav['bool'] == bool then
                    move.turn_bool(bool)
                    move.turn_bool(bool)
                    move.forward(sav['x'] - 1)
                    bool = not bool
                end
                move.turn_bool(not bool)
                move.forward(sav['y'] - 1)
                move.turn_bool(not bool)
            end
        end
    end
    place_seeds(plant)
end

function go_base_to_fields()
    move.up()
    move.move(6, side.front)
end

function go_fields_to_base()
    move.move(6, side.back)
    move.down()
end

function harvest_next_field()
    go_base_to_fields()
    move.move(4 * last_field, side.up)
    move.move(2, side.front)
    if last_field == FIELD_WHEAT_NUMBER then
        harvest_field(FIELD_X_SIZE, FIELD_Y_SIZE, FIELD_DIRECTION, "minecraft:wheat")
    else
        harvest_field(FIELD_X_SIZE, FIELD_Y_SIZE, FIELD_DIRECTION)
    end
    move.move(2, side.back)
    move.move(4 * last_field, side.down)
    go_fields_to_base()
    last_field = last_field + 1
    if last_field >= FIELD_AMOUNT then
       last_field = 0
    end
end

function drop_inventory_to_chests()
    move.move(1, side.up)
    move.move(1)
    chest.drop_item_to_chest('minecraft:wheat_seeds', false, side.down)
    chest.drop_item_to_chest('TConstruct:oreBerries', false, side.up)
    move.move(1)
    chest.drop_item_to_chest('minecraft:wheat', false, side.down)
    chest.drop_item_to_chest('minecraft:apple', false, side.up)
    move.move(1)
    chest.drop_item_to_chest('harvestcraft:tomatoItem', false, side.down)
    move.move(1)
    chest.drop_item_to_chest('harvestcraft:soybeanItem', false, side.down)
    move.move(1)
    chest.drop_item_to_chest('harvestcraft:lettuceItem', false, side.down)
    move.move(5, side.back)
    move.move(1, side.down)
end

function garbage_all()
    local slot

    move.move(1, side.up)
    move.move(1, side.right)
    slot = robot.inventorySize()
    while slot > 1 do
        robot.select(slot)
        robot.dropDown()
        slot = slot - 1
    end
    move.move(1, side.left)
    move.move(1, side.down)
end

function core()
    local frequency_iter

    frequency_iter = 0
    while true do
        if frequency_iter % FREQUENCY_CHEST_DROP == 0 then
            energy.wait_charging()
            drop_inventory_to_chests()
            garbage_all()
        end
        energy.wait_charging()
        harvest_next_field()
        if frequency_iter % FREQUENCY_APPLE == 0 then
            energy.wait_charging()
            harvest_apples()
        end
        os.sleep(MAIN_LOOP_SECONDS_SLEEP)
        frequency_iter = frequency_iter + 1
        if frequency_iter > 2000000000 then --in case of scipt running non-stop 63 years.
            frequency_iter = 0
        end
    end
end

if args[1] == '-u' or args[1] == '--update' then
    update()
    return true
end

core()
