#include "Types.lua"

function create_option_set()
	local inst = {}
	inst.name = "Unnamed"
	inst.display_name = "Unnamed option set"
	inst.version = CURRENT_VERSION
	inst.options = {}

	return inst
end

function option_set_to_string(inst)
	local ser_parts = {inst.version}
	for i = 1, #inst.options do
		ser_parts[#ser_parts + 1] = mode_option_to_string(inst.options[i])
	end
	return join_strings(ser_parts, DELIM.OPTION_SET)
end

function save_option_set(inst)
	SetString(REG.PREFIX_TOOL_OPTIONS, option_set_to_string(inst))
end

function load_option_set(create_if_not_found)
	local ser = GetString(REG.PREFIX_TOOL_OPTIONS)
	if ser == "" then
		if create_if_not_found then
			local oset = create_general_option_set()
			return oset
		else 
			return nil
		end
	end
	local options = option_set_from_string(ser)
	return options
end


function option_set_from_string(ser)
	local options = create_option_set()
	options.options = {}
	local option_sers = split_string(ser, DELIM.OPTION_SET)
	options.version = option_sers[1]
	local parse_start_index = 2
	for i = parse_start_index, #option_sers do
		local option_ser = option_sers[i]
		local option = mode_option_from_string(option_ser)
		options[option.key] = option
		table.insert(options.options, option)
	end
	return options
end

function reset_all_options()
	option_set_reset()
end

function option_set_reset()
	ClearKey(REG.PREFIX_TOOL_OPTIONS)
	for i=1, #keybind_options do
		local keybind = keybind_options[i]
		ClearKey(REG.PREFIX_TOOL_KEYBIND..REG.DELIM..keybind.reg)
	end
end

function create_mode_option(o_type, value, key, friendly_name)
	local inst = {}
	inst.type = o_type or option_type.numeric
	inst.value = value
	inst.key = key or "unnamed_option"
	inst.friendly_name = friendly_name or "Unnamed option"
	return inst
end

function mode_option_to_string(inst)
	local parts = {}
	parts[1] = tostring(inst.type)
	if inst.type == option_type.color then
		parts[2] = vec_to_string(inst.value)
	else
		parts[2] = inst.value
	end
	parts[3] = inst.key
	parts[4] = inst.friendly_name

	return join_strings(parts, DELIM.OPTION)
end

function mode_option_from_string(ser)
	local option = create_mode_option()
	local parts = split_string(ser, DELIM.OPTION)
	option.type = tonumber(parts[1])
	if option.type == option_type.color then
		option.value = string_to_vec(parts[2])
	else
		option.value = tonumber(parts[2])
	end
	option.key = parts[3]
	option.friendly_name = parts[4]
	return option
end

function create_general_option_set()
    local oSet = create_option_set()
    oSet.version = CURRENT_VERSION
	return oSet
end

