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
		800,
		"sparksSimulation",
		"Sparks simulation, all fireballs together")
	oSet.options[#oSet.options + 1] = oSet.sparksSimulation	

	oSet.detonationTrigger = create_mode_option(
		option_type.numeric, 
		400,
		"detonationTrigger",
		"Number of sparks in simulation when next detonation occurs")
	oSet.options[#oSet.options + 1] = oSet.detonationTrigger	

	-- blast effects

	oSet.sparksPerExplosionMin = create_mode_option(
		option_type.numeric, 
		600,
		"sparksPerExplosionMin",
		"Sparks created at detonation, minimum")
	oSet.options[#oSet.options + 1] = oSet.sparksPerExplosionMin		

	oSet.sparksPerExplosionMax = create_mode_option(
		option_type.numeric, 
		800,
		"sparksPerExplosionMax",
		"Sparks created at detonation, maximum")
	oSet.options[#oSet.options + 1] = oSet.sparksPerExplosionMax	

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
		5,
		"fireballRadius",
		"Fireball radius (Distance between sparks before they're assigned a different torus)")
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
		"Blast speed at detonation (+ for wider initial fireball)")
	oSet.options[#oSet.options + 1] = oSet.blastSpeed	

	oSet.sparkHurt = create_mode_option(
		option_type.numeric, 
		0.01,
		"sparkHurt",
		"Spark player hurt factor")
	oSet.options[#oSet.options + 1] = oSet.sparkHurt	

	oSet.sparkHoleSoftRad = create_mode_option(
		option_type.numeric, 
		0.5,
		"sparkHoleSoftRad",
		"Spark hole radius, soft materials")
	oSet.options[#oSet.options + 1] = oSet.sparkHoleSoftRad

	oSet.sparkHoleMediumRad = create_mode_option(
		option_type.numeric, 
		0.3,
		"sparkHoleMediumRad",
		"Spark hole radius, medium materials")
	oSet.options[#oSet.options + 1] = oSet.sparkHoleMediumRad

	oSet.sparkHoleHardRad = create_mode_option(
		option_type.numeric, 
		0.1,
		"sparkHoleHardRad",
		"Spark hole radius, hard materials")
	oSet.options[#oSet.options + 1] = oSet.sparkHoleHardRad

	oSet.ignitionRadius = create_mode_option(
		option_type.numeric, 
		5,
		"ignitionRadius",
		"Fire ignition and player hurt radius")
	oSet.options[#oSet.options + 1] = oSet.ignitionRadius	

	oSet.ignitionProbes = create_mode_option(
		option_type.numeric, 
		10,
		"ignitionProbes",
		"Ignition raycasts per spark per explosion per tick")
	oSet.options[#oSet.options + 1] = oSet.ignitionProbes

	oSet.ignitionCount = create_mode_option(
		option_type.numeric, 
		1,
		"ignitionCount",
		"Ignitions from secondary raycasts on hit")
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

	oSet.impulseFreq = create_mode_option(
		option_type.numeric, 
		200,
		"impulseFreq",
		"Impulse frequency (1 = always, + for less frequent)")
	oSet.options[#oSet.options + 1] = oSet.impulseFreq	

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
		"Cloud torus pressure magnitude per spark x 10^-4")
	oSet.options[#oSet.options + 1] = oSet.sparkTorusMag

	oSet.sparkVacuumMag = create_mode_option(
		option_type.numeric, 
		0.04,
		"sparkVacuumMag",
		"Cloud vacuum pressure magnitude per spark x 10^-4")
	oSet.options[#oSet.options + 1] = oSet.sparkVacuumMag

	oSet.sparkInflateMag = create_mode_option(
		option_type.numeric, 
		0.46,
		"sparkInflateMag",
		"Cloud inflation pressure magnitude per spark x 10^-4")
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

	oSet.sparkBlastPushAmount = create_mode_option(
		option_type.numeric, 
		0.5,
		"sparkBlastPushAmount",
		"Max blast speed transfer to existing sparks (multiple at nearest)")
	oSet.options[#oSet.options + 1] = oSet.sparkBlastPushAmount	

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
		"Spark radius hot")
	oSet.options[#oSet.options + 1] = oSet.sparkTileRadMax	

	oSet.sparkSmokeTileRadius = create_mode_option(
		option_type.numeric, 
		0.45,
		"sparkSmokeTileRadius",
		"Spark smoke tile radius")
	oSet.options[#oSet.options + 1] = oSet.sparkSmokeTileRadius	

	oSet.sparkTileRadMin = create_mode_option(
		option_type.numeric, 
		2,
		"sparkTileRadMin",
		"Spark radius cool")
	oSet.options[#oSet.options + 1] = oSet.sparkTileRadMin	

	oSet.sparkLightIntensity = create_mode_option(
		option_type.numeric, 
		3,
		"sparkLightIntensity",
		"Spark light intensity")
	oSet.options[#oSet.options + 1] = oSet.sparkLightIntensity	
	
    return oSet
end
