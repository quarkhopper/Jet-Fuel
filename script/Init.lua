#include "Utils.lua"
#include "Defs.lua"
#include "Types.lua"
#include "HSVRGB.lua"

function createDefaultOptions()
    local oSet = create_option_set()
    oSet.name = "default"
    oSet.version = CURRENT_VERSION

	-- colors

	oSet.sparkColor = create_mode_option(
		option_type.color,
		Vec(7.7, 0.99, 0.65),
		"sparkColor",
		"Spark color")
	oSet.options[#oSet.options + 1] = oSet.sparkColor

	oSet.smokeColor = create_mode_option(
		option_type.color,
		Vec(0, 0, 0.1),
		"smokeColor",
		"Smoke color")
	oSet.options[#oSet.options + 1] = oSet.smokeColor

	-- simulation

	oSet.sparksSimulation = create_mode_option(
		option_type.numeric, 
		1000,
		"sparksSimulation",
		"Sparks simulation limit, all fireballs together")
	oSet.options[#oSet.options + 1] = oSet.sparksSimulation	

	-- blast effects

	oSet.bombEnergy = create_mode_option(
		option_type.numeric, 
		200,
		"bombEnergy",
		"Bomb energy at detonation (affects lifespan)")
	oSet.options[#oSet.options + 1] = oSet.bombEnergy		

	oSet.bombSparks = create_mode_option(
		option_type.numeric, 
		100,
		"bombSparks",
		"Bomb sparks at detonation (affects size)")
	oSet.options[#oSet.options + 1] = oSet.bombSparks		
	
	oSet.detonationTrigger = create_mode_option(
		option_type.numeric, 
		-1,
		"detonationTrigger",
		"Spark when next detonation (-1 for simultaneous explosions)")
	oSet.options[#oSet.options + 1] = oSet.detonationTrigger

	oSet.fireballSparksMin = create_mode_option(
		option_type.numeric, 
		20,
		"fireballSparksMin",
		"Minimum sparks below which fireball dies")
	oSet.options[#oSet.options + 1] = oSet.fireballSparksMin	

	oSet.fireballSparksMax = create_mode_option(
		option_type.numeric, 
		600,
		"fireballSparksMax",
		"Maximum number of sparks per one fireball")
	oSet.options[#oSet.options + 1] = oSet.fireballSparksMax	

	oSet.fireballRadius = create_mode_option(
		option_type.numeric, 
		6,
		"fireballRadius",
		"Torus radius (affects lumpiness)")
	oSet.options[#oSet.options + 1] = oSet.fireballRadius

	oSet.blastPowerPrimary = create_mode_option(
		option_type.numeric, 
		3,
		"blastPowerPrimary",
		"Blast power")
	oSet.options[#oSet.options + 1] = oSet.blastPowerPrimary

	oSet.blastSpeed = create_mode_option(
		option_type.numeric, 
		0.5,
		"blastSpeed",
		"Blast speed at detonation (affects size)")
	oSet.options[#oSet.options + 1] = oSet.blastSpeed	

	oSet.sparkHurt = create_mode_option(
		option_type.numeric, 
		0.01,
		"sparkHurt",
		"Spark player hurt threshold")
	oSet.options[#oSet.options + 1] = oSet.sparkHurt	

	oSet.sparkHoleVoxelsSoft = create_mode_option(
		option_type.numeric, 
		5,
		"sparkHoleVoxelsSoft",
		"Spark erosion, soft materials (number of voxel)")
	oSet.options[#oSet.options + 1] = oSet.sparkHoleVoxelsSoft

	oSet.sparkHoleVoxelsMedium = create_mode_option(
		option_type.numeric, 
		3,
		"sparkHoleVoxelsMedium",
		"Spark erosion, medium materials (number of voxel)")
	oSet.options[#oSet.options + 1] = oSet.sparkHoleVoxelsMedium

	oSet.sparkHoleVoxelsHard = create_mode_option(
		option_type.numeric, 
		1,
		"sparkHoleVoxelsHard",
		"Spark erosion, hard materials (number of voxel)")
	oSet.options[#oSet.options + 1] = oSet.sparkHoleVoxelsHard

	oSet.ignitionRadius = create_mode_option(
		option_type.numeric, 
		5,
		"ignitionRadius",
		"Fire ignition and player hurt radius")
	oSet.options[#oSet.options + 1] = oSet.ignitionRadius	

	oSet.ignitionProbes = create_mode_option(
		option_type.numeric, 
		1,
		"ignitionProbes",
		"First ignition raycasts (pre-bounce) per fireball spark per tick")
	oSet.options[#oSet.options + 1] = oSet.ignitionProbes

	oSet.ignitionCount = create_mode_option(
		option_type.numeric, 
		1,
		"ignitionCount",
		"Ignitions from secondary raycast (post-bounce) on hit")
	oSet.options[#oSet.options + 1] = oSet.ignitionCount

	oSet.impulsePower = create_mode_option(
		option_type.numeric, 
		-5,
		"impulsePower",
		"Impulse power")
	oSet.options[#oSet.options + 1] = oSet.impulsePower	

	oSet.impulseRad = create_mode_option(
		option_type.numeric, 
		6,
		"impulseRad",
		"Impulse radius")
	oSet.options[#oSet.options + 1] = oSet.impulseRad	

	oSet.impulseTrials = create_mode_option(
		option_type.numeric, 
		100,
		"impulseTrials",
		"Nearest number of shapes to impulse per tick")
	oSet.options[#oSet.options + 1] = oSet.impulseTrials

	oSet.sparkTorusMag = create_mode_option(
		option_type.numeric, 
		0.8,
		"sparkTorusMag",
		"Fireball torus pressure magnitude per spark x 10^-4")
	oSet.options[#oSet.options + 1] = oSet.sparkTorusMag

	oSet.sparkVacuumMag = create_mode_option(
		option_type.numeric, 
		0.04,
		"sparkVacuumMag",
		"Fireball vacuum pressure magnitude per spark x 10^-4")
	oSet.options[#oSet.options + 1] = oSet.sparkVacuumMag

	oSet.sparkInflateMag = create_mode_option(
		option_type.numeric, 
		0.46,
		"sparkInflateMag",
		"Fireball inflation pressure magnitude per spark x 10^-4")
	oSet.options[#oSet.options + 1] = oSet.sparkInflateMag

	-- explosion character

	oSet.sparkFizzleFreq = create_mode_option(
		option_type.numeric, 
		15,
		"sparkFizzleFreq",
		"Spark fizzle frequency (1 = always, + for less frequent)")
	oSet.options[#oSet.options + 1] = oSet.sparkFizzleFreq	

	oSet.sparkSpawnsUpper = create_mode_option(
		option_type.numeric, 
		14,
		"sparkSpawnsUpper",
		"Spark spawns max")
	oSet.options[#oSet.options + 1] = oSet.sparkSpawnsUpper	

	oSet.sparkSpawnsLower = create_mode_option(
		option_type.numeric, 
		3,
		"sparkSpawnsLower",
		"Spark spawns min")
	oSet.options[#oSet.options + 1] = oSet.sparkSpawnsLower	

	oSet.sparkSplitFreqStart = create_mode_option(
		option_type.numeric, 
		10,
		"sparkSplitFreqStart",
		"Spark split frequency start (1 = always, + for less frequent)")
	oSet.options[#oSet.options + 1] = oSet.sparkSplitFreqStart	

	oSet.sparkSplitFreqEnd = create_mode_option(
		option_type.numeric, 
		300,
		"sparkSplitFreqEnd",
		"Spark split frequency end (1 = always, + for less frequent)")
	oSet.options[#oSet.options + 1] = oSet.sparkSplitFreqEnd	

	oSet.sparkSplitFreqInc = create_mode_option(
		option_type.numeric, 
		1,
		"sparkSplitFreqInc",
		"Spark split 1/freq increase")
	oSet.options[#oSet.options + 1] = oSet.sparkSplitFreqInc	

	oSet.sparkSplitDirVariation = create_mode_option(
		option_type.numeric, 
		0.8,
		"sparkSplitDirVariation",
		"Spark split dir variation")
	oSet.options[#oSet.options + 1] = oSet.sparkSplitDirVariation	

	oSet.sparkHitDirVariation = create_mode_option(
		option_type.numeric, 
		1,
		"sparkHitDirVariation",
		"Spark hit spawn dir variation")
	oSet.options[#oSet.options + 1] = oSet.sparkHitDirVariation	

	oSet.sparkHitFollowMaxSpeed = create_mode_option(
		option_type.numeric, 
		3,
		"sparkHitFollowMaxSpeed",
		"Hit following max spark speed")
	oSet.options[#oSet.options + 1] = oSet.sparkHitFollowMaxSpeed	

	oSet.sparkDeathSpeed = create_mode_option(
		option_type.numeric, 
		0.04,
		"sparkDeathSpeed",
		"Spark dead at speed")
	oSet.options[#oSet.options + 1] = oSet.sparkDeathSpeed	

	oSet.sparkSplitSpeed = create_mode_option(
		option_type.numeric, 
		0.6,
		"sparkSplitSpeed",
		"Spark speed at split")
	oSet.options[#oSet.options + 1] = oSet.sparkSplitSpeed	

	oSet.sparkSplitSpeedVariation = create_mode_option(
		option_type.numeric, 
		0.5,
		"sparkSplitSpeedVariation",
		"Spark split speed variation")
	oSet.options[#oSet.options + 1] = oSet.sparkSplitSpeedVariation	

	oSet.sparkSpeedReduction = create_mode_option(
		option_type.numeric, 
		0.5,
		"sparkSpeedReduction",
		"Spark speed reduction over time")
	oSet.options[#oSet.options + 1] = oSet.sparkSpeedReduction	
	
	oSet.sparkJitter = create_mode_option(
		option_type.numeric, 
		0.1,
		"sparkJitter",
		"Spark dir jitter")
	oSet.options[#oSet.options + 1] = oSet.sparkJitter	

-- aesthetics

	oSet.sparkPuffLife = create_mode_option(
		option_type.numeric, 
		1.5,
		"sparkPuffLife",
		"Spark puff particle life (glowing fire particles)")
	oSet.options[#oSet.options + 1] = oSet.sparkPuffLife	

	oSet.sparkSmokeLife = create_mode_option(
		option_type.numeric, 
		2,
		"sparkSmokeLife",
		"Spark smoke particle life (lingering dark particles)")
	oSet.options[#oSet.options + 1] = oSet.sparkSmokeLife	

	oSet.sparkTileRadMax = create_mode_option(
		option_type.numeric, 
		3,
		"sparkTileRadMax",
		"Spark size max")
	oSet.options[#oSet.options + 1] = oSet.sparkTileRadMax	

	oSet.sparkTileRadMin = create_mode_option(
		option_type.numeric, 
		2,
		"sparkTileRadMin",
		"Spark size min")
	oSet.options[#oSet.options + 1] = oSet.sparkTileRadMin	
	
	oSet.sparkSmokeTileSize = create_mode_option(
		option_type.numeric, 
		0.45,
		"sparkSmokeTileSize",
		"Spark smoke tile size")
	oSet.options[#oSet.options + 1] = oSet.sparkSmokeTileSize	

	oSet.sparkLightIntensity = create_mode_option(
		option_type.numeric, 
		3,
		"sparkLightIntensity",
		"Spark light intensity")
	oSet.options[#oSet.options + 1] = oSet.sparkLightIntensity	
	
    return oSet
end
