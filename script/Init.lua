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

	oSet.fireballDirection = create_mode_option(
		option_type.vec,
		Vec(0, 1, 0),
		"fireballDirection",
		"Fireball travel direction")
	oSet.options[#oSet.options + 1] = oSet.fireballDirection

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
		1000,
		"bombEnergy",
		"Bomb energy at detonation (affects lifespan)")
	oSet.options[#oSet.options + 1] = oSet.bombEnergy		

	oSet.bombSparks = create_mode_option(
		option_type.numeric, 
		600,
		"bombSparks",
		"Bomb sparks at detonation (affects size)")
	oSet.options[#oSet.options + 1] = oSet.bombSparks		
	
	oSet.detonationTrigger = create_mode_option(
		option_type.numeric, 
		100,
		"detonationTrigger",
		"Detonation trigger (Spark count. -1 for simultaneous explosions)")
	oSet.options[#oSet.options + 1] = oSet.detonationTrigger

	oSet.fireballSparksMax = create_mode_option(
		option_type.numeric, 
		400,
		"fireballSparksMax",
		"Maximum number of sparks per one fireball")
	oSet.options[#oSet.options + 1] = oSet.fireballSparksMax	

	oSet.fireballRadius = create_mode_option(
		option_type.numeric, 
		3,
		"fireballRadius",
		"Fireball radius (affects lumpiness)")
	oSet.options[#oSet.options + 1] = oSet.fireballRadius

	oSet.blastPowerPrimary = create_mode_option(
		option_type.numeric, 
		3,
		"blastPowerPrimary",
		"Blast power")
	oSet.options[#oSet.options + 1] = oSet.blastPowerPrimary

	oSet.blastSpeed = create_mode_option(
		option_type.numeric, 
		1,
		"blastSpeed",
		"Blast speed at detonation (affects size)")
	oSet.options[#oSet.options + 1] = oSet.blastSpeed	

	oSet.sparkHurt = create_mode_option(
		option_type.numeric, 
		0.01,
		"sparkHurt",
		"Player hurt threshold")
	oSet.options[#oSet.options + 1] = oSet.sparkHurt	

	oSet.sparkHoleVoxelsSoft = create_mode_option(
		option_type.numeric, 
		5,
		"sparkHoleVoxelsSoft",
		"Erosion, soft materials (number of voxel)")
	oSet.options[#oSet.options + 1] = oSet.sparkHoleVoxelsSoft

	oSet.sparkHoleVoxelsMedium = create_mode_option(
		option_type.numeric, 
		3,
		"sparkHoleVoxelsMedium",
		"Erosion, medium materials (number of voxel)")
	oSet.options[#oSet.options + 1] = oSet.sparkHoleVoxelsMedium

	oSet.sparkHoleVoxelsHard = create_mode_option(
		option_type.numeric, 
		1,
		"sparkHoleVoxelsHard",
		"Erosion, hard materials (number of voxel)")
	oSet.options[#oSet.options + 1] = oSet.sparkHoleVoxelsHard

	oSet.ignitionRadius = create_mode_option(
		option_type.numeric, 
		5,
		"ignitionRadius",
		"Fire ignition and player hurt radius")
	oSet.options[#oSet.options + 1] = oSet.ignitionRadius	

	oSet.ignitionFreq = create_mode_option(
		option_type.numeric, 
		10,
		"ignitionFreq",
		"First ignition frequency (1 = every hit, + for less frequent)")
	oSet.options[#oSet.options + 1] = oSet.ignitionFreq

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
		1,
		"sparkTorusMag",
		"Fireball torus pressure magnitude per spark x 10^-4")
	oSet.options[#oSet.options + 1] = oSet.sparkTorusMag

	oSet.sparkVacuumMag = create_mode_option(
		option_type.numeric, 
		0.03,
		"sparkVacuumMag",
		"Fireball vacuum pressure magnitude per spark x 10^-4")
	oSet.options[#oSet.options + 1] = oSet.sparkVacuumMag

	oSet.sparkInflateMag = create_mode_option(
		option_type.numeric, 
		0.5,
		"sparkInflateMag",
		"Fireball inflation pressure magnitude per spark x 10^-4")
	oSet.options[#oSet.options + 1] = oSet.sparkInflateMag

	-- explosion character

	oSet.sparkFizzleFreq = create_mode_option(
		option_type.numeric, 
		8,
		"sparkFizzleFreq",
		"Fizzle frequency (1 = always, + for less frequent)")
	oSet.options[#oSet.options + 1] = oSet.sparkFizzleFreq	

	oSet.sparkSpawnsUpper = create_mode_option(
		option_type.numeric, 
		14,
		"sparkSpawnsUpper",
		"Spawns max")
	oSet.options[#oSet.options + 1] = oSet.sparkSpawnsUpper	

	oSet.sparkSpawnsLower = create_mode_option(
		option_type.numeric, 
		3,
		"sparkSpawnsLower",
		"Spawns min")
	oSet.options[#oSet.options + 1] = oSet.sparkSpawnsLower	

	oSet.sparkSplitFreqStart = create_mode_option(
		option_type.numeric, 
		10,
		"sparkSplitFreqStart",
		"Split frequency start (1 = always, + for less frequent)")
	oSet.options[#oSet.options + 1] = oSet.sparkSplitFreqStart	

	oSet.sparkSplitFreqEnd = create_mode_option(
		option_type.numeric, 
		100,
		"sparkSplitFreqEnd",
		"Split frequency end (1 = always, + for less frequent)")
	oSet.options[#oSet.options + 1] = oSet.sparkSplitFreqEnd	

	oSet.sparkSplitFreqInc = create_mode_option(
		option_type.numeric, 
		1,
		"sparkSplitFreqInc",
		"Split 1/freq increase")
	oSet.options[#oSet.options + 1] = oSet.sparkSplitFreqInc	

	oSet.sparkSplitDirVariation = create_mode_option(
		option_type.numeric, 
		0.8,
		"sparkSplitDirVariation",
		"Split dir variation")
	oSet.options[#oSet.options + 1] = oSet.sparkSplitDirVariation	

	oSet.sparkHitFollowMaxSpeed = create_mode_option(
		option_type.numeric, 
		2,
		"sparkHitFollowMaxSpeed",
		"Hit following max spark speed")
	oSet.options[#oSet.options + 1] = oSet.sparkHitFollowMaxSpeed	

	oSet.sparkDeathSpeed = create_mode_option(
		option_type.numeric, 
		0.02,
		"sparkDeathSpeed",
		"Death speed")
	oSet.options[#oSet.options + 1] = oSet.sparkDeathSpeed	

	oSet.sparkSplitSpeed = create_mode_option(
		option_type.numeric, 
		0.5,
		"sparkSplitSpeed",
		"Split speed")
	oSet.options[#oSet.options + 1] = oSet.sparkSplitSpeed	

	oSet.sparkSplitSpeedVariation = create_mode_option(
		option_type.numeric, 
		0.1,
		"sparkSplitSpeedVariation",
		"Split speed variation")
	oSet.options[#oSet.options + 1] = oSet.sparkSplitSpeedVariation	

	oSet.sparkSpeedReduction = create_mode_option(
		option_type.numeric, 
		0.5,
		"sparkSpeedReduction",
		"Speed reduction over time")
	oSet.options[#oSet.options + 1] = oSet.sparkSpeedReduction	
	
-- aesthetics

	oSet.sparkPuffLife = create_mode_option(
		option_type.numeric, 
		1.5,
		"sparkPuffLife",
		"Spark puff particle life (glowing fire particles)")
	oSet.options[#oSet.options + 1] = oSet.sparkPuffLife	

	oSet.sparkSmokeLife = create_mode_option(
		option_type.numeric, 
		1.5,
		"sparkSmokeLife",
		"Smoke particle life (lingering dark particles)")
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
		"Smoke tile size")
	oSet.options[#oSet.options + 1] = oSet.sparkSmokeTileSize	

	oSet.sparkLightIntensity = create_mode_option(
		option_type.numeric, 
		3,
		"sparkLightIntensity",
		"Spark light intensity")
	oSet.options[#oSet.options + 1] = oSet.sparkLightIntensity	
	
	-- jet options

	oSet.jetSpeed = create_mode_option(
		option_type.numeric, 
		0.3,
		"jetSpeed",
		"Jet mode speed at activation (affects jet plume)")
	oSet.options[#oSet.options + 1] = oSet.jetSpeed	

	oSet.jetFireballSparksMax = create_mode_option(
		option_type.numeric, 
		200,
		"jetFireballSparksMax",
		"Maximum number of sparks in a fireball in jet mode.")
	oSet.options[#oSet.options + 1] = oSet.jetFireballSparksMax	

	oSet.jetFireballRadius = create_mode_option(
		option_type.numeric, 
		1.5,
		"jetFireballRadius",
		"Jet mode fireball radius")
	oSet.options[#oSet.options + 1] = oSet.jetFireballRadius	

	oSet.jetFizzleFreq = create_mode_option(
		option_type.numeric, 
		5,
		"jetFizzleFreq",
		"Jet fizzle frequency (1 = always, + for less frequent)")
	oSet.options[#oSet.options + 1] = oSet.jetFizzleFreq	

	oSet.jetSplitSpeed = create_mode_option(
		option_type.numeric, 
		0.5,
		"jetSplitSpeed",
		"Jet mode split speed (affects speed of jet)")
	oSet.options[#oSet.options + 1] = oSet.jetSplitSpeed	

	oSet.jetTorusMag = create_mode_option(
		option_type.numeric, 
		5.5,
		"jetTorusMag",
		"Jet mode fireball torus pressure magnitude per spark x 10^-4")
	oSet.options[#oSet.options + 1] = oSet.jetTorusMag

	oSet.jetVacuumMag = create_mode_option(
		option_type.numeric, 
		0.02,
		"jetVacuumMag",
		"Jet mode fireball vacuum pressure magnitude per spark x 10^-4")
	oSet.options[#oSet.options + 1] = oSet.jetVacuumMag

	oSet.jetInflateMag = create_mode_option(
		option_type.numeric, 
		0.5,
		"jetInflateMag",
		"Jet mode fireball inflation pressure magnitude per spark x 10^-4")
	oSet.options[#oSet.options + 1] = oSet.jetInflateMag

    return oSet
end
