
local COMMON_DIR_NAME = 'common'
local paste = {}

-- All commons pastes
paste[#paste + 1] = {}
paste[#paste]['id'] = 'HNGxVAg5'
paste[#paste]['name'] = 'utilities.lua'

paste[#paste + 1] = {}
paste[#paste]['id'] = 'PyZFfHkx'
paste[#paste]['name'] = 'movement.lua'

paste[#paste + 1] = {}
paste[#paste]['id'] = 'dv4tCD8j'
paste[#paste]['name'] = 'energy.lua'

paste[#paste + 1] = {}
paste[#paste]['id'] = 'u4HJM0wi'
paste[#paste]['name'] = 'inventory.lua'

paste[#paste + 1] = {}
paste[#paste]['id'] = 'aEsQKEsA'
paste[#paste]['name'] = 'environement.lua'

paste[#paste + 1] = {}
paste[#paste]['id'] = 'bvgVf19y'
paste[#paste]['name'] = 'chest.lua'

paste[#paste + 1] = {}
paste[#paste]['id'] = '3KBrih6H'
paste[#paste]['name'] = 'crafting.lua'

function download_all_pastes()
    local i

    i = 1
    while i <= #paste do
        print('File: ' .. paste[i]['name'])
        os.execute('pastebin -f get ' .. paste[i]['id'] .. ' ' .. COMMON_DIR_NAME .. '/' .. paste[i]['name'])
        i = i + 1
    end
end

download_all_pastes()