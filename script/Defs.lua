CURRENT_VERSION = "3.5"
TOOL_NAME = "Jet Fuel"

-- delimeters
DELIM = {}
DELIM.VEC = ":"
DELIM.STRINGS = "~"
DELIM.ENUM_PAIR = "&"
DELIM.OPTION_SET = "|"
DELIM.OPTION = ";"

-- registry related delimeters and strings
REG = {}
REG.DELIM = "."
REG.TOOL_KEY = "jetfuel"
REG.TOOL_NAME = "savegame.mod.tool." .. REG.TOOL_KEY .. ".quarkhopper"
REG.TOOL_OPTION = "option"
REG.PREFIX_TOOL_OPTIONS = REG.TOOL_NAME .. REG.DELIM .. REG.TOOL_OPTION
REG.TOOL_KEYBIND = "keybind"
REG.PREFIX_TOOL_KEYBIND = REG.TOOL_NAME .. REG.DELIM .. REG.TOOL_KEYBIND

-- Keybinds
function setup_keybind(name, reg, default_key)
    local keybind = {["name"] = name, ["reg"] = reg}
    keybind.key = GetString(REG.PREFIX_TOOL_KEYBIND..REG.DELIM..keybind.reg)
    if keybind.key == "" then 
        keybind.key = default_key
        SetString(REG.PREFIX_TOOL_KEYBIND..REG.DELIM..keybind.reg, keybind.key)
    end
    return keybind
end

KEY = {}
KEY.PLANT_BOMB = setup_keybind("Plant canister", "plant_bomb", "LMB")
KEY.PLANT_GROUP = setup_keybind("Plant 10 canisters", "plant_group", "M")
KEY.DETONATE = setup_keybind("Detonate jet fuel", "detonate", "X")
KEY.DETONATE_LAST = setup_keybind("Detonate last", "detonate_last", "L")
KEY.STOP_FIRE = setup_keybind("Stop fire", "stop_fire", "MMB")
KEY.OPTIONS = setup_keybind("Options", "options", "O")
KEY.MODE = setup_keybind("Change modes (plant / infuse)", "mode", "B")
KEY.CLEAR = setup_keybind("Clear all jet fuel from map", "clear", "V")

-- set on init
TOOL = {}
VALUES = {}

VALUES.SPARK_HURT_ADJUSTMENT = 0.005
VALUES.SUCTION_IMPULSE_ADJUSTMENT = 0.005 -- times the power
VALUES.DEFAULT_PUFF_COLOR = Vec(0, 0, 0.7)
VALUES.PRESSURE_EFFECT_SCALE = 10^-3
VALUES.DIRECTIONAL_VECTOR = Vec(0,1,0)
VALUES.FIREBALL_SPLIT_DIST = 10

-- UI 
UI = {}
UI.OPTION_TEXT_SIZE = 14
UI.OPTION_CONTROL_WIDTH = 300
UI.OPTION_BUMP_BUTTON_WIDTH = 4