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

	oSet.ashColor = create_mode_option(
		option_type.color,
		Vec(0, 0, 0.3),
		"ashColor",
		"Ash color")
	oSet.options[#oSet.options + 1] = oSet.ashColor

	-- simulation

	oSet.sparksSimulation = create_mode_option(
		option_type.numeric, 
		2000,
		"sparksSimulation",
		"Sparks entire simulation")
	oSet.options[#oSet.options + 1] = oSet.sparksSimulation	

	oSet.sparkSimSpace = create_mode_option(
		option_type.numeric, 
		1900,
		"sparkSimSpace",
		"Sim space requried to trigger next explosion")
	oSet.options[#oSet.options + 1] = oSet.sparkSimSpace	

	oSet.ashTickLimit = create_mode_option(
		option_type.numeric, 
		10,
		"ashTickLimit",
		"Max ash particles per tick")
	oSet.options[#oSet.options + 1] = oSet.ashTickLimit

	oSet.ignitionTickLimit = create_mode_option(
		option_type.numeric, 
		20,
		"ignitionTickLimit",
		"Max fire ignitions per tick")
	oSet.options[#oSet.options + 1] = oSet.ignitionTickLimit	


	-- blast effects

	oSet.sparksPerExplosion = create_mode_option(
		option_type.numeric, 
		500,
		"sparksPerExplosion",
		"Sparks limit per explosion")
	oSet.options[#oSet.options + 1] = oSet.sparksPerExplosion		
	
	oSet.sparksAtDetonation = create_mode_option(
		option_type.numeric, 
		400,
		"sparksAtDetonation",
		"Sparks at detonation")
	oSet.options[#oSet.options + 1] = oSet.sparksAtDetonation
	
	oSet.blastPowerPrimary = create_mode_option(
		option_type.numeric, 
		3,
		"blastPowerPrimary",
		"Blast power")
	oSet.options[#oSet.options + 1] = oSet.blastPowerPrimary

	oSet.blastSpeed = create_mode_option(
		option_type.numeric, 
		3,
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
		"Spark flame ignition raycasts")
	oSet.options[#oSet.options + 1] = oSet.ignitionProbes

	oSet.ignitionCount = create_mode_option(
		option_type.numeric, 
		4,
		"ignitionCount",
		"Spark flame ignition secondary raycasts on hit")
	oSet.options[#oSet.options + 1] = oSet.ignitionCount

	oSet.impulsePower = create_mode_option(
		option_type.numeric, 
		-5,
		"impulsePower",
		"impulse power")
	oSet.options[#oSet.options + 1] = oSet.impulsePower	

	oSet.impulseRad = create_mode_option(
		option_type.numeric, 
		6,
		"impulseRad",
		"impulse radius")
	oSet.options[#oSet.options + 1] = oSet.impulseRad	

	oSet.impulseFreq = create_mode_option(
		option_type.numeric, 
		200,
		"impulseFreq",
		"impulse frequency (1 = always, + for less frequent)")
	oSet.options[#oSet.options + 1] = oSet.impulseFreq	

	oSet.impulseTrials = create_mode_option(
		option_type.numeric, 
		100,
		"impulseTrials",
		"Nearest number of shapes to impulse per tick")
	oSet.options[#oSet.options + 1] = oSet.impulseTrials

	-- explosion character

	oSet.sparkFizzleFreq = create_mode_option(
		option_type.numeric, 
		14,
		"sparkFizzleFreq",
		"Spark fizzle frequency (1 = always, + for less frequent)")
	oSet.options[#oSet.options + 1] = oSet.sparkFizzleFreq	
	
	oSet.sparkSpawnsUpper = create_mode_option(
		option_type.numeric, 
		15,
		"sparkSpawnsUpper",
		"Spark spawns max")
	oSet.options[#oSet.options + 1] = oSet.sparkSpawnsUpper	

	oSet.sparkSpawnsLower = create_mode_option(
		option_type.numeric, 
		2,
		"sparkSpawnsLower",
		"Spark spawns min")
	oSet.options[#oSet.options + 1] = oSet.sparkSpawnsLower	

	oSet.sparkSplitFreqStart = create_mode_option(
		option_type.numeric, 
		8,
		"sparkSplitFreqStart",
		"Spark split frequency start (1 = always, + for less frequent)")
	oSet.options[#oSet.options + 1] = oSet.sparkSplitFreqStart	

	oSet.sparkSplitFreqEnd = create_mode_option(
		option_type.numeric, 
		130,
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
		0.5,
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
		0.005,
		"sparkDeathSpeed",
		"Spark dead at speed")
	oSet.options[#oSet.options + 1] = oSet.sparkDeathSpeed	

	oSet.sparkSplitSpeed = create_mode_option(
		option_type.numeric, 
		0.4,
		"sparkSplitSpeed",
		"Spark speed at split")
	oSet.options[#oSet.options + 1] = oSet.sparkSplitSpeed	

	oSet.sparkSplitSpeedVariation = create_mode_option(
		option_type.numeric, 
		0.01,
		"sparkSplitSpeedVariation",
		"Spark split speed variation")
	oSet.options[#oSet.options + 1] = oSet.sparkSplitSpeedVariation	

	oSet.sparkSpeedReduction = create_mode_option(
		option_type.numeric, 
		0.4,
		"sparkSpeedReduction",
		"Spark speed reduction over time")
	oSet.options[#oSet.options + 1] = oSet.sparkSpeedReduction	

	oSet.sparkAttraction = create_mode_option(
		option_type.numeric, 
		0.03,
		"sparkAttraction",
		"Attraction magnitude of one spark on the simulation")
	oSet.options[#oSet.options + 1] = oSet.sparkAttraction	

	oSet.sparkAttractionRadius = create_mode_option(
		option_type.numeric, 
		6,
		"sparkAttractionRadius",
		"Attraction radius of one spark on the simulation")
		oSet.options[#oSet.options + 1] = oSet.sparkAttractionRadius	
		
	oSet.heatRiseForceAmount = create_mode_option(
		option_type.numeric, 
		0.3,
		"heatRiseForceAmount",
		"Heat rise force, multiple of attraction magnitude force")
	oSet.options[#oSet.options + 1] = oSet.heatRiseForceAmount	

	oSet.sparkJiggle = create_mode_option(
		option_type.numeric, 
		0.05,
		"sparkJiggle",
		"Spark dir jitter")
	oSet.options[#oSet.options + 1] = oSet.sparkJiggle	

	oSet.sparkBlastPushAmount = create_mode_option(
		option_type.numeric, 
		0.5,
		"sparkBlastPushAmount",
		"Max blast speed transfer to existing sparks (multiple at nearest)")
	oSet.options[#oSet.options + 1] = oSet.sparkBlastPushAmount	

	oSet.sparkBlastPushRadius = create_mode_option(
		option_type.numeric, 
		5,
		"sparkBlastPushRadius",
		"Max radius sparks are pushed by other blasts")
	oSet.options[#oSet.options + 1] = oSet.sparkBlastPushRadius	


-- aesthetics

	oSet.sparkSmokeLife = create_mode_option(
		option_type.numeric, 
		3,
		"sparkSmokeLife",
		"Spark smoke life")
	oSet.options[#oSet.options + 1] = oSet.sparkSmokeLife	

	oSet.sparkTileRadMax = create_mode_option(
		option_type.numeric, 
		3.5,
		"sparkTileRadMax",
		"Spark radius hot")
	oSet.options[#oSet.options + 1] = oSet.sparkTileRadMax	

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

	oSet.ashMaxLife = create_mode_option(
		option_type.numeric, 
		3,
		"ashMaxLife",
		"Ash max lifetime (secs)")
	oSet.options[#oSet.options + 1] = oSet.ashMaxLife		

	oSet.ashMaxSpeed = create_mode_option(
		option_type.numeric, 
		2,
		"ashMaxSpeed",
		"Ash max speed (m/s)")
	oSet.options[#oSet.options + 1] = oSet.ashMaxSpeed	

	oSet.ashTileRadius = create_mode_option(
		option_type.numeric, 
		0.3,
		"ashTileRadius",
		"Ash tile radius (m)")
	oSet.options[#oSet.options + 1] = oSet.ashTileRadius	

	oSet.ashGravity = create_mode_option(
		option_type.numeric, 
		0,
		"ashGravity",
		"Ash gravity (m/s/s)")
	oSet.options[#oSet.options + 1] = oSet.ashGravity	

	oSet.ashDrag = create_mode_option(
		option_type.numeric, 
		0,
		"ashDrag",
		"Ash drag")
	oSet.options[#oSet.options + 1] = oSet.ashDrag	

	oSet.ashMinDist = create_mode_option(
		option_type.numeric, 
		1,
		"ashMinDist",
		"Ash min distance from spark to spawn")
	oSet.options[#oSet.options + 1] = oSet.ashMinDist	

	oSet.ashProbes = create_mode_option(
		option_type.numeric, 
		50,
		"ashProbes",
		"Ash raycast trials for group spawn")
	oSet.options[#oSet.options + 1] = oSet.ashProbes

	oSet.ashSpawns = create_mode_option(
		option_type.numeric, 
		8,
		"ashSpawns",
		"Ash spawns on successful raycast")
	oSet.options[#oSet.options + 1] = oSet.ashSpawns

	oSet.ashSpawnJitter = create_mode_option(
		option_type.numeric, 
		1,
		"ashSpawnJitter",
		"Ash spawn position jitter")
	oSet.options[#oSet.options + 1] = oSet.ashSpawnJitter

	oSet.smokeFreq = create_mode_option(
		option_type.numeric, 
		10,
		"smokeFreq",
		"Smoke partical frequency (1 = always, + for less frequent)")
	oSet.options[#oSet.options + 1] = oSet.smokeFreq	

    return oSet
end
