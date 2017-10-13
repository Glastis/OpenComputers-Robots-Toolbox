local move = require('movement')
local utilitie = require('utilities')
local energy = require('energy')
local inventory = require('inventory')
local net = require('net')

local component = require('component')
local robot = require('robot')
local side = require('sides')

local LENTH_MAX = 67
local REQ_ENERGY_PER_LOOP = 8000
local IDLE_SLEEP_TIME = 60
local PASTE_URL = "https://pastebin.com/raw/3yHDsrqX"
local FILEPATH = "sort"
local UNKNOWN_LIST = "unsortable_items"
local arg = {...}

function get_item_list_right()
    local right = {}
    local i = 1

    while i <= LENTH_MAX do
        right[i] = {}
        i = i + 1
    end
    right[1][#right[1] + 1] = "minecraft:cobblestone"
    right[2][#right[2] + 1] = "minecraft:dirt"
    right[3][#right[3] + 1] = "minecraft:gravel"
    right[4][#right[4] + 1] = "minecraft:glass"
    right[5][#right[5] + 1] = "minecraft:sand"
    right[6][#right[6] + 1] = "chisel:limestone"
    right[7][#right[7] + 1] = "chisel:marble"
    right[7][#right[7] + 1] = "ProjRed|Exploration:projectred.exploration.stone,0"
    right[8][#right[8] + 1] = "minecraft:grass"
    right[9][#right[9] + 1] = "minecraft:stone,0"
    right[10][#right[10] + 1] = "minecraft:log"
    right[10][#right[10] + 1] = "minecraft:log2"
    right[11][#right[11] + 1] = "minecraft:iron_ingot"
    right[12][#right[12] + 1] = "minecraft:gold_ingot"
    right[12][#right[12] + 1] = "minecraft:gold_block"
    right[13][#right[13] + 1] = "minecraft:diamond"
    right[14][#right[14] + 1] = "minecraft:emerald"
    right[15][#right[15] + 1] = "TConstruct:materials,9"
    right[15][#right[15] + 1] = "ThermalFoundation:material,64"
    right[16][#right[16] + 1] = "TConstruct:materials,10"
    right[16][#right[16] + 1] = "ThermalFoundation:material,65"
    right[17][#right[17] + 1] = "ThermalFoundation:material,66"
    right[18][#right[18] + 1] = "TConstruct:materials,5"
    right[18][#right[18] + 1] = "TConstruct:materials,15"
    right[18][#right[18] + 1] = "TConstruct:materials,18"
    right[18][#right[18] + 1] = "TConstruct:materials,34"
    right[18][#right[18] + 1] = "TConstruct:materials,3"
    right[18][#right[18] + 1] = "ProjRed|Core:projectred.core.part,10"
    right[19][#right[19] + 1] = "ThermalFoundation:material,71"
    right[19][#right[19] + 1] = "ThermalFoundation:material,69"
    right[19][#right[19] + 1] = "ThermalFoundation:material,76"
    right[19][#right[19] + 1] = "ThermalFoundation:material,74"
    right[19][#right[19] + 1] = "ThermalFoundation:material,106"
    right[20][#right[20] + 1] = "ThermalFoundation:material,67"
    right[21][#right[21] + 1] = "TConstruct:materials,13"
    right[21][#right[21] + 1] = "ThermalFoundation:material,73"
    right[22][#right[22] + 1] = "ThermalFoundation:material,68"
    right[23][#right[23] + 1] = "TConstruct:materials,14"
    right[24][#right[24] + 1] = "ThermalFoundation:material,72"
    right[25][#right[25] + 1] = "TConstruct:materials,11"
    right[26][#right[26] + 1] = "minecraft:ender_pearl"
    right[27][#right[27] + 1] = "minecraft:leather"
    right[28][#right[28] + 1] = "minecraft:wool"
    right[29][#right[29] + 1] = "minecraft:bone"
    right[30][#right[30] + 1] = "minecraft:rotten_flesh"
    right[31][#right[31] + 1] = "minecraft:gunpowder"
    right[32][#right[32] + 1] = "minecraft:glowstone"
    right[32][#right[32] + 1] = "minecraft:glowstone_dust"
    right[32][#right[32] + 1] = "chisel:glowstone"
    right[33][#right[33] + 1] = "minecraft:ghast_tear"
    right[33][#right[33] + 1] = "minecraft:skull"
    right[33][#right[33] + 1] = "OpenBlocks:trophy"
    right[33][#right[33] + 1] = "minecraft:saddle"
    right[33][#right[33] + 1] = "minecraft:tnt"
    right[33][#right[33] + 1] = "minecraft:name_tag"
    right[33][#right[33] + 1] = "TConstruct:materials,8"
    right[33][#right[33] + 1] = "ThermalFoundation:material,1028"
    right[33][#right[33] + 1] = "GrimoireOfGaia:item.GrimoireOfGaia.MiscSoulFire"
    right[33][#right[33] + 1] = "GrimoireOfGaia:item.GrimoireOfGaia.MiscFurnaceFuel"
    right[33][#right[33] + 1] = "GrimoireOfGaia:item.GrimoireOfGaia.FoodBerryFire"
    right[33][#right[33] + 1] = "GrimoireOfGaia:item.GrimoireOfGaia.MiscBook"
    right[34][#right[34] + 1] = "minecraft:reeds"
    right[35][#right[35] + 1] = "minecraft:apple"
    right[35][#right[35] + 1] = "minecraft:bread"
    right[35][#right[35] + 1] = "minecraft:wheat"
    right[35][#right[35] + 1] = "minecraft:pumpkin"
    right[35][#right[35] + 1] = "minecraft:golden_carrot"
    right[35][#right[35] + 1] = "GrimoireOfGaia:item.GrimoireOfGaia.FoodBerryCure"
    right[36][#right[36] + 1] = "minecraft:wheat_seeds"
    right[36][#right[36] + 1] = "minecraft:pumpkin_seeds"
    right[36][#right[36] + 1] = "minecraft:melon_seeds"
    right[36][#right[36] + 1] = "harvestcraft:bambooshootseedItem"
    right[36][#right[36] + 1] = "harvestcraft:spinachseedItem"
    right[36][#right[36] + 1] = "harvestcraft:barleyseedItem"
    right[36][#right[36] + 1] = "harvestcraft:beanseedItem"
    right[36][#right[36] + 1] = "harvestcraft:beetseedItem"
    right[36][#right[36] + 1] = "harvestcraft:broccoliseedItem"
    right[36][#right[36] + 1] = "harvestcraft:brusselsproutseedItem"
    right[36][#right[36] + 1] = "harvestcraft:cabbageseedItem"
    right[36][#right[36] + 1] = "harvestcraft:cactusfruitseedItem"
    right[36][#right[36] + 1] = "harvestcraft:cantaloupeseedItem"
    right[36][#right[36] + 1] = "harvestcraft:chilipepperseedItem"
    right[36][#right[36] + 1] = "harvestcraft:coffeeseedItem"
    right[36][#right[36] + 1] = "harvestcraft:cranberryseedItem"
    right[36][#right[36] + 1] = "harvestcraft:eggplantseedItem"
    right[36][#right[36] + 1] = "harvestcraft:garlicseedItem"
    right[36][#right[36] + 1] = "harvestcraft:grapeseedItem"
    right[36][#right[36] + 1] = "harvestcraft:leekseedItem"
    right[36][#right[36] + 1] = "harvestcraft:oatsseedItem"
    right[36][#right[36] + 1] = "harvestcraft:onionseedItem"
    right[36][#right[36] + 1] = "harvestcraft:parsnipseedItem"
    right[36][#right[36] + 1] = "harvestcraft:peanutseedItem"
    right[36][#right[36] + 1] = "harvestcraft:peasseedItem"
    right[36][#right[36] + 1] = "harvestcraft:pineappleseedItem"
    right[36][#right[36] + 1] = "harvestcraft:radishseedItem"
    right[36][#right[36] + 1] = "harvestcraft:raspberryseedItem"
    right[36][#right[36] + 1] = "harvestcraft:rutabagaseedItem"
    right[36][#right[36] + 1] = "harvestcraft:ryeseedItem"
    right[36][#right[36] + 1] = "harvestcraft:soybeanseedItem"
    right[36][#right[36] + 1] = "harvestcraft:strawberryseedItem"
    right[36][#right[36] + 1] = "harvestcraft:sweetpotatoseedItem"
    right[36][#right[36] + 1] = "harvestcraft:teaseedItem"
    right[36][#right[36] + 1] = "harvestcraft:turnipseedItem"
    right[36][#right[36] + 1] = "harvestcraft:waterchestnutseedItem"
    right[36][#right[36] + 1] = "harvestcraft:whitemushroomseedItem"
    right[36][#right[36] + 1] = "harvestcraft:wintersquashseedItem"
    right[36][#right[36] + 1] = "harvestcraft:candleberryseedItem"
    right[36][#right[36] + 1] = "harvestcraft:cottonseedItem"
    right[36][#right[36] + 1] = "harvestcraft:soybeanseedItem"
    right[36][#right[36] + 1] = "harvestcraft:spinachseedItem"
    right[36][#right[36] + 1] = "harvestcraft:soybeanseedItem"
    right[36][#right[36] + 1] = "harvestcraft:cornseedItem"
    right[36][#right[36] + 1] = "harvestcraft:artichokeseedItem"
    right[36][#right[36] + 1] = "harvestcraft:asparagusseedItem"
    right[36][#right[36] + 1] = "harvestcraft:cauliflowerseedItem"
    right[36][#right[36] + 1] = "harvestcraft:cucumberseedItem"
    right[36][#right[36] + 1] = "harvestcraft:curryleafseedItem"
    right[36][#right[36] + 1] = "harvestcraft:kiwiseedItem"
    right[36][#right[36] + 1] = "harvestcraft:okraseedItem"
    right[36][#right[36] + 1] = "harvestcraft:rhubarbseedItem"
    right[36][#right[36] + 1] = "harvestcraft:sesameseedsseedItem"
    right[36][#right[36] + 1] = "harvestcraft:tomatoseedItem"
    right[36][#right[36] + 1] = "harvestcraft:zucchiniseedItem"
    right[36][#right[36] + 1] = "harvestcraft:blueberryseedItem"
    right[36][#right[36] + 1] = "harvestcraft:riceseedItem"
    right[36][#right[36] + 1] = "harvestcraft:scallionseedItem"
    right[36][#right[36] + 1] = "ExtraUtilities:plant/ender_lilly"
    right[37][#right[37] + 1] = "minecraft:enchanted_book"
    right[38][#right[38] + 1] = "harvestcraft:lettuceItem"
    right[38][#right[38] + 1] = "harvestcraft:soybeanItem"
    right[38][#right[38] + 1] = "harvestcraft:spinachItem"
    right[38][#right[38] + 1] = "harvestcraft:freshmilkItem"
    right[38][#right[38] + 1] = "harvestcraft:coffeebeanItem"
    right[38][#right[38] + 1] = "harvestcraft:tomatoItem"
    right[38][#right[38] + 1] = "harvestcraft:parsnipItem"
    right[38][#right[38] + 1] = "harvestcraft:turnipItem"
    right[38][#right[38] + 1] = "harvestcraft:whitemushroomItem"
    right[38][#right[38] + 1] = "harvestcraft:delightedmealItem"
    right[38][#right[38] + 1] = "harvestcraft:grilledmushroomItem"
    right[39][#right[39] + 1] = "harvestcraft:cottonItem"
    right[39][#right[39] + 1] = "harvestcraft:coffeeItem"
    right[39][#right[39] + 1] = "harvestcraft:cashewItem"
    right[39][#right[39] + 1] = "harvestcraft:sink"
    right[39][#right[39] + 1] = "harvestcraft:saltItem"
    right[39][#right[39] + 1] = "harvestcraft:salt"
    right[39][#right[39] + 1] = "harvestcraft:grainbaitItem"
    right[39][#right[39] + 1] = "harvestcraft:firmtofuItem"
    right[39][#right[39] + 1] = "harvestcraft:soymilkItem"
    right[39][#right[39] + 1] = "harvestcraft:stockItem"
    right[39][#right[39] + 1] = "harvestcraft:silkentofuItem"
    right[39][#right[39] + 1] = "harvestcraft:baconcheeseburgerItem"
    right[39][#right[39] + 1] = "harvestcraft:plainyogurtItem"
    right[40][#right[40] + 1] = "harvestcraft:appleyogurtItem"
    right[40][#right[40] + 1] = "harvestcraft:carrotsoupItem"
    right[40][#right[40] + 1] = "minecraft:baked_potato"
    right[40][#right[40] + 1] = "minecraft:mushroom_stew"
    right[41][#right[41] + 1] = "minecraft:potato"
    right[41][#right[41] + 1] = "minecraft:carrot"
    right[41][#right[41] + 1] = "minecraft:melon"
    right[42][#right[42] + 1] = "minecraft:feather"
    right[43][#right[43] + 1] = "minecraft:string"
    right[44][#right[44] + 1] = "minecraft:cooked_beef"
    right[44][#right[44] + 1] = "minecraft:cooked_chicken"
    right[44][#right[44] + 1] = "minecraft:cooked_fished"
    right[44][#right[44] + 1] = "minecraft:cooked_porkchop"
    right[44][#right[44] + 1] = "minecraft:egg"
    right[44][#right[44] + 1] = "minecraft:beef"
    right[44][#right[44] + 1] = "minecraft:chicken"
    right[44][#right[44] + 1] = "harvestcraft:muttonrawItem"
    right[44][#right[44] + 1] = "harvestcraft:calamarirawItem"
    right[44][#right[44] + 1] = "minecraft:porkchop"
    right[44][#right[44] + 1] = "GrimoireOfGaia:item.GrimoireOfGaia.FoodMeat"
    right[44][#right[44] + 1] = "GrimoireOfGaia:item.GrimoireOfGaia.FoodMeatMorsel"
    right[44][#right[44] + 1] = "GrimoireOfGaia:item.GrimoireOfGaia.FoodWitherMeat"
    right[44][#right[44] + 1] = "TConstruct:jerky,7"
    right[44][#right[44] + 1] = "TConstruct:jerky,6"
    right[45][#right[45] + 1] = "minecraft:record_13"
    right[45][#right[45] + 1] = "minecraft:record_cat"
    right[45][#right[45] + 1] = "minecraft:record_wait"
    right[46][#right[46] + 1] = "ExtraUtilities:drum"
    right[47][#right[47] + 1] = "minechem:minechemBlueprint"
    right[47][#right[47] + 1] = "minechem:tile.blueprintProjector"
    right[47][#right[47] + 1] = "minechem:tile.chemicalDecomposer"
    right[47][#right[47] + 1] = "minechem:tile.fusionWall"
    right[47][#right[47] + 1] = "minechem:tile.chemicalSynthesizer"
    right[48][#right[48] + 1] = "minechem:minechemElement"
    right[48][#right[48] + 1] = "minechem:minechemMolecule"
    right[49][#right[49] + 1] = "tc:minecartCaboose3"
    right[49][#right[49] + 1] = "tc:minecartChest"
    right[50][#right[50] + 1] = "ThermalFoundation:material,2"
    right[51][#right[51] + 1] = "tc:rawPlastic"
    right[52][#right[52] + 1] = "TConstruct:materials,16"
    right[53][#right[53] + 1] = "tc:firebox"
    right[53][#right[53] + 1] = "tc:graphite"
    right[53][#right[53] + 1] = "tc:bridgePillar"
    right[53][#right[53] + 1] = "tc:copperWireFine"
    right[53][#right[53] + 1] = "tc:tcRailMediumStraight"
    right[53][#right[53] + 1] = "tc:tcRailMediumSwitch"
    right[53][#right[53] + 1] = "tc:tcRailMediumTurn"
    right[53][#right[53] + 1] = "tc:tcRailLongStraight"
    right[54][#right[54] + 1] = "millenaire:tile.ml_earth_deco"
    right[54][#right[54] + 1] = "millenaire:tile.ml_wood_deco"
    right[54][#right[54] + 1] = "millenaire:tile.ml_panes"
    right[54][#right[54] + 1] = "millenaire:tile.ml_path"
    right[54][#right[54] + 1] = "millenaire:tile.ml_path_slab"
    right[55][#right[55] + 1] = "millenaire:item.ml_wine_basic"
    right[55][#right[55] + 1] = "millenaire:item.ml_ciderapple"
    right[55][#right[55] + 1] = "millenaire:item.ml_cacauhaa"
    right[55][#right[55] + 1] = "millenaire:item.ml_turmeric"
    right[55][#right[55] + 1] = "millenaire:item.ml_masa"
    right[55][#right[55] + 1] = "millenaire:item.ml_wah"
    right[55][#right[55] + 1] = "millenaire:item.ml_maize"
    right[55][#right[55] + 1] = "millenaire:item.ml_ciderapple"
    right[55][#right[55] + 1] = "millenaire:item.ml_ciderapple"
    right[55][#right[55] + 1] = "millenaire:item.ml_ciderapple"
    right[56][#right[56] + 1] = "millenaire:item.ml_denier"
    right[56][#right[56] + 1] = "millenaire:item.ml_parchmentJapaneseComplete"
    right[56][#right[56] + 1] = "millenaire:item.ml_purse"
    right[56][#right[56] + 1] = "millenaire:item.ml_villageWand"
    right[56][#right[56] + 1] = "millenaire:item.ml_negationWand"
    right[57][#right[57] + 1] = "minecraft:lava_bucket"
    right[57][#right[57] + 1] = "minecraft:milk_bucket"
    right[57][#right[57] + 1] = "minecraft:water_bucket"
    right[57][#right[57] + 1] = "minecraft:bucket"
    right[67][#right[67] + 1] = "OpenBlocks:xpdrain"
    return right
end

function get_item_list_left()
    local right = {}
    local i = 1

    while i <= LENTH_MAX do
        right[i] = {}
        i = i + 1
    end
    right[1][#right[1] + 1] = "minecraft:wooden_slab"
    right[1][#right[1] + 1] = "minecraft:stone_slab"
    right[1][#right[1] + 1] = "minecraft:birch_stairs"
    right[1][#right[1] + 1] = "minecraft:spruce_stairs"
    right[1][#right[1] + 1] = "minecraft:stone_stairs"
    right[1][#right[1] + 1] = "minecraft:brick_stairs"
    right[1][#right[1] + 1] = "minecraft:sandstone_stairs"
    right[1][#right[1] + 1] = "minecraft:carpet"
    right[1][#right[1] + 1] = "minecraft:oak_stairs"
    right[1][#right[1] + 1] = "minecraft:nether_brick_stairs"
    right[1][#right[1] + 1] = "minecraft:quartz_stairs"
    right[2][#right[2] + 1] = "minecraft:birch_fence"
    right[2][#right[2] + 1] = "minecraft:fence_gate"
    right[2][#right[2] + 1] = "minecraft:oak_fence"
    right[2][#right[2] + 1] = "minecraft:nether_brick_fence"
    right[2][#right[2] + 1] = "minecraft:spruce_fence"
    right[2][#right[2] + 1] = "minecraft:jungle_fence"
    right[2][#right[2] + 1] = "minecraft:dark_oak_fence"
    right[2][#right[2] + 1] = "minecraft:acacia_fence"
    right[2][#right[2] + 1] = "minecraft:birch_fence_gate"
    right[2][#right[2] + 1] = "minecraft:oak_fence_gate"
    right[2][#right[2] + 1] = "minecraft:spruce_fence_gate"
    right[2][#right[2] + 1] = "minecraft:jungle_fence_gate"
    right[2][#right[2] + 1] = "minecraft:dark_oak_fence_gate"
    right[2][#right[2] + 1] = "minecraft:acacia_fence_gate"
    right[2][#right[2] + 1] = "minecraft:cobblestone_wall"
    right[2][#right[2] + 1] = "minecraft:iron_bars"
    right[2][#right[2] + 1] = "minecraft:stained_glass_pane"
    right[2][#right[2] + 1] = "minecraft:glass_pane"
    right[2][#right[2] + 1] = "minecraft:fence"
    right[3][#right[3] + 1] = "minecraft:flint"
    right[4][#right[4] + 1] = "minecraft:sandstone"
    right[5][#right[5] + 1] = "ImmibisPeripherals:lanwire"
    right[5][#right[5] + 1] = "OpenBlocks:technicolorGlasses"
    right[5][#right[5] + 1] = "ComputerCraft:CC-TurtleAdvanced"
    right[5][#right[5] + 1] = "ComputerCraft:CC-Turtle"
    right[5][#right[5] + 1] = "ComputerCraft:treasureDisk"
    right[5][#right[5] + 1] = "ComputerCraft:CC-Computer"
    right[5][#right[5] + 1] = "ComputerCraft:CC-Peripheral"
    right[5][#right[5] + 1] = "ComputerCraft:disk"
    right[5][#right[5] + 1] = "ComputerCraft:advanced_modem"
    right[5][#right[5] + 1] = "ComputerCraft:CC-Cable"
    right[5][#right[5] + 1] = "ComputerCraft:pocketComputer"
    right[5][#right[5] + 1] = "ComputerCraft:CC-TurtleExpanded"
    right[5][#right[5] + 1] = "SGCraft:naquadah"
    right[5][#right[5] + 1] = "SGCraft:ccInterface"
    right[5][#right[5] + 1] = "SGCraft:rfPowerUnit"
    right[5][#right[5] + 1] = "SGCraft:sgIrisUpgrade"
    right[5][#right[5] + 1] = "SGCraft:stargateController"
    right[5][#right[5] + 1] = "SGCraft:stargateRing"
    right[5][#right[5] + 1] = "SGCraft:sgChevronUpgrade"
    right[5][#right[5] + 1] = "SGCraft:stargateBase"
    right[5][#right[5] + 1] = "BuildCraft|Core:engineBlock"
    right[5][#right[5] + 1] = "BuildCraft|Factory:pumpBlock"
    right[5][#right[5] + 1] = "ChickenChunks:chickenChunkLoader"
    right[6][#right[6] + 1] = "OpenComputers:material"
    right[6][#right[6] + 1] = "OpenComputers:card"
    right[6][#right[6] + 1] = "OpenComputers:component"
    right[6][#right[6] + 1] = "OpenComputers:tool"
    right[6][#right[6] + 1] = "OpenComputers:storage"
    right[6][#right[6] + 1] = "OpenComputers:print"
    right[6][#right[6] + 1] = "OpenComputers:cable"
    right[6][#right[6] + 1] = "OpenComputers:case1"
    right[6][#right[6] + 1] = "OpenComputers:diskDrive"
    right[6][#right[6] + 1] = "OpenComputers:case2"
    right[6][#right[6] + 1] = "OpenComputers:case3"
    right[6][#right[6] + 1] = "OpenComputers:disassembler"
    right[6][#right[6] + 1] = "OpenComputers:screen1"
    right[6][#right[6] + 1] = "OpenComputers:screen2"
    right[6][#right[6] + 1] = "OpenComputers:screen3"
    right[6][#right[6] + 1] = "OpenComputers:keyboard"
    right[6][#right[6] + 1] = "OpenComputers:upgrade"
    right[6][#right[6] + 1] = "OpenComputers:robot"
    right[6][#right[6] + 1] = "OpenComputers:motionSensor"
    right[6][#right[6] + 1] = "OpenComputers:wrench"
    right[6][#right[6] + 1] = "OpenComputers:item"
    right[6][#right[6] + 1] = "OpenComputers:eeprom"
    right[6][#right[6] + 1] = "OpenComputers:charger"
    right[6][#right[6] + 1] = "OpenComputers:assembler"
    right[6][#right[6] + 1] = "OpenComputers:printer"
    right[7][#right[7] + 1] = "minecraft:potion"
    right[7][#right[7] + 1] = "minecraft:sugar"
    right[7][#right[7] + 1] = "minecraft:nether_wart"
    right[7][#right[7] + 1] = "minecraft:fish,3"
    right[7][#right[7] + 1] = "minecraft:magma_cream"
    right[7][#right[7] + 1] = "minecraft:glass_bottle"
    right[7][#right[7] + 1] = "minecraft:blaze_rod"
    right[7][#right[7] + 1] = "minecraft:nether_star"
    right[7][#right[7] + 1] = "minecraft:blaze_powder"
    right[7][#right[7] + 1] = "minecraft:spider_eye"
    right[7][#right[7] + 1] = "minecraft:brewing_stand"
    right[7][#right[7] + 1] = "minecraft:fermented_spider_eye"
    right[7][#right[7] + 1] = "minecraft:golden_apple"
    right[7][#right[7] + 1] = "minecraft:speckled_melon"
    right[7][#right[7] + 1] = "minecraft:ender_eye"
    right[8][#right[8] + 1] = "minecraft:anvil"
    right[8][#right[8] + 1] = "minecraft:hopper"
    right[8][#right[8] + 1] = "minecraft:chest"
    right[8][#right[8] + 1] = "minecraft:bed"
    right[8][#right[8] + 1] = "minecraft:item_frame"
    right[8][#right[8] + 1] = "IronChest:BlockIronChest"
    right[8][#right[8] + 1] = "minecraft:repeater"
    right[8][#right[8] + 1] = "minecraft:torch"
    right[8][#right[8] + 1] = "TConstruct:decoration.stonetorch"
    right[8][#right[8] + 1] = "minecraft:redstone_lamp"
    right[8][#right[8] + 1] = "minecraft:piston"
    right[8][#right[8] + 1] = "minecraft:sticky_piston"
    right[8][#right[8] + 1] = "minecraft:tripwire_hook"
    right[8][#right[8] + 1] = "minecraft:rail"
    right[8][#right[8] + 1] = "minecraft:golden_rail"
    right[8][#right[8] + 1] = "minecraft:birch_door"
    right[8][#right[8] + 1] = "minecraft:oak_door"
    right[8][#right[8] + 1] = "minecraft:spruce_door"
    right[8][#right[8] + 1] = "minecraft:jungle_door"
    right[8][#right[8] + 1] = "minecraft:dark_oak_door"
    right[8][#right[8] + 1] = "minecraft:acacia_door"
    right[8][#right[8] + 1] = "minecraft:wooden_door"
    right[8][#right[8] + 1] = "minecraft:redstone_torch"
    right[8][#right[8] + 1] = "minecraft:dispenser"
    right[8][#right[8] + 1] = "minecraft:furnace"
    right[8][#right[8] + 1] = "minecraft:crafting_table"
    right[8][#right[8] + 1] = "minecraft:trapped_chest"
    right[8][#right[8] + 1] = "minecraft:dropper"
    right[8][#right[8] + 1] = "minecraft:trapdoor"
    right[8][#right[8] + 1] = "minecraft:stone_button"
    right[8][#right[8] + 1] = "minecraft:wooden_pressure_plate"
    right[8][#right[8] + 1] = "minecraft:stone_pressure_plate"
    right[8][#right[8] + 1] = "minecraft:lever"
    right[8][#right[8] + 1] = "ironchest:BlockIronChest"
    right[8][#right[8] + 1] = "minecraft:activator_rail"
    right[8][#right[8] + 1] = "minecraft:wooden_button"
    right[8][#right[8] + 1] = "minecraft:comparator"
    right[8][#right[8] + 1] = "ironchest:BlockIronChest"
    right[8][#right[8] + 1] = "minecraft:enchanting_table"
    right[8][#right[8] + 1] = "minecraft:ender_chest"
    right[8][#right[8] + 1] = "randomutilities:displayTable"
    right[8][#right[8] + 1] = "minecraft:iron_door"
    right[8][#right[8] + 1] = "minecraft:ladder"
    right[8][#right[8] + 1] = "TConstruct:decoration.stoneladder"
    right[8][#right[8] + 1] = "EnderStorage:enderChest"
    right[8][#right[8] + 1] = "ExtraUtilities:trashcan"
    right[8][#right[8] + 1] = "harvestcraft:sink"
    right[9][#right[9] + 1] = "minecraft:stonebrick"
    right[9][#right[9] + 1] = "minecraft:stone_brick_stairs"
    right[10][#right[10] + 1] = "minecraft:planks"
    right[10][#right[10] + 1] = "minecraft:stick"
    right[10][#right[10] + 1] = "minecraft:sign"
    right[10][#right[10] + 1] = "TConstruct:toolRod"
    right[11][#right[11] + 1] = "minecraft:redstone"
    right[12][#right[12] + 1] = "minecraft:redstone_block"
    right[13][#right[13] + 1] = "minecraft:coal,0"
    right[14][#right[14] + 1] = "GrimoireOfGaia:item.GrimoireOfGaia.MiscSoulFiery"
    right[14][#right[14] + 1] = "GrimoireOfGaia:item.GrimoireOfGaia.Shard"
    right[14][#right[14] + 1] = "TConstruct:oreBerries,0"
    right[14][#right[14] + 1] = "TConstruct:oreBerries,1"
    right[14][#right[14] + 1] = "TConstruct:oreBerries,2"
    right[14][#right[14] + 1] = "TConstruct:oreBerries,3"
    right[14][#right[14] + 1] = "TConstruct:oreBerries,4"
    right[14][#right[14] + 1] = "minecraft:gold_nugget"
    right[14][#right[14] + 1] = "ThermalFoundation:material,98"
    right[14][#right[14] + 1] = "TConstruct:materials,19"
    right[15][#right[15] + 1] = "minecraft:coal"
    right[16][#right[16] + 1] = "BuildCraft|Silicon:laserBlock"
    right[16][#right[16] + 1] = "BuildCraft|Silicon:laserTableBlock"
    right[16][#right[16] + 1] = "BuildCraft|Transport:item.buildcraftPipe.pipeitemsgold"
    right[16][#right[16] + 1] = "BuildCraft|Transport:item.buildcraftPipe.pipepoweremerald"
    right[16][#right[16] + 1] = "BuildCraft|Transport:item.buildcraftPipe.pipepowerdiamond"
    right[16][#right[16] + 1] = "BuildCraft|Transport:item.buildcraftPipe.pipepowergold"
    right[16][#right[16] + 1] = "BuildCraft|Transport:item.buildcraftPipe.pipestructurecobblestone"
    right[16][#right[16] + 1] = "BuildCraft|Transport:pipePowerAdapter"
    right[16][#right[16] + 1] = "BuildCraft|Factory:tankBlock"
    right[16][#right[16] + 1] = "BuildCraft|Transport:pipeFacade"
    right[17][#right[17] + 1] = "TConstruct:slime.gel"
    right[17][#right[17] + 1] = "TConstruct:strangeFood"
    right[17][#right[17] + 1] = "minecraft:slime_ball"
    right[18][#right[18] + 1] = "minecraft:leather_helmet"
    right[18][#right[18] + 1] = "minecraft:leather_chestplate"
    right[18][#right[18] + 1] = "minecraft:leather_leggings"
    right[18][#right[18] + 1] = "minecraft:leather_boots"
    right[18][#right[18] + 1] = "minecraft:chainmail_helmet"
    right[18][#right[18] + 1] = "minecraft:chainmail_chestplate"
    right[18][#right[18] + 1] = "minecraft:chainmail_leggings"
    right[18][#right[18] + 1] = "minecraft:chainmail_boots"
    right[18][#right[18] + 1] = "minecraft:iron_helmet"
    right[18][#right[18] + 1] = "minecraft:iron_chestplate"
    right[18][#right[18] + 1] = "minecraft:iron_leggings"
    right[18][#right[18] + 1] = "minecraft:iron_boots"
    right[18][#right[18] + 1] = "minecraft:diamond_helmet"
    right[18][#right[18] + 1] = "minecraft:diamond_chestplate"
    right[18][#right[18] + 1] = "minecraft:diamond_leggings"
    right[18][#right[18] + 1] = "minecraft:diamond_boots"
    right[18][#right[18] + 1] = "minecraft:golden_helmet"
    right[18][#right[18] + 1] = "minecraft:golden_chestplate"
    right[18][#right[18] + 1] = "minecraft:golden_leggings"
    right[18][#right[18] + 1] = "minecraft:golden_boots"
    right[18][#right[18] + 1] = "minecraft:iron_horse_armor"
    right[18][#right[18] + 1] = "minecraft:golden_horse_armor"
    right[18][#right[18] + 1] = "minecraft:diamond_horse_armor"
    right[18][#right[18] + 1] = "ThermalFoundation:armor.helmetBronze"
    right[18][#right[18] + 1] = "ThermalFoundation:armor.bootsBronze"
    right[18][#right[18] + 1] = "ThermalFoundation:armor.helmetBronze"
    right[18][#right[18] + 1] = "ThermalFoundation:armor.legsBronze"
    right[18][#right[18] + 1] = "ThermalFoundation:armor.plateBronze"
    right[18][#right[18] + 1] = "randomutilities:heartCanister"
    right[18][#right[18] + 1] = "TConstruct:heartCanister"
    right[18][#right[18] + 1] = "ProjRed|Exploration:projectred.exploration.sapphirechestplate"
    right[18][#right[18] + 1] = "ProjRed|Exploration:projectred.exploration.rubychestplate"
    right[18][#right[18] + 1] = "ProjRed|Exploration:projectred.exploration.rubyboots"
    right[19][#right[19] + 1] = "EnderStorage:enderPouch"
    right[19][#right[19] + 1] = "ExtraUtilities:golden_lasso"
    right[19][#right[19] + 1] = "ExtraUtilities:watering_can"
    right[19][#right[19] + 1] = "minecraft:wooden_shovel"
    right[19][#right[19] + 1] = "minecraft:wooden_pickaxe"
    right[19][#right[19] + 1] = "minecraft:wooden_axe"
    right[19][#right[19] + 1] = "minecraft:wooden_hoe"
    right[19][#right[19] + 1] = "minecraft:stone_shovel"
    right[19][#right[19] + 1] = "minecraft:stone_pickaxe"
    right[19][#right[19] + 1] = "minecraft:stone_axe"
    right[19][#right[19] + 1] = "minecraft:stone_hoe"
    right[19][#right[19] + 1] = "minecraft:iron_shovel"
    right[19][#right[19] + 1] = "minecraft:iron_pickaxe"
    right[19][#right[19] + 1] = "minecraft:iron_axe"
    right[19][#right[19] + 1] = "minecraft:iron_hoe"
    right[19][#right[19] + 1] = "minecraft:golden_shovel"
    right[19][#right[19] + 1] = "minecraft:golden_pickaxe"
    right[19][#right[19] + 1] = "minecraft:golden_axe"
    right[19][#right[19] + 1] = "minecraft:golden_hoe"
    right[19][#right[19] + 1] = "minecraft:diamond_shovel"
    right[19][#right[19] + 1] = "minecraft:diamond_pickaxe"
    right[19][#right[19] + 1] = "minecraft:diamond_axe"
    right[19][#right[19] + 1] = "minecraft:diamond_hoe"
    right[19][#right[19] + 1] = "minecraft:shears"
    right[19][#right[19] + 1] = "minecraft:boat"
    right[19][#right[19] + 1] = "minechem:minechemPolytool"
    right[19][#right[19] + 1] = "ExtraUtilities:builderswand"
    right[19][#right[19] + 1] = "ThermalExpansion:wrench"
    right[19][#right[19] + 1] = "ThermalFoundation:tool.shearsWood"
    right[19][#right[19] + 1] = "TConstruct:hammer"
    right[19][#right[19] + 1] = "TConstruct:excavator"
    right[19][#right[19] + 1] = "TConstruct:lumberaxe"
    right[19][#right[19] + 1] = "TConstruct:pickaxe"
    right[19][#right[19] + 1] = "TConstruct:shovel"
    right[19][#right[19] + 1] = "minecraft:flint_and_steel"
    right[19][#right[19] + 1] = "minecraft:fishing_rod"
    right[19][#right[19] + 1] = "minecraft:lead"
    right[19][#right[19] + 1] = "minecraft:minecart"
    right[19][#right[19] + 1] = "minecraft:experience_bottle"
    right[19][#right[19] + 1] = "minecraft:compass"
    right[19][#right[19] + 1] = "minecraft:clock"
    right[19][#right[19] + 1] = "chisel:chisel"
    right[19][#right[19] + 1] = "harvestcraft:mixingbowlItem"
    right[19][#right[19] + 1] = "harvestcraft:potItem"
    right[19][#right[19] + 1] = "ProjRed|Exploration:projectred.exploration.sawsapphire"
    right[19][#right[19] + 1] = "ExtraUtilities:destructionpickaxe"
    right[19][#right[19] + 1] = "ExtraUtilities:erosionShovel"
    right[19][#right[19] + 1] = "ThermalFoundation:tool.hoeBronze"
    right[20][#right[20] + 1] = "minecraft:wooden_sword"
    right[20][#right[20] + 1] = "minecraft:stone_sword"
    right[20][#right[20] + 1] = "minecraft:iron_sword"
    right[20][#right[20] + 1] = "minecraft:golden_sword"
    right[20][#right[20] + 1] = "minecraft:diamond_sword"
    right[20][#right[20] + 1] = "ThermalFoundation:tool.swordBronze"
    right[20][#right[20] + 1] = "TConstruct:longsword"
    right[20][#right[20] + 1] = "minecraft:bow"
    right[20][#right[20] + 1] = "minecraft:arrow"
    right[20][#right[20] + 1] = "TConstruct:Shuriken"
    right[21][#right[21] + 1] = "ExtraUtilities:generator"
    right[21][#right[21] + 1] = "ExtraUtilities:divisionSigil"
    right[21][#right[21] + 1] = "ExtraUtilities:bedrockiumIngot"
    right[21][#right[21] + 1] = "ExtraUtilities:decorativeBlock1"
    right[21][#right[21] + 1] = "ExtraUtilities:nodeUpgrade"
    right[21][#right[21] + 1] = "ExtraUtilities:pipes"
    right[21][#right[21] + 1] = "ExtraUtilities:extractor_base"
    right[21][#right[21] + 1] = "ExtraUtilities:Tank"
    right[21][#right[21] + 1] = "ExtraUtilities:timer"
    right[22][#right[22] + 1] = "ThermalExpansion:Device"
    right[22][#right[22] + 1] = "ThermalExpansion:Glass"
    right[22][#right[22] + 1] = "ThermalDynamics:ThermalDynamics_0"
    right[22][#right[22] + 1] = "ThermalDynamics:ThermalDynamics_16"
    right[22][#right[22] + 1] = "ThermalDynamics:ThermalDynamics_32"
    right[22][#right[22] + 1] = "ThermalDynamics:servo"
    right[22][#right[22] + 1] = "ThermalExpansion:Cell"
    right[22][#right[22] + 1] = "ThermalExpansion:Frame"
    right[22][#right[22] + 1] = "ThermalExpansion:Tank"
    right[22][#right[22] + 1] = "ThermalExpansion:Tesseract"
    right[22][#right[22] + 1] = "ThermalExpansion:material,16"
    right[22][#right[22] + 1] = "ThermalFoundation:material,512"
    right[22][#right[22] + 1] = "ThermalFoundation:material,4"
    right[22][#right[22] + 1] = "ThermalExpansion:Machine"
    right[23][#right[23] + 1] = "minecraft:paper"
    right[23][#right[23] + 1] = "minecraft:bookshelf"
    right[23][#right[23] + 1] = "minecraft:book"
    right[23][#right[23] + 1] = "minecraft:written_book"
    right[23][#right[23] + 1] = "ComputerCraft:printout"
    right[24][#right[24] + 1] = "minecraft:dye,4"
    right[25][#right[25] + 1] = "minecraft:lapis_block"
    right[26][#right[26] + 1] = "minecraft:gold_ore"
    right[26][#right[26] + 1] = "minecraft:iron_ore"
    right[26][#right[26] + 1] = "minecraft:coal_ore"
    right[26][#right[26] + 1] = "minecraft:lapis_ore"
    right[26][#right[26] + 1] = "minecraft:diamond_ore"
    right[26][#right[26] + 1] = "minecraft:redstone_ore"
    right[26][#right[26] + 1] = "minecraft:emerald_ore"
    right[26][#right[26] + 1] = "minecraft:quartz_ore"
    right[27][#right[27] + 1] = "TConstruct:SearedBrick,1"
    right[27][#right[27] + 1] = "TConstruct:SearedBrick,2"
    right[27][#right[27] + 1] = "TConstruct:SearedBrick,3"
    right[27][#right[27] + 1] = "TConstruct:SearedBrick,4"
    right[27][#right[27] + 1] = "TConstruct:SearedBrick,5"
    right[27][#right[27] + 1] = "ThermalFoundation:Ore"
    right[27][#right[27] + 1] = "TConstruct:GravelOre"
    right[27][#right[27] + 1] = "tc:oreTC,0"
    right[27][#right[27] + 1] = "qCraft:quantumore"
    right[27][#right[27] + 1] = "ProjRed|Exploration:projectred.exploration.ore"
    right[27][#right[27] + 1] = "SGCraft:naquadahOre"
    right[28][#right[28] + 1] = "TConstruct:ore.berries.two"
    right[28][#right[28] + 1] = "TConstruct:ore.berries.one"
    right[29][#right[29] + 1] = "ExtraUtilities:cobblestone_compressed"
    right[30][#right[30] + 1] = "minecraft:coal_block"
    right[31][#right[31] + 1] = "TConstruct:oreBerries,5"
    right[32][#right[32] + 1] = "qCraft:dust"
    right[33][#right[33] + 1] = "ProjRed|Core:projectred.core.part,37" -- Ruby
    right[33][#right[33] + 1] = "ProjRed|Core:projectred.core.part,38" -- Saphire
    right[33][#right[33] + 1] = "ProjRed|Core:projectred.core.part,39" -- Peridot
    right[34][#right[34] + 1] = "ProjRed|Core:projectred.core.part,56" -- Electrotine
    right[35][#right[35] + 1] = "minecraft:quartz_block"
    right[36][#right[36] + 1] = "minecraft:netherrack"
    right[37][#right[37] + 1] = "minecraft:end_stone"
    right[38][#right[38] + 1] = "minecraft:obsidian"
    right[39][#right[39] + 1] = "minecraft:iron_block"
    right[40][#right[40] + 1] = "minecraft:sapling"
    right[40][#right[40] + 1] = "minecraft:flower"
    right[40][#right[40] + 1] = "minecraft:fern"
    right[40][#right[40] + 1] = "minecraft:leaves"
    right[40][#right[40] + 1] = "minecraft:dead_bush"
    right[40][#right[40] + 1] = "minecraft:waterlily"
    right[40][#right[40] + 1] = "minecraft:cactus"
    right[40][#right[40] + 1] = "minecraft:red_mushroom"
    right[40][#right[40] + 1] = "minecraft:lily_pad"
    right[40][#right[40] + 1] = "minecraft:vines"
    right[40][#right[40] + 1] = "minecraft:red_flower"
    right[40][#right[40] + 1] = "minecraft:brown_mushroom"
    right[40][#right[40] + 1] = "minecraft:yellow_flower"
    right[40][#right[40] + 1] = "minecraft:double_plant"
    right[40][#right[40] + 1] = "TConstruct:slime.sapling"
    right[41][#right[41] + 1] = "minecraft:clay"
    right[41][#right[41] + 1] = "minecraft:clay_ball"
    right[41][#right[41] + 1] = "minecraft:mossy_cobblestone"
    right[41][#right[41] + 1] = "minecraft:brick_block"
    right[41][#right[41] + 1] = "minecraft:brick"
    right[42][#right[42] + 1] = "minecraft:nether_brick"
    right[42][#right[42] + 1] = "minecraft:netherbrick"
    right[43][#right[43] + 1] = "minecraft:quartz"
    right[44][#right[44] + 1] = "minecraft:dye"
    right[45][#right[45] + 1] = "minecraft:soul_sand"
    right[46][#right[46] + 1] = "ForgeMicroblock:microblock"
    right[46][#right[46] + 1] = "chisel:marble_pillar"
    right[46][#right[46] + 1] = "chisel:holystone"
    right[46][#right[46] + 1] = "chisel:iron_block"
    right[46][#right[46] + 1] = "chisel:concrete"
    right[46][#right[46] + 1] = "chisel:factoryblock"
    right[46][#right[46] + 1] = "chisel:cobblestone"
    right[46][#right[46] + 1] = "chisel:glass"
    right[46][#right[46] + 1] = "minecraft:stained_glass"
    right[47][#right[47] + 1] = "TConstruct:materials,2"
    right[47][#right[47] + 1] = "TConstruct:materials,6"
    right[47][#right[47] + 1] = "TConstruct:toolShard"
    right[47][#right[47] + 1] = "TConstruct:swordBlade"
    right[47][#right[47] + 1] = "TConstruct:excavatorHead"
    right[47][#right[47] + 1] = "TConstruct:handGuard"
    right[47][#right[47] + 1] = "TConstruct:CraftedSoil"
    right[47][#right[47] + 1] = "TConstruct:Smeltery"
    right[47][#right[47] + 1] = "TConstruct:blankPattern"
    right[47][#right[47] + 1] = "TConstruct:Armor.DryingRack"
    right[47][#right[47] + 1] = "TConstruct:trap.punji"
    right[47][#right[47] + 1] = "TConstruct:manualBook"
    right[47][#right[47] + 1] = "TConstruct:CraftingStation"
    right[47][#right[47] + 1] = "TConstruct:ToolStationBlock"
    right[47][#right[47] + 1] = "TConstruct:metalPattern"
    right[48][#right[48] + 1] = "minechem:tile.oreUranium"
    right[49][#right[49] + 1] = "tc:oreTC,2"
    right[49][#right[49] + 1] = "tc:oreTC,1"
    right[50][#right[50] + 1] = "minecraft:snow"
    right[50][#right[50] + 1] = "minecraft:snowball"
    right[51][#right[51] + 1] = "ThermalFoundation:material,16"
    right[52][#right[52] + 1] = "ThermalFoundation:material,20"
    right[53][#right[53] + 1] = "ThermalExpansion:material,515"
    right[54][#right[54] + 1] = "ThermalFoundation:material,17"
    return right
end

--[[
----    FIND CHEST FUNCTIONS
--]]

function get_info(chest_item)
    local str
    local name

    name, str = chest_item:match("([^,]+),([^,]+)")
    if name then
        return name, tonumber(str)
    else
        return chest_item, nil
    end
end

function get_item_list()
    local chest = {}

    chest["left"] = get_item_list_left()
    chest["right"] = get_item_list_right()
    return chest
end

function get_item_chest_id(side, item, damage)
    local i
    local meta
    local damageRef
    local bestCandidate
    local name
    local chest

    i = 1
    meta = 1
    name = true
    chest = get_item_list()
    if (side and side ~= "left" and side ~= "right") or not item or not side then
        error("get_item_chest_id: Invalid side or nil item")
    end
    while chest[side][i] do
        meta = 1
        while chest[side][i][meta] do
            name, damageRef = get_info(chest[side][i][meta])
            if name == item and damageRef and damageRef == damage then
                return i
            elseif name == item and not damageRef then
                bestCandidate = i
            end
            meta = meta + 1
        end
        i = i + 1
    end
    return bestCandidate
end

function get_max_distance_side(side, max, data)
    local tmp
    
    tmp = get_item_chest_id("left", data.name, data.damage)
    if not tmp then
        return LENTH_MAX
    elseif tmp > max then
        return tmp
    end
    return max
end

function get_max_distance(inv_map)
    local slot
    local max_distance

    max_distance = 0
    slot = robot.inventorySize()
    while slot > 0 do
        if inv_map[slot] then
            max_distance = get_max_distance_side("left", max_distance, inv_map[slot])
            max_distance = get_max_distance_side("right", max_distance, inv_map[slot])
            if max_distance == LENTH_MAX then
                return LENTH_MAX
            end
        end
        slot = slot - 1
    end
    return max_distance
end

--[[
----    DELIVER FUNCTIONS
--]]

function line(side, max_distance, inv_map)
    local i

    i = 0
    while i < max_distance do
        if i > 0 then
            move.move(1, side.front)
        end
        i = i + 1
        if side == "right" then
            put_under_chest(side, i, inv_map)
        else
            put_under_chest(side, max_distance - (i - 1), inv_map)
        end
    end
end

function put_under_chest(side, chest_id, inv_map)
    local tmp
    local slot

    slot = robot.inventorySize()
    while slot > 0 do
        if inv_map[slot] then
            tmp = get_item_chest_id(side, inv_map[slot].name, inv_map[slot].damage)
            if (tmp and chest_id == tmp) or (not tmp and chest_id == LENTH_MAX and side == "left") then
                column(inv_map[slot].name, inv_map[slot].damage, inv_map)
            end
        end
        slot = slot - 1
    end
end

function column(name, damage, inv_map)
    local slot
    local offset
    local bool = false

    offset = 0
    slot = robot.inventorySize()
    while slot > 0 do
        if inv_map[slot] and inv_map[slot].name == name and damage == inv_map[slot].damage then
            bool = false
            robot.select(slot)
            while not robot.dropDown() do
                move.move(1, side.right)
                offset = offset + 1
            end
            inv_map[slot] = false
        end
        slot = slot - 1
    end
    move.move(offset, side.left)
end

function suck_all()
    local moved

    moved = false
    while robot.suckUp() do
        moved = true
    end
    return moved
end

--[[
----    LOG FUNCTIONS
--]]

function dump(o)
    if type(o) == 'table' then
        local s = '{ '
        for k,v in pairs(o) do
            if type(k) ~= 'number' then k = '"'..k..'"' end
            s = s .. '[' .. k .. '] = ' .. dump(v) .. '\n'
        end
        return s .. '}\n'
    else
        return tostring(o)
    end
end

function get_known_and_unknown(inv_map)
    local slot
    local data
    local tmp
    local k = {}
    local u = {}

    slot = robot.inventorySize()
    while slot > 0 do
        data = inv_map[slot]
        if data then
            tmp = tostring(data.name) .. "," .. tostring(data.damage)
            if get_item_chest_id("left", data.name, data.damage) == LENTH_MAX and
               get_item_chest_id("right", data.name, data.damage) == LENTH_MAX then
                if not utilitie.is_elem_in_list(u, tmp) then
                    u[#u + 1] = tmp
                end
                print("No chest found for ", data.name, " ", data.damage)
            elseif not utilitie.is_elem_in_list(k, tmp) then
                k[#k + 1] = tmp
            end
        end
        slot = slot - 1
    end
    return u, k
end

function purge_includes(main, sub)
    local i
    local x

    i = 1
    while i <= #main do
        x = 1
        while x <= #sub do
            if main[i] == sub[x] then
                main[i] = main[#main]
                main[#main] = nil
            end
            x = x + 1
        end
        i = i + 1
    end
    return main
end

function check_default_file(filename)
    local f

    if not utilitie.file_exists(filename) then
        f = io.open(filename, "w")
        f:write("minecraft:air\n")
        f:close()
    end
end

function get_file_per_lines(filename)
    local lines = {}

    for line in io.lines(filename) do
        lines[#lines + 1] = line
    end
    table.sort(lines)
    return lines
end

function update_unknown_list(inv_map)
    local lines
    local u
    local k

    check_default_file(UNKNOWN_LIST)
    u, k = get_known_and_unknown(inv_map)
    io.input(UNKNOWN_LIST)
    lines = get_file_per_lines()
    io.input():close()
    lines = purge_includes(lines, k)
    lines = purge_includes(lines, u)
    lines = utilitie.concatenate_arrays(lines, u)
    table.sort(lines)
    io.output(UNKNOWN_LIST)
    for i, l in ipairs(lines) do
        io.write(l .. "\n")
    end
    io.output():close()
end

--[[
----    ENERGY FUNCTIONS
--]]

function base_to_charger()
    move.move(3, side.front)
end

function charger_to_base()
    move.move(3, side.back)
end

function check_energy(on_base)
    if energy.get_level() < REQ_ENERGY_PER_LOOP then
        if not on_base then
            return false
        end
        base_to_charger()
        energy.wait_charging()
        charger_to_base()
    end
    return true
end

--[[
----    CORE FUNCTIONS
--]]

function move_angle(distance)
    move.move_orientation(side.left)
    move.move(distance, side.front)
    move.move_orientation(side.left)
end

function check_energy_and_line(border, max_distance, inv_map)
    if check_energy() then
        line(border, max_distance, inv_map)
    else
        move.move(max_distance, side.front)
    end
end

function core()
    local inv_map
    local max_distance
    local message

    while true do
        message = true
        while not suck_all() and inventory.is_empty do
            if message then
                print('Idle')
            end
            os.sleep(IDLE_SLEEP_TIME)
            message = false
        end
        print('Active')
        check_energy(true)
        inv_map = inventory.get_inventory_map()
        update_unknown_list(inv_map)
        max_distance = get_max_distance(inv_map)
        move.move(4, side.right)
        check_energy_and_line("right", max_distance, inv_map)
        move_angle(8)
        check_energy_and_line("left", max_distance, inv_map)
        move_angle(4)
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

core()