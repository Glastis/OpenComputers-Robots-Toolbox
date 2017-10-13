local net = require('net')
local utilities = require('utilities')

local component = require('component')
local robot = require('robot')

local arg = {...}

local PASTE_URL = 'https://pastebin.com/raw/mXkLDR54'
local FILEPATH = 'xp_consumer'

function print_experience()
    print(utilities.round(component.experience.level(), 2))
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

function parse_inv()
    local slot

    slot = robot.inventorySize()
    while slot > 0 do
        robot.select(slot)
        if component.experience.consume() then
            print_experience()
        end
        robot.dropDown()
        slot = slot - 1
    end
end

function get_stuff()
    local moved

    moved = false
    while robot.suckUp() do
        moved = true
    end
    return moved
end

function core()
    print_experience()
    parse_inv()
    while get_stuff() do
        parse_inv()
    end
end

if arg[1] and (arg[1] == '-u' or arg[1] == '--update') then
    return update()
end

core()
return true