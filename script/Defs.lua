CURRENT_VERSION = "5.0"
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
KEY.DETONATE = setup_keybind("detonate", "detonate", "X")
KEY.PLANT = setup_keybind("plant/infuse", "plant", "LMB")
KEY.CLEAR = setup_keybind("clear all", "clear", "V")
KEY.OPTIONS = setup_keybind("options", "options", "O")
KEY.INFUSE_MODE = setup_keybind("infuse on/off", "infuse_mode", "I")
KEY.SINGLE_MODE = setup_keybind("single on/off", "single_mode", "B")
KEY.REVERSE_MODE = setup_keybind("reverse on/off", "reverse_mode", "N")
KEY.STICKY_MODE = setup_keybind("sticky on/off", "sticky_mode", "M")

keybind_options = {KEY.DETONATE, KEY.PLANT, KEY.CLEAR, KEY.OPTIONS, KEY.INFUSE_MODE, KEY.SINGLE_MODE, KEY.REVERSE_MODE, KEY.STICKY_MODE }

-- set on init
TOOL = {}
VALUES = {}

VALUES.SPARK_HURT_SCALE = 0.005
VALUES.IMPULSE_SCALE = 0.005
VALUES.PRESSURE_EFFECT_SCALE = 10^-3
VALUES.PUFF_CONTRAST = 0.65
VALUES.UP_VECTOR = Vec(0,1,0)

-- UI 
UI = {}
UI.LEGEND_TEXT_SIZE = 20
UI.OPTION_TEXT_SIZE = 14
UI.OPTION_CONTROL_WIDTH = 300
