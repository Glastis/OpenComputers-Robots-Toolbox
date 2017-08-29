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

local PASTE_ID = 'KzP5EAya'
local SCRIPT_NAME = 'foody'
local FIELD_X_SIZE = 9
local FIELD_Y_SIZE = 9
local FIELD_DIRECTION = 'right'
local MAIN_LOOP_MINUTES_SLEEP = 0
local MAIN_LOOP_SECONDS_SLEEP = (MAIN_LOOP_MINUTES_SLEEP * 60) + 30
local SALT_PRODUCTION_STACK_AMOUNT = 1
local WATER_PRODUCTION_STACK_AMOUNT = 1
local MIN_SLOTS_EMPTY = 13
local args = {... }

local CHEST_MAP = {}
local FIELD_MAP = {}
local need_list = {}

-- Will be harverst one time every FREQUENCY loop.
local FREQUENCY_CHEST_DROP = 30
local FREQUENCY_SALT = 4
local FREQUENCY_WATER = 4
local FREQUENCY_APPLE = 30
local FREQUENCY_BREAD = 10
local FREQUENCY_DOUGHT = 10
local FREQUENCY_FLOUR = 10
local FREQUENCY_TOAST = 10
local FREQUENCY_MILK_TOFU = 20
local FREQUENCY_SILKEN_TOFU = 20
local FREQUENCY_HAMBURGER = 25
local FREQUENCY_CHEESEBURGER = 25
local FREQUENCY_DELUXECHEESEBURGER = 25
local FREQUENCY_DELIGHTEDMEAL = 25
local FREQUENCY_CHEESE = 20

local last_field

