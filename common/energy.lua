local computer = require('computer')

local ENERGY_CHARGING_CHECK_SLEEP = 10
local ERROR_TOLERANCE = 100
local energy = {}

local function wait_charging()
    while computer.energy() < computer.maxEnergy() - ERROR_TOLERANCE do
        os.sleep(ENERGY_CHARGING_CHECK_SLEEP)
    end
end
energy.wait_charging = wait_charging

return energy