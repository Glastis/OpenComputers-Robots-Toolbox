local component = require("component")
local side = require("sides")

local environement = {}

local function get_bloc(direction)
    if not direction then
        direction = side.front
    end
    return component.geolyzer.analyze(direction)
end
environement.get_bloc = get_bloc

local function get_bloc_meta(direction)
    if not direction then
        direction = side.front
    end
    return component.geolyzer.analyze(direction).metadata
end
environement.get_bloc_meta = get_bloc_meta

return environement