#include "Utils.lua"
#include "Types.lua"
#include "Defs.lua"
#include "HSVRGB.lua"

boomSound = LoadSound("MOD/snd/toiletBoom.ogg")
rumbleSound = LoadSound("MOD/snd/rumble.ogg")
bombs = {}
toDetonate = {}
rushDetonate = false
blastEffectOrigin = nil


function explosionTick(dt)
	local totalSparkNum = totalSparks()
	local stillAlive = {}
	for i=1, #bombs do
		local bomb = bombs[i]
		if IsShapeBroken(bomb) then
			table.insert(toDetonate, bomb)
		else
			table.insert(stillAlive, bomb)
		end
	end
	bombs = stillAlive
	
	detonationTick(dt)
	
	local newExplosions = {}
	for e= 1, #explosions do 
		local explosion = explosions[e]
		local positions = {}
		local dirs = {}
		local dists = {}
		local newSparks = {}
		local sparkSpeeds = {}
		for s = 1, #explosion.sparks do
			-- evolve the spark if it hasn't fizzled randomly
			-- Fizzling verses splitting is what mostly determines the
			-- length of the explosion.
			local spark = explosion.sparks[s]
			local forceSplit = false
			local hitPoint = nil
			local hit, dist, normal, shape = QueryRaycast(spark.pos, spark.dir, spark.speed + 0.1, 0.025)
			local sparkStillAlive = true
			local chance = TOOL.sparkFizzleFreq.value
			-- the sparks further away from the center of the cloud will die out
			-- faster than the closer ones
			local distance = VecLength(VecSub(explosion.center, spark.pos))
			local distance_n = math.min((1 + TOOL.sparkFizzleFalloffRadius.value)/(1 + distance), 1) ^ 0.5 
			chance = math.max(math.ceil(chance * distance_n), 1)
			if math.random(1, chance) == 1 then
				-- fizzle
				sparkStillAlive = false
			elseif hit then

				-- make hole
				MakeHole(spark.pos, TOOL.sparkHoleSoftRad.value, TOOL.sparkHoleMediumRad.value, TOOL.sparkHoleHardRad.value)

				-- hit following
				local body = GetShapeBody(shape)
				if body ~= nil then 
					local velocity = GetProperty(body, "velocity")
					if VecLength(velocity) < TOOL.sparkDeathSpeed.value then 
						-- stationary object or it slowed down too much
						spark.dir = VecScale(spark.dir, -1)
						forceSplit = true
					else
						-- moving object, match the speed plus a little
						local maxSpeedProperty = TOOL.sparkHitFollowMaxSpeed or TOOL.blastSpeed 
						local newSpeed = math.min(VecLength(velocity) + 0.1, maxSpeedProperty.value)
						spark.dir = VecNormalize(velocity)
						spark.speed = newSpeed
						forceSplit = true
					end
				else
					-- shape had no body
					spark.dir = VecScale(spark.dir, -1)
				end
			else
				-- other explosion shocks
				spark.dir = VecAdd(spark.dir, random_vec(TOOL.sparkJiggle.value))
				if blastEffectOrigin ~= nil then
					pushSparkFromOrigin(spark, 
					blastEffectOrigin, 
					TOOL.sparkBlastPushRadius.value, 
					TOOL.blastSpeed.value,
					0.5) 
				end

				spark.dir = VecNormalize(spark.dir)
				spark.speed = math.max(spark.speed * (1 - TOOL.sparkSpeedReduction.value), TOOL.sparkDeathSpeed.value)

				-- pressure effects. 
				-- Torus effects - Pulling from behind the cloud and pushing from the front

				local deltaFromOrigin = VecSub(spark.pos, explosion.center)
				local distFromOrigin = VecLength(deltaFromOrigin)
				table.insert(dists, distFromOrigin)
				local distance_n = math.min(1, 1/(1 + distFromOrigin)) * 0.5
				-- positive if behind the origin
				local inverseDelta = VecScale(deltaFromOrigin, -1)
				local lookOriginDir = VecNormalize(inverseDelta)
				local angleDot_n = VecDot(lookOriginDir, Vec(0,1,0))
				local torus_n = distance_n * angleDot_n
				local torus_mag = TOOL.sparkTorusMag.value * #explosion.sparks * torus_n
				local torus_vector = VecScale(lookOriginDir, torus_mag)
				-- DebugLine(spark.pos, VecScale(VecAdd(spark.pos, torus_vector), 1))
				pushSparkUniform(spark, torus_vector)

				-- pulling into the center
				local vacuum_mag = TOOL.sparkVacuumMag.value * #explosion.sparks * distance_n
				local vacuum_vector = VecScale(lookOriginDir, vacuum_mag)
				pushSparkUniform(spark, vacuum_vector)

				-- pushing out
				local inflate_mag = TOOL.sparkInflateMag.value * #explosion.sparks * distance_n * -1
				local inflate_vector = VecScale(lookOriginDir, inflate_mag)
				pushSparkUniform(spark, inflate_vector)


				spark.pos = VecAdd(spark.pos, VecScale(spark.dir, spark.speed))
	
				-- splitting into new sparks
				if math.random(1, explosion.splitFreq) == 1 or forceSplit then
					for i=1, math.random(TOOL.sparkSpawnsLower.value, TOOL.sparkSpawnsUpper.value) do
						if totalSparkNum <= TOOL.sparksSimulation.value and
						spark.splitsRemaining ~= 0 and
						#explosion.sparks < TOOL.sparksPerExplosion.value then
							local newDir = VecAdd(spark.dir, random_vec(TOOL.sparkSplitDirVariation.value))
							newDir = VecNormalize(newDir)
							local newSpark = createSparkInst(spark.options, 
							spark.pos, 
							newDir, 
							vary_by_percentage(TOOL.sparkSplitSpeed.value, TOOL.sparkSplitSpeedVariation.value))
							table.insert(newSparks, newSpark)
						end
					end
				end
			end
			
			if sparkStillAlive then
				makeSparkEffect(spark.pos, {color=spark.sparkColor, smokeSize=0.5})
				table.insert(newSparks, spark)
				table.insert(sparkSpeeds, spark.speed)
				table.insert(positions, spark.pos)
				table.insert(dirs, spark.dir)

				-- hurt the player if too close
				local player_pos = GetPlayerTransform().pos
				local dist = VecLength(VecSub(player_pos, spark.pos))
				local dist_n = dist / TOOL.ignitionRadius.value
				local hurt_n = 1 - math.min(1, dist_n) ^ 0.5
				if hurt_n > TOOL.sparkHurt.value then
					local health = GetPlayerHealth()
					SetPlayerHealth(health - (hurt_n * VALUES.SPARK_HURT_ADJUSTMENT))
				end
			end
		end

		-- spawn fire and ash
		for probe=1, TOOL.ignitionProbes.value * #explosion.sparks do
			local ign_probe_dir = random_vec(1)
			local ign_probe_hit, ign_probe_dist = QueryRaycast(explosion.center, ign_probe_dir, rad)
			if ign_probe_hit then 
				local ign_probe_pos = VecAdd(explosion.center, VecScale(ign_probe_dir, ign_probe_dist))
				SpawnFire(ign_probe_pos)
				for ign=1, TOOL.ignitionCount.value do
					local ign_dir = random_vec(1)
					local ign_hit, ign_dist = QueryRaycast(ign_probe_pos, ign_dir, rad)
					if ign_hit then 
						local ign_pos = VecAdd(ign_probe_pos, VecScale(ign_dir, ign_dist))
						SpawnFire(ign_pos) 
					end
				end
			end
		end

		-- create ash
		for p=1, TOOL.ashProbes.value do
			local ash_probe_dir = random_vec(1)
			local ash_hit, ash_dist = QueryRaycast(explosion.center, ash_probe_dir, TOOL.ashRadius.value)
			if ash_hit and ash_dist >= TOOL.ashMinDist.value then
				local ash_pos = VecAdd(explosion.center, VecScale(ash_probe_dir, ash_dist))
				local ash_dir = VecNormalize(VecSub(explosion.center, ash_pos))
				local dist_n = 1 - (math.min(1, ash_dist/TOOL.ashRadius.value) ^ 0.5)
				local ash_movement=VecScale(ash_dir, TOOL.ashMaxSpeed.value * dist_n)
				for ash=1, TOOL.ashSpawns.value do
					makeSmoke(VecAdd(ash_pos, random_vec(TOOL.ashSpawnJitter.value)), {
						smokeColor = HSVToRGB(TOOL.ashColor.value), 
						smokeSize = TOOL.ashTileRadius.value, 
						smokeLife = TOOL.ashMaxLife.value, 
						gravity = TOOL.ashGravity.value,
						drag = TOOL.ashDrag.value, 
						smokeMovement=ash_movement, 
						alphaStart=1, 
						alphaEnd=0.2,
						alphaFadeIn=0.5,
						alphaFadeOut=0.5})
				end
			end
		end

		if #newSparks > 0 then
			explosion.sparks = newSparks
			explosion.life_n = bracket_value(#explosion.sparks / TOOL.sparksPerExplosion.value, 1, 0)
			explosion.center = average_vec(positions)
			explosion.averageDist = 0
			for j=1, #dists do
				explosion.averageDist = explosion.averageDist + dists[j]
			end
			explosion.averageDist = explosion.averageDist / #dists
			explosion.dir = VecNormalize(average_vec(dirs))

			-- -- heat rise effect. Move the center up 
			-- local SPARK_HEAT_CONTRIBUTION = 0.001
			-- -- local SPARK_HEAT_FALLOFF_RAD = 1
			-- -- local HEAT_EXPONENT = 1
			-- -- local heat_n = math.min(1, (1 + SPARK_HEAT_FALLOFF_RAD)/(1 + explosion.averageDist)) ^ HEAT_EXPONENT
			-- local heat_mag = SPARK_HEAT_CONTRIBUTION * #explosion.sparks -- * heat_n
			-- explosion.center = VecAdd(explosion.center, Vec(0, heat_mag, 0))

			table.insert(newExplosions, explosion)
		end
		explosion.splitFreq = math.floor(math.min(explosion.splitFreq + TOOL.sparkSplitFreqInc.value, TOOL.sparkSplitFreqEnd.value))
	end

	impulseTick()
	explosions = newExplosions

end

function pushSparkFromOrigin(spark, origin, radius, maxAmount, falloffExponent)
	local distance = VecLength(VecSub(origin, spark.pos))
	if distance < radius and distance > 0 then 
		local effect_n = (1 - (distance / radius)) ^ falloffExponent
		local effectVector = VecScale(VecNormalize(VecSub(spark.pos, origin)), maxAmount * effect_n)
		pushSparkUniform(spark, effectVector)
	end
end

function pushSparkUniform(spark, effectVector)
	local sparkVector = VecScale(spark.dir, spark.speed)
	local newSparkVector = VecAdd(sparkVector, effectVector)
	spark.dir = VecNormalize(newSparkVector)
	spark.speed = VecLength(newSparkVector)
end

function detonationTick(dt)
	blastEffectOrigin = nil
	if rushDetonate == false then 
		local totalSparkCount = totalSparks()
		local simSpace = TOOL.sparksSimulation.value - totalSparkCount
		if simSpace < TOOL.sparkSimSpace.value then 
			return
		end
	else
		rushDetonate = false
	end
	local newDetonate = {}
	for i=1, #toDetonate do
		local bomb = toDetonate[i]
		if i == 1 then 
			detonate(bomb)
		else
			table.insert(newDetonate, bomb)
		end
	end
	toDetonate = {}
	for i=0, #newDetonate do
		table.insert(toDetonate, newDetonate[i])
	end
end

function detonateAll()
	if #bombs == 0 then 
		rushDetonate = true
	else
		for i=1, #bombs do
			local bomb = bombs[i]
			table.insert(toDetonate, bomb)
		end
	end
	bombs = {}
end

function detonate(bomb)
	local position = get_shape_center(bomb)
	createExplosion(position)
	Explosion(position, TOOL.blastPowerPrimary.value)
	PlaySound(boomSound, position, 5)
	PlaySound(rumbleSound, position, 5)
	if blastEffectOrigin == nil then 
		blastEffectOrigin = position
	else
		blastEffectOrigin = VecLerp(blastEffectOrigin, position)
	end
end

function createExplosion(pos)
	local explosion = createExplosionInst(TOOL)
	for a = 1, TOOL.sparksAtDetonation.value do
		local newSpark = createSparkInst(TOOL, 
		VecAdd(pos, random_vec(0.1)), 
		VecNormalize(random_vec(1)), 
		math.random(1, TOOL.blastSpeed.value))
		table.insert(explosion.sparks, newSpark)
	end
	table.insert(explosions, explosion)
end

function impulseTick()
	-- impulse the closest 100 shapes
	for e=1, #explosions do
		local explosion = explosions[e]
		local shapesFilter = {}
		for i=1, TOOL.impulseTrials.value do
			QueryRejectShapes(shapesFilter)
			local imp_hit, imp_pos, imp_normal, imp_shape = QueryClosestPoint(explosion.center, TOOL.impulseRad.value)
			if imp_hit == false then 
				break
			end
			table.insert(shapesFilter, imp_shape)
			local imp_body = GetShapeBody(imp_shape)
			if imp_body ~= nil then 
				local imp_delta = VecSub(imp_pos, explosion.center)
				local imp_delta_mag = VecLength(imp_delta)
				if imp_delta_mag <= TOOL.impulseRad.value then 
					local imp_dir = VecNormalize(imp_delta)
					local imp_n = 1 - bracket_value(imp_delta_mag/TOOL.impulseRad.value, 1, 0)
					local impulse_mag = imp_n * TOOL.impulsePower.value * #explosion.sparks * VALUES.SUCTION_IMPULSE_ADJUSTMENT
					local impulse = VecScale(imp_dir, impulse_mag)
					ApplyBodyImpulse(imp_body, GetBodyCenterOfMass(imp_body), impulse)
				end
			end
		end
	end
end

function makeSparkEffect(pos, options)
	options = options or {}
	local movement = random_vec(1)
	local gravity = options.gravity or 0
	local colorHSV = options.color or TOOL.sparkColor.value
	local color = HSVToRGB(colorHSV)
	local intensity = TOOL.sparkLightIntensity.value
	local lifetime = TOOL.sparkSmokeLife.value
	local puffColor = HSVToRGB(VALUES.DEFAULT_PUFF_COLOR)
	PointLight(pos, color[1], color[2], color[3], intensity)

	-- fire puff
	ParticleReset()
	ParticleType("smoke")
	ParticleTile(0)
	ParticleRotation(((math.random() * 2) - 1) * 10)
	ParticleDrag(0.25)
	ParticleAlpha(1, 0, "easeout", 0, 0.5)
	ParticleRadius(math.random(TOOL.sparkTileRadMin.value, TOOL.sparkTileRadMax.value) * 0.1)
	ParticleColor(puffColor[1], puffColor[2], puffColor[3])
	ParticleGravity(gravity)
	SpawnParticle(pos, movement, lifetime)

	if math.random(1, TOOL.smokeFreq.value) == 1 then 
		options.smokeColor = HSVToRGB(VALUES.DEFAULT_SMOKE_COLOR)
		options.smokeColor = HSVToRGB(TOOL.smokeColor.value)
		makeSmoke(pos, options)
	end
end

function makeSmoke(pos, options)
	local movement = options.smokeMovement or random_vec(1)
	local lifetime = TOOL.sparkSmokeLife.value
	local gravity = options.gravity or 1
	local smokeSize = options.smokeSize or math.random(2,5) * 0.1
	local smokeColor = options.smokeColor or HSVToRGB(VALUES.DEFAULT_SMOKE_COLOR)
	local alphaStart = options.alphaStart or 0
	local alphaEnd = options.alphaEnd or 0.8
	local alphaGraph = options.alphaFunction or "easeout"
	local alphaFadeIn = options.alphaFadeIn or 0
	local alphaFadeOut = options.alphaFadeOut or 1
	local drag = options.drag or 0.5

	-- smoke puff
	ParticleReset()
	ParticleType("smoke")
	ParticleTile(0)
	ParticleRotation(((math.random() * 2) - 1) * 10)
	ParticleDrag(drag)
	ParticleAlpha(alphaStart, alphaEnd, alphaGraph, alphaFadeIn, alphaFadeOut)
	ParticleRadius(smokeSize)
	ParticleColor(smokeColor[1], smokeColor[2], smokeColor[3])
	ParticleGravity(gravity * 0.25)
	SpawnParticle(VecAdd(pos, random_vec(TOOL.sparkJiggle.value)), movement, lifetime)
end

function totalSparks()
	local sum = 0
	for i = 1, #explosions do
		sum = sum + #explosions[i].sparks
	end
	return sum
end

function createExplosionInst(options, pos)
	local inst = {}
	inst.options = options or createOptionSetInst()
	inst.sparks = {}
	-- this value gets deincremented over time
	if pos ~= nil then
		table.insert(inst.sparks, pos)
	end
	inst.splitFreq = TOOL.sparkSplitFreqStart.value
	inst.life_n = 1
	inst.center = pos
	inst.dir = Vec()
	inst.averageDist = 0
	return inst
end

function createSparkInst(options, pos, dir, speed)
	local inst = {}
	inst.options = options or createOptionSetInst()
	inst.pos = pos
	inst.dir = dir
	inst.speed = speed or vary_by_percentage(TOOL.sparkSplitSpeed.value, TOOL.sparkSplitSpeedVariation.value)
	inst.sparkColor = options.sparkColor.value
	return inst
end

function getSparkLife(sparkSpeedValue)
	local delta = TOOL.sparkSplitSpeed.value - sparkSpeedValue
	local value = delta/(TOOL.sparkSplitSpeed.value - TOOL.sparkDeathSpeed.value)
	return bracket_value(value, 1, 0)
end