function init()
    local tmp

    tmp = {}
    tmp[#tmp + 1] = {}
    tmp[#tmp][side.up] = 'harvestcraft:saltItem'
    tmp[#tmp][side.down] = 'harvestcraft:freshwaterItem'
    tmp[#tmp + 1] = {}
    tmp[#tmp][side.up] = 'harvestcraft:soybeanItem'
    tmp[#tmp][side.down] = 'harvestcraft:lettuceItem'
    tmp[#tmp + 1] = {}
    tmp[#tmp][side.up] = 'harvestcraft:silkentofuItem'
    tmp[#tmp][side.down] = 'harvestcraft:soymilkItem'
    tmp[#tmp + 1] = {}
    tmp[#tmp][side.up] = 'harvestcraft:firmtofuItem'
    tmp[#tmp][side.down] = 'minecraft:wheat_seeds'
    tmp[#tmp + 1] = {}
    tmp[#tmp][side.up] = 'harvestcraft:cheeseItem'
    tmp[#tmp][side.down] = 'harvestcraft:hamburgerItem'
    tmp[#tmp + 1] = {}
    tmp[#tmp][side.up] = 'harvestcraft:deluxecheeseburgerItem'
    tmp[#tmp][side.down] = 'harvestcraft:cheeseburgerItem'
    tmp[#tmp + 1] = {}
    tmp[#tmp][side.up] = 'harvestcraft:friesItem'
    tmp[#tmp][side.down] = 'harvestcraft:whitemushroomItem'
    tmp[#tmp + 1] = {}
    tmp[#tmp][side.up] = 'harvestcraft:zucchiniItem'
    tmp[#tmp][side.down] = 'harvestcraft:cabbageItem'
    tmp[#tmp + 1] = {}
    tmp[#tmp][side.up] = 'harvestcraft:tealeafItem'
    tmp[#tmp][side.down] = 'harvestcraft:cupofteaItem'
    CHEST_MAP[#CHEST_MAP + 1] = tmp

    tmp = {}
    tmp[#tmp + 1] = {}
    tmp[#tmp][side.up] = 'harvestcraft:melonsmoothieItem'
    tmp[#tmp][side.down] = "TConstruct:oreBerries"
    tmp[#tmp + 1] = {}
    tmp[#tmp][side.up] = 'harvestcraft:flourItem'
    tmp[#tmp][side.down] = "minecraft:wheat"
    tmp[#tmp + 1] = {}
    tmp[#tmp][side.up] = 'harvestcraft:doughItem'
    tmp[#tmp][side.down] = "minecraft:apple"
    tmp[#tmp + 1] = {}
    tmp[#tmp][side.up] = 'harvestcraft:delightedmealItem'
    tmp[#tmp][side.down] = "harvestcraft:tomatoItem"
    tmp[#tmp + 1] = {}
    tmp[#tmp][side.up] = 'harvestcraft:coffeebeanItem'
    tmp[#tmp][side.down] = 'minecraft:bread'
    tmp[#tmp + 1] = {}
    tmp[#tmp][side.up] = 'harvestcraft:cottonItem'
    tmp[#tmp][side.down] = 'harvestcraft:toastItem'
    tmp[#tmp + 1] = {}
    tmp[#tmp][side.up] = 'harvestcraft:delightedmealItem'
    CHEST_MAP[#CHEST_MAP + 1] = tmp

    last_field = {}

    tmp = {}
    tmp[#tmp + 1] ="harvestcraft:lettuceItem"
    tmp[#tmp + 1] ="harvestcraft:soybeanItem"
    tmp[#tmp + 1] ="harvestcraft:tomatoItem"
    tmp[#tmp + 1] ="minecraft:wheat"
    tmp[#tmp + 1] ="TConstruct:oreBerries"
    tmp[#tmp + 1] ="minecraft:wheat"
    tmp[#tmp + 1] ="minecraft:wheat"
    tmp[#tmp + 1] ="harvestcraft:coffeebeanItem"
    FIELD_MAP[#FIELD_MAP + 1] = tmp

    tmp = {}
    tmp[#tmp + 1] ="harvestcraft:zucchiniItem"
    tmp[#tmp + 1] ="harvestcraft:cabbageItem"
    tmp[#tmp + 1] ="harvestcraft:tealeafItem"
    tmp[#tmp + 1] ="harvestcraft:whitemushroomItem"
    tmp[#tmp + 1] ="harvestcraft:cottonItem"
    FIELD_MAP[#FIELD_MAP + 1] = tmp

    last_field.y = #tmp
    last_field.x = 2
end

function update()
    os.execute('rm ' .. SCRIPT_NAME)
    utilitie.download_file(PASTE_ID, SCRIPT_NAME, true)
end

--[[
----    APPLES PRODUCTION
--]]

function harvest_apples()
    if not utilitie.is_elem_in_list(need_list, 'minecraft:apple') then
        return false
    end
    move.move(4, side.right)
    move.move(5, side.back)
    robot.useUp()
    move.move(4, side.back)
    move.move(3, side.right)
    move.move(1, side.back)
    robot.useUp()
    move.move(1, side.front)
    move.move(1, side.right)
    move.move(1, side.up)
    robot.useUp()
    move.move(1, side.down)
    move.move(4, side.left)
    move.move(2, side.back)
    move.move(1, side.right)
    robot.useUp()
    move.move(1, side.back)
    move.move(1, side.right)
    robot.useUp()
    move.move(6, side.left)
    move.move(1, side.back)
    move.move(1, side.up)
    robot.useUp()
    move.move(1, side.left)
    move.move(2, side.front)
    robot.useUp()
    move.move(2, side.front)
    robot.useUp()
    move.move(2, side.right)
    robot.useUp()
    move.move(1, side.down)
    move.move(3, side.right)
    move.move(2, side.front)
    move.move(4, side.right)
    robot.useUp()
    move.move(2, side.front)
    robot.useUp()
    move.move(1, side.front)
    robot.useUp()
    move.move(1, side.front)
    robot.useUp()
    move.move(1, side.left)
    move.move(1, side.back)
    robot.useUp()
    move.move(1, side.left)
    move.move(1, side.front)
    robot.useUp()
    move.move(1, side.left)
    move.move(1, side.back)
    robot.useUp()
    move.move(1, side.left)
    move.move(4, side.front)
    move.move(4, side.left)
    return true
end

--[[
----    BURGERS PRODUCTION
--]]

function make_hamburger()
    local ingredient = {}
    local tool = {}

    ingredient[#ingredient + 1] = {}
    ingredient[#ingredient]['item'] = 'harvestcraft:toastItem'
    ingredient[#ingredient]['slot'] = 4
    ingredient[#ingredient + 1] = {}
    ingredient[#ingredient]['item'] = 'harvestcraft:firmtofuItem'
    ingredient[#ingredient]['slot'] = 2
    tool[#tool + 1] = {}
    tool[#tool]['item'] = 'harvestcraft:skilletItem'
    tool[#tool]['slot'] = 1

    return make('harvestcraft:hamburgerItem', ingredient, tool)
end

function make_cheese()
    local ingredient = {}
    local tool = {}

    ingredient[#ingredient + 1] = {}
    ingredient[#ingredient]['item'] = 'harvestcraft:soymilkItem'
    ingredient[#ingredient]['slot'] = 2
    ingredient[#ingredient + 1] = {}
    ingredient[#ingredient]['item'] = 'harvestcraft:saltItem'
    ingredient[#ingredient]['slot'] = 4
    tool[#tool + 1] = {}
    tool[#tool]['item'] = 'harvestcraft:potItem'
    tool[#tool]['slot'] = 1

    return make('harvestcraft:cheeseItem', ingredient, tool)
end

function make_cheeseburger()
    local ingredient = {}

    ingredient[#ingredient + 1] = {}
    ingredient[#ingredient]['item'] = 'harvestcraft:hamburgerItem'
    ingredient[#ingredient]['slot'] = 1
    ingredient[#ingredient + 1] = {}
    ingredient[#ingredient]['item'] = 'harvestcraft:cheeseItem'
    ingredient[#ingredient]['slot'] = 2

    return make('harvestcraft:cheeseburgerItem', ingredient)
end

function make_deluxecheeseburger()
    local ingredient = {}

    ingredient[#ingredient + 1] = {}
    ingredient[#ingredient]['item'] = 'harvestcraft:cheeseburgerItem'
    ingredient[#ingredient]['slot'] = 1
    ingredient[#ingredient + 1] = {}
    ingredient[#ingredient]['item'] = 'harvestcraft:lettuceItem'
    ingredient[#ingredient]['slot'] = 2
    ingredient[#ingredient + 1] = {}
    ingredient[#ingredient]['item'] = 'harvestcraft:tomatoItem'
    ingredient[#ingredient]['slot'] = 4

    return make('harvestcraft:delightedmealItem', ingredient)
end

function make_delightedmeal()
    local ingredient = {}

    ingredient[#ingredient + 1] = {}
    ingredient[#ingredient]['item'] = 'harvestcraft:deluxecheeseburgerItem'
    ingredient[#ingredient]['slot'] = 1
    ingredient[#ingredient + 1] = {}
    ingredient[#ingredient]['item'] = 'harvestcraft:friesItem'
    ingredient[#ingredient]['slot'] = 2
    ingredient[#ingredient + 1] = {}
    ingredient[#ingredient]['item'] = 'harvestcraft:melonsmoothieItem'
    ingredient[#ingredient]['slot'] = 4

    return make('harvestcraft:deluxecheeseburgerItem', ingredient)
end

--[[
----    TOFU AND MILK PRODUCTION
--]]

function go_base_to_press()
    move.move(3, side.up)
    move.move(2, side.back)
end

function go_press_to_base()
    move.move(2, side.front)
    move.move(3, side.down)
end

function get_finished_milk_and_tofu()
    move.move(1, side.back)
    while chest.get_item_from_chest('harvestcraft:soymilkItem', nil, nil, side.back) do end
    while chest.get_item_from_chest('harvestcraft:firmtofuItem', nil, nil, side.back) do end
    move.move(1, side.front)
end

function get_finished_silken_tofu()
    move.move(1, side.back)
    while chest.get_item_from_chest('harvestcraft:silkentofuItem', nil, nil, side.back) do end
    move.move(1, side.front)
end

function make_milk_and_tofu()
    if (not utilitie.is_elem_in_list(need_list, 'harvestcraft:soymilkItem') and not utilitie.is_elem_in_list(need_list, 'harvestcraft:firmtofuItem')) or not get_item('harvestcraft:silkentofuItem') then
        return false
    end
    go_base_to_press()
    chest.drop_item_to_chest('harvestcraft:silkentofuItem', nil, nil, side.left)
    go_press_to_base()
    get_finished_milk_and_tofu()
end

function make_silken_tofu()
    if not utilitie.is_elem_in_list(need_list, 'harvestcraft:silkentofuItem') or not get_item('harvestcraft:soybeanItem') then
        return false
    end
    go_base_to_press()
    chest.drop_item_to_chest('harvestcraft:soybeanItem', nil, nil, side.left)
    go_press_to_base()
    get_finished_silken_tofu()
end

--[[
----    BREAD AND TOAST PRODUCTION
--]]

function craft_bread()
    crafting.free_crafting_table()
    while crafting.place_item_for_craft('minecraft:wheat', 1) and crafting.place_item_for_craft('minecraft:wheat', 2) and crafting.place_item_for_craft('minecraft:wheat', 3) do
        crafting.craft()
        crafting.free_crafting_table()
    end
end

function make_flour()
    local ingredient = {}
    local tool = {}

    ingredient[#ingredient + 1] = {}
    ingredient[#ingredient]['item'] = 'minecraft:wheat'
    ingredient[#ingredient]['slot'] = 2
    tool[#tool + 1] = {}
    tool[#tool]['item'] = 'harvestcraft:mortarandpestleItem'
    tool[#tool]['slot'] = 1

    return make('harvestcraft:flourItem', ingredient, tool)
end

function make_dough()
    local ingredient = {}
    local tool = {}

    ingredient[#ingredient + 1] = {}
    ingredient[#ingredient]['item'] = 'harvestcraft:freshwaterItem'
    ingredient[#ingredient]['slot'] = 2
    ingredient[#ingredient + 1] = {}
    ingredient[#ingredient]['item'] = 'harvestcraft:flourItem'
    ingredient[#ingredient]['slot'] = 4
    ingredient[#ingredient + 1] = {}
    ingredient[#ingredient]['item'] = 'harvestcraft:saltItem'
    ingredient[#ingredient]['slot'] = 5
    tool[#tool + 1] = {}
    tool[#tool]['item'] = 'harvestcraft:mixingbowlItem'
    tool[#tool]['slot'] = 1

    return make('harvestcraft:doughItem', ingredient, tool)
end

function make_bread()
    if not utilitie.is_elem_in_list(need_list, 'minecraft:bread') or not get_item('minecraft:wheat') then
        return false
    end
    if get_item('minecraft:wheat') then
        get_item('minecraft:wheat')
    end
    craft_bread()
end

function go_toast_furnace_from_base()
    move.move(3, side.up)
    move.move(3, side.back)
end

function go_base_from_toast_furnace()
    move.move(3, side.front)
    move.move(3, side.down)
end

function get_finished_toasts()
    move.move(1, side.up)
    move.move(3, side.back)
    while chest.get_item_from_chest('harvestcraft:toastItem', nil, nil, side.down) do end
    move.move(3, side.front)
    move.move(1, side.down)
end

function get_finished_bread()
    move.move(1, side.up)
    move.move(3, side.back)
    while chest.get_item_from_chest('minecraft:bread', nil, nil, side.down) do end
    move.move(3, side.front)
    move.move(1, side.down)
end

function make_toast()
    if not utilitie.is_elem_in_list(need_list, 'harvestcraft:toastItem') or not get_item('minecraft:bread') then
        return false
    end
    go_toast_furnace_from_base()
    chest.drop_item_to_chest('minecraft:bread', nil, nil, side.left)
    go_base_from_toast_furnace()
    get_finished_toasts()
end

function bake_dough()
    if not utilitie.is_elem_in_list(need_list, 'minecraft:bread') or not get_item('harvestcraft:doughItem') then
        return false
    end
    go_toast_furnace_from_base()
    chest.drop_item_to_chest('harvestcraft:doughItem', nil, nil, side.left)
    go_base_from_toast_furnace()
    get_finished_bread()
end

--[[
----    SALT AND WATER PRODUCTION
--]]

function go_base_to_salt()
    move.move(4, side.front)
    move.move(2, side.right)
    move.move(1, side.down)
    move.move(1, side.right)
end

function go_salt_to_base()
    move.move(1, side.left)
    move.move(1, side.up)
    move.move(2, side.left)
    move.move(4, side.back)
end

function empty_bucket()
    if not crafting.craft() then
        if not crafting.free_crafting_table() then
            chest.drop_item_to_chest('minecraft:water_bucket', nil, nil, side.up)
            return false
        end
        crafting.place_item_for_craft('minecraft:water_bucket', 1)
        return crafting.craft()
    end
    return true
end

function draw_water(amount)
    if not chest.get_item_from_chest('minecraft:bucket', nil, nil, side.up) and not chest.get_item_from_chest('minecraft:water_bucket', nil, nil, side.up) then
        print('Bucket not found, can\'t craft water.')
        return false
    end
    if inventory.select_item('minecraft:water_bucket') then
        empty_bucket()
    end
    if amount / 64 > robot.inventorySize() - 10 then
        amount = (robot.inventorySize() - 10) * 64
    end
    crafting.free_crafting_table()
    crafting.place_item_for_craft('minecraft:bucket', 1)
    while amount > 0 do
        environement.fill_bucket(robot.front, true, true)
        if not empty_bucket() then
            return false
        end
        crafting.move_item_out_of_crafting_table('harvestcraft:freshwaterItem')
        amount = amount - 1
    end
    if inventory.select_item('minecraft:water_bucket') then
        crafting.free_crafting_table()
        crafting.place_item_for_craft('minecraft:water_bucket', 1)
        crafting.craft()
    end
    chest.drop_item_to_chest('minecraft:bucket', nil, nil, side.up)
    return true
end

function craft_salt()
    if not draw_water(SALT_PRODUCTION_STACK_AMOUNT * 64) or not chest.get_item_from_chest('harvestcraft:potItem', nil, nil, side.up) then
        return false
    end
    crafting.free_crafting_table()
    crafting.place_item_for_craft('harvestcraft:potItem', 1)
    while crafting.place_item_for_craft('harvestcraft:freshwaterItem', 2, nil, 64) do
        component.crafting.craft()
        crafting.move_item_out_of_crafting_table('harvestcraft:saltItem')
    end
    chest.drop_item_to_chest('harvestcraft:potItem', nil, nil, side.up)
    return true
end

function make_salt()
    if not utilitie.is_elem_in_list(need_list, 'harvestcraft:saltItem') then
        return false
    end
    go_base_to_salt()
    if not craft_salt() then
        go_salt_to_base()
        return false
    end
    go_salt_to_base()
    return true
end

function make_water()
    local retval

    if not utilitie.is_elem_in_list(need_list, 'harvestcraft:freshwaterItem') then
        return false
    end
    go_base_to_salt()
    retval = draw_water(WATER_PRODUCTION_STACK_AMOUNT * 64)
    go_salt_to_base()
    return retval
end

--[[
----    FIELDS HARVEST
--]]

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

function go_base_to_fields(id)
    move.move(1, side.up)
    move.move(6, side.front)
    if id == 2 then
        move.move(21, side.left)
    end
end

function go_fields_to_base(id)
    if id == 2 then
        move.move(21, side.right)
    end
    move.move(6, side.back)
    move.move(1, side.down)
end

function get_next_field()
    local tmp = {}

    tmp.x = last_field.x
    tmp.y = last_field.y + 1
    while tmp.y ~= last_field.y or tmp.x ~= last_field.x do
        if tmp.y > #FIELD_MAP[tmp.x] then
            tmp.y = 1
            tmp.x = tmp.x + 1
            if tmp.x > #FIELD_MAP then
                tmp.x = 1
            end
        end
        if utilitie.is_elem_in_list(need_list, FIELD_MAP[tmp.x][tmp.y]) then
            last_field.x = tmp.x
            last_field.y = tmp.y
            return last_field.x, last_field.y
        end
        tmp.y = tmp.y + 1
    end
    if utilitie.is_elem_in_list(need_list, FIELD_MAP[tmp.x][tmp.y]) then
        last_field.x = tmp.x
        last_field.y = tmp.y
        return last_field.x, last_field.y
    end
    return false
end

function harvest_next_field()
    local next_field
    local id

    id, next_field = get_next_field()
    if not next_field or not id then
        return false
    end
    go_base_to_fields(id)
    move.move(4 * (next_field - 1), side.up)
    move.move(2, side.front)
    harvest_field(FIELD_X_SIZE, FIELD_Y_SIZE, FIELD_DIRECTION, FIELD_MAP[id][next_field])
    move.move(2, side.back)
    move.move(4 * (next_field - 1), side.down)
    go_fields_to_base(id)
    return true
end

--[[
----    INVENTORY CONTROLL
--]]

function check_inventory()
    if inventory.free_slots_amount() < 13 then
        inventory_controll(true)
        garbage_all()
    end
end

function move_base_to_chest(line_i, chest_i)
    move.move(1, side.up)
    move.move(6, side.front)
    move.move(2, side.left)
    move.move(1, side.front)
    move.move(2 * (line_i - 1), side.left)
    move.move(chest_i - 1, side.front)
end

function move_chest_to_base(line_i, chest_i)
    move.move(chest_i - 1, side.back)
    move.move(2 * (line_i - 1), side.right)
    move.move(1, side.back)
    move.move(2, side.right)
    move.move(6, side.back)
    move.move(1, side.down)
end

function get_chest_side(column, item, last_chest)
    local side_i

    if not last_chest and column[side.up] and column[side.up] == item then
        return side.up
    elseif (not last_chest or last_chest.side ~= side.down) and column[side.down] and column[side.down] == item then
        return side.down
    end
    return false
end

function get_chest_in_line(line, item, last_chest)
    local chest_i
    local side_i

    chest_i = 1
    if last_chest then
        chest_i = last_chest.chest
    end
    while chest_i <= #line do
        if last_chest and chest_i > last_chest.chest then
            last_chest = nil
        end
        side_i = get_chest_side(line[chest_i], item, last_chest)
        if side_i then
            return chest_i, side_i
        end
        chest_i = chest_i + 1
    end
    return false
end

function get_chest(item, last_chest)
    local line_i
    local chest_i
    local side_i
    local i

    line_i = 1
    if last_chest then
        line_i = last_chest.line
    end
    while line_i <= #CHEST_MAP do
        if last_chest and line_i > last_chest.line then
            last_chest = nil
        end
        chest_i, side_i = get_chest_in_line(CHEST_MAP[line_i], item, last_chest)
        if chest_i and side_i then
            return line_i, chest_i, side_i
        end
        line_i = line_i + 1
    end
    return false
end

function get_item(item)
    local line_i
    local chest_i
    local side_i
    local ret_val

    line_i, chest_i, side_i = get_chest(item)
    if not line_i then
        print('Warning: Chest for ' .. item .. ' not found.')
        return false
    end
    move_base_to_chest(line_i, chest_i, side_i)
    chest.repack_chest(side_i)
    ret_val = chest.get_item_from_chest(item, nil, nil, side_i)
    move_chest_to_base(line_i, chest_i, side_i)
    return ret_val
end

function is_multiple_chests(item)
    local amount
    local tmpx
    local tmpy
    local tmpz
    local last_chest = {}

    amount = 0
    tmpx, tmpy, tmpz = get_chest(item)
    while tmpx and tmpy and tmpz do
        last_chest.line = tmpx
        last_chest.chest = tmpy
        last_chest.side = tmpz
        tmpx, tmpy, tmpz = get_chest(item, last_chest)
        amount = amount + 1
    end
    if amount > 0 then
        return amount
    end
    return false
end

function inventory_controll_chest(item, chest_side, drop, repack, update_need, inv_map)
    local tmp
    local inv_map

    if drop then
        tmp = is_multiple_chests(item)
        if tmp > 1 then
            chest.drop_item_to_chest(item, nil, math.ceil(inventory.item_amount(item, nil, inv_map) / tmp), chest_side)
        elseif tmp then
            chest.drop_item_to_chest(item, nil, nil, chest_side)
        end
    end
    if repack then
        chest.repack_chest(chest_side)
    end
    if update_need then
        if not utilitie.is_elem_in_list(need_list, item) and not chest.is_full(chest_side) then
            need_list[#need_list + 1] = item
        elseif utilitie.is_elem_in_list(need_list, item) and chest.is_full(chest_side) then
           table.remove(need_list, utilitie.is_elem_in_list(need_list, item))
        end
    end
end

function inventory_controll_case(case, drop, repack, update_need, inv_map)
    if case[side.up] then
        inventory_controll_chest(case[side.up], side.up, drop, repack, update_need, inv_map)
    end
    if case[side.down] then
        inventory_controll_chest(case[side.down], side.down, drop, repack, update_need, inv_map)
    end
end

function inventory_controll_line(line, drop, repack, update_need, inv_map)
    local i

    i = 1
    while i <= #line do
        inventory_controll_case(line[i], drop, repack, update_need, inv_map)
        i = i + 1
        if i <= #line then
            move.move(1)
        end
    end
    move.move(#line - 1, side.back)
end

function inventory_controll(drop, repack, update_need)
    local i
    local inv_map

    i = 1
    move.move(1, side.up)
    move.move(6, side.front)
    move.move(2, side.left)
    move.move(1, side.front)
    inv_map = inventory.get_inventory_map()
    while i <= #CHEST_MAP do
        inventory_controll_line(CHEST_MAP[i], drop, repack, update_need, inv_map)
        i = i + 1
        if i <= #CHEST_MAP then
            move.move(2, side.left)
        end
    end
    move.move(2 * (i - 2), side.right)
    move.move(1, side.back)
    move.move(2, side.right)
    move.move(6, side.back)
    move.move(1, side.down)
end

function garbage_all()
    local slot

    move.move(1, side.up)
    move.move(1, side.right)
    slot = robot.inventorySize()
    while slot >= 1 do
        robot.select(slot)
        robot.dropDown()
        slot = slot - 1
    end
    move.move(1, side.left)
    move.move(1, side.down)
end

--[[
----    CRAFTING
--]]

function get_ingredients(ingredient)
    local i

    i = 1
    while i <= #ingredient do
        if not get_item(ingredient[i]['item']) then
            return false
        end
        i = i + 1
    end
    return true
end

function move_tool(tool, drop_mode)
    local i

    i = 1
    while i <= #tool do
        if drop_mode and not chest.drop_item_to_chest(tool[i]['item'], nil, nil, side.down) then
            return false
        elseif not drop_mode and not chest.get_item_from_chest(tool[i]['item'], nil, nil, side.down) then
            print('Warning: tool ' .. tostring(tool[i]['item']) .. 'not found')
            return false
        end
        i = i + 1
    end
    return true
end

function get_pattern(ingredient, tool)
    local pattern = {}
    local i

    i = 1
    while i <= 9 do
        pattern[i] = false
        i = i + 1
    end
    i = 1
    while i <= #ingredient do
        pattern[ingredient[i]['slot']] = {}
        pattern[ingredient[i]['slot']]['item'] = ingredient[i]['item']
        pattern[ingredient[i]['slot']]['amount'] = 64
        i = i + 1
    end
    i = 1
    while tool and i <= #tool do
        pattern[tool[i]['slot']] = {}
        pattern[tool[i]['slot']]['item'] = tool[i]['item']
        pattern[tool[i]['slot']]['amount'] = 1
        i = i + 1
    end
    return pattern
end

function make_get_max(ingredient)
    local i
    local data
    local min
    local craft_bench = {}

    craft_bench[1] = 1
    craft_bench[2] = 2
    craft_bench[3] = 3
    craft_bench[4] = 5
    craft_bench[5] = 6
    craft_bench[6] = 7
    craft_bench[7] = 9
    craft_bench[8] = 10
    craft_bench[9] = 11

    min = 64
    i = 1
    while i <= #ingredient do
        data = component.inventory_controller.getStackInInternalSlot(craft_bench[ingredient[i]['slot']])

        if not data then
            print(utilitie.var_dump(ingredient[i]))
            os.exit()
        end
        if min < data.size then
            min = data.size
        end
        i = i + 1
    end
    return min
end

function make(desired, ingredient, tool)
    local i

    i = 1
    if not utilitie.is_elem_in_list(need_list, desired) or not get_ingredients(ingredient) or (tool and not move_tool(tool)) then
        return false
    end
    if crafting.prepare_craft(get_pattern(ingredient, tool)) then
        crafting.craft(make_get_max(ingredient))
    end
    if tool and not move_tool(tool, true) then
        print('Error: can\'t drop tool')
        os.exit()
    end
    return true
end

--[[
----    OTHER
--]]

function check_actions(frequency_iter)
    if frequency_iter % FREQUENCY_CHEST_DROP == 0 then
        energy.wait_charging()
        inventory_controll(true, false, true)
        print('Needed ressources: ' .. utilitie.var_dump(need_list))
        garbage_all()
    end
    if frequency_iter % FREQUENCY_SALT == 0 then
        energy.wait_charging()
        make_salt()
        check_inventory()
    end
    if frequency_iter % FREQUENCY_WATER == 0 then
        energy.wait_charging()
        make_water()
        check_inventory()
    end
    if frequency_iter % FREQUENCY_FLOUR == 0 then
        energy.wait_charging()
        make_flour()
        check_inventory()
    end
    if frequency_iter % FREQUENCY_DOUGHT == 0 then
        energy.wait_charging()
        make_dough()
        check_inventory()
    end
    if frequency_iter % FREQUENCY_DELUXECHEESEBURGER == 0 then
        energy.wait_charging()
        make_delightedmeal()
        check_inventory()
    end
    if frequency_iter % FREQUENCY_DELUXECHEESEBURGER == 0 then
        energy.wait_charging()
        make_deluxecheeseburger()
        check_inventory()
    end
    if frequency_iter % FREQUENCY_CHEESEBURGER == 0 then
        energy.wait_charging()
        make_cheeseburger()
        check_inventory()
    end
    if frequency_iter % FREQUENCY_HAMBURGER == 0 then
        energy.wait_charging()
        make_hamburger()
        check_inventory()
    end
    if frequency_iter % FREQUENCY_CHEESE == 0 then
        energy.wait_charging()
        make_cheese()
        check_inventory()
    end
    if frequency_iter % FREQUENCY_SILKEN_TOFU == 0 then
        energy.wait_charging()
        make_silken_tofu()
        check_inventory()
    end
    if frequency_iter % FREQUENCY_MILK_TOFU == 0 then
        energy.wait_charging()
        make_milk_and_tofu()
        check_inventory()
    end
    if frequency_iter % FREQUENCY_BREAD == 0 then
        energy.wait_charging()
        bake_dough()
        check_inventory()
    end
    if frequency_iter % FREQUENCY_TOAST == 0 then
        energy.wait_charging()
        make_toast()
        check_inventory()
    end
    if frequency_iter % FREQUENCY_APPLE == 0 then
        energy.wait_charging()
        harvest_apples()
        check_inventory()
    end
end

function core()
    local frequency_iter

    frequency_iter = 0
    while true do
        check_actions(frequency_iter)
        energy.wait_charging()
        harvest_next_field()
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

init()
core()
