local COMMON_DIR_NAME = '/lib'
local CUSTOM_BIN = '/bin'
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

paste[#paste + 1] = {}
paste[#paste]['id'] = 'AbPE6Yve'
paste[#paste]['name'] = 'net.lua'

function download_all_pastes(list, location)
    local i

    i = 1
    while i <= #list do
        print('File: ' .. list[i]['name'])
        os.execute('pastebin -f get ' .. list[i]['id'] .. ' ' .. location .. '/' .. list[i]['name'])
        i = i + 1
    end
end

download_all_pastes(paste, COMMON_DIR_NAME)

paste = {}

paste[#paste + 1] = {}
paste[#paste]['id'] = 'sAvMP1FH'
paste[#paste]['name'] = 'pastebin.lua'

paste[#paste + 1] = {}
paste[#paste]['id'] = '6HJwNNKZ'
paste[#paste]['name'] = 'update.lua'

download_all_pastes(paste, CUSTOM_BIN)