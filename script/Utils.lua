#include "Defs.lua"

function random_in_range(low, high)
	return (math.random() * (high - low)) + low
end

function split_string(inputString, separator)
	if inputString == nil or inputString == "" then return {} end
	if separator == nil then
			separator = "%s"
	end
	local t={}
	for str in string.gmatch(inputString, "([^"..separator.."]+)") do
			table.insert(t, str)
	end
	return t
end

function join_strings(inputTable, delimeter)
	if inputTable == nil or #inputTable == 0 then return "" end
	if #inputTable == 1 then return tostring(inputTable[1]) end
	
	local concatString = tostring(inputTable[1])
	for i=2, #inputTable do
		concatString = concatString..delimeter..tostring(inputTable[i])
	end
	
	return concatString
end

function vec_to_string(vec)
	return vec[1]..DELIM.VEC
	..vec[2]..DELIM.VEC
	..vec[3]
end

function string_to_vec(vecString)
	local parts = split_string(vecString, DELIM.VEC)
	return Vec(parts[1], parts[2], parts[3])
end

function random_vec(magnitude)
	return Vec(random_vec_component(magnitude), random_vec_component(magnitude), random_vec_component(magnitude))
end

function random_vec_component(magnitude)
	return (math.random() * magnitude * 2) - magnitude
end 

function vary_by_percentage(value, variation)
	return value + (value * random_vec_component(variation))
end

function random_float(min, max)
	local range = max - min
	return (math.random() * range) + min
end

function fraction_to_range_value(fraction, min, max)
	local range = max - min
	return (range * fraction) + min
end

function range_value_to_fraction(value, min, max)
	frac = (value - min) / (max - min)
	return frac
end

function vecs_equal(a, b)
	return a[1] == b[1] 
	and a[2] == b[2]
	and a[3] == b[3]
end 

function quat_between_vecs(v1, v2)
    local a = VecCross(v1, v2)
    local w = (VecLength(v1)^2 * VecLength(v2)^2) ^ 0.5 + VecDot(v1, v2)
    return Quat(a[1], a[2], a[3], w)
end

function get_shape_center(shape)
	if GetShapeVoxelCount(shape) == 0 then return nil end
	local lower, upper = GetShapeBounds(shape)
	return VecLerp(lower, upper, 0.5)
end

function get_keys_and_values(t)
	keys = {}
	values = {}
	for k,v in pairs(t) do
		table.insert(keys, k)
		table.insert(values, v)
	end
	return keys, values
end

function get_index(t, s)
	for k,v in pairs(t) do
		if v == s then return k end
	end
	return nil
end

function bracket_value(value, max, min)
	return math.max(math.min(max, value), min)
end

function round_to_place(value, place)
	multiplier = math.pow(10, place)
	rounded = math.floor(value * multiplier)
	return rounded / multiplier
end

function round(value)
	return math.floor(value + 0.5)
end

function debug_options(set)
	DebugPrint(set.name)
	for i = 3, #set.options do
		local option = set.options[i]
		DebugPrint(option.toString())
	end
end

function is_number(value)
	if tonumber(value) ~= nil then
		return true
	end
    return false
end

function average_vec(values)
	local sum_x = 0
	local sum_y = 0
	local sum_z = 0
	for i=1, #values do
		sum_x = sum_x + values[i][1]
		sum_y = sum_y + values[i][2]
		sum_z = sum_z + values[i][3]
	end
	return Vec(sum_x / #values, sum_y / #values, sum_z / #values)
end

function copyTable(t)
	local copy = {}
	for i=1, #t do
		table.insert(copy, t[i])
	end
	return copy
end

function reverseTable(t)
	local reversed = {}
	for i=1, #t do
		table.insert(reversed, 1, t[i])
	end
	return reversed
end



stringToBoolean={ ["true"]=true, ["false"]=false }


	