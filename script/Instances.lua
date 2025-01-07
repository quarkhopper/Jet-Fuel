#include "Utils.lua"
#include "Types.lua"
#include "Defs.lua"
#include "HSVRGB.lua"

function createFireballInst()
	local inst = {}
	inst.sparks = {}
	inst.center = Vec()
	inst.dir = Vec()
	inst.impulse = nil
	inst.sparksMax = nil
	inst.radius = nil
	return inst
end

function createSparkInst(source)
	local inst = {}
	inst.pos = Vec() -- set on init
	inst.speed = 0 -- set on init
	inst.dir = source.dir or random_vec(1)
	inst.splitsRemaining = source.splitCount or source.splitsRemaining
	inst.impulse = source.impulse
	inst.fizzleFreq = source.fizzleFreq
	inst.splitSpeed = source.splitSpeed
	inst.splitFreq = source.splitFreq or TOOL.sparkSplitFreqStart.value
	inst.fireballRadius = source.fireballRadius
	inst.fireballSparksMax = source.fireballSparksMax
	inst.torusMag = source.torusMag
	inst.vacuumMag = source.vacuumMag
	inst.inflationMag = source.inflationMag

	-- below are set per tick
	inst.distanceFromOrigin = 0
	inst.distance_n = 1
	inst.vectorFromOrigin = 0
	inst.inverseVector = Vec()
	inst.lookOriginDir = nil
	return inst
end

function createBombInst(shape)
	local inst = {}
	inst.position = Vec() -- set when ready to detonate
	inst.dir = nil
	inst.shape = shape
	inst.impulse = TOOL.impulsePower.value
	inst.sparkCount = TOOL.bombSparks.value
	inst.splitSpeed = TOOL.sparkSplitSpeed.value
	inst.fizzleFreq = TOOL.sparkFizzleFreq.value
	inst.splitCount = math.ceil((TOOL.bombEnergy.value * 10^2)/inst.sparkCount)
	inst.fireballRadius = TOOL.fireballRadius.value
	inst.fireballSparksMax = TOOL.fireballSparksMax.value
	inst.torusMag = TOOL.sparkTorusMag.value
	inst.vacuumMag = TOOL.sparkVacuumMag.value
	inst.inflationMag = TOOL.sparkInflateMag.value
	return inst
end

function createJetInst(shape)
	-- converts a bomb to a jet
	local jet = createBombInst(shape)
	jet.impulse = 0
	jet.splitSpeed = TOOL.jetSplitSpeed.value
	jet.fizzleFreq = TOOL.jetFizzleFreq.value
	jet.fireballRadius = TOOL.jetFireballRadius.value
	jet.fireballSparksMax = TOOL.jetFireballSparksMax.value
	jet.torusMag = TOOL.jetTorusMag.value
	jet.vacuumMag = TOOL.jetVacuumMag.value
	jet.inflationMag = TOOL.jetInflateMag.value
	return jet
end

function debugBomb(bomb)
	DebugPrint("dir: "..tostring(bomb.dir))
	DebugPrint("impulse: "..bomb.impulse)
	DebugPrint("sparkCount: "..bomb.sparkCount)
	DebugPrint("splitSpeed: "..bomb.splitSpeed)
	DebugPrint("fizzleFreq: "..bomb.fizzleFreq)
	DebugPrint("splitCount: "..bomb.splitCount)
	DebugPrint("fireballRadius: "..bomb.fireballRadius)
	DebugPrint("fireballSparksMax: "..bomb.fireballSparksMax)
end


