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
		local sparkSpeeds = {}
		
		local newSmoke = {}
		for s = 1, #explosion.smoke do 
			local spark = explosion.smoke[s]
			local hitPoint = nil
			local hit, dist, normal, shape = QueryRaycast(spark.pos, spark.dir, spark.speed + 0.1, 0.025)
			if not hit then 
				makeSmoke(spark)
			end
		end
		
		local newSparks = {}
		for s = 1, #explosion.sparks do
			local spark = explosion.sparks[s]
			local sparkStillAlive = true
			local forceSplit = false
			spark.deltaFromOrigin = VecSub(spark.pos, explosion.center)
			spark.distanceFromOrigin = VecLength(spark.deltaFromOrigin)
			spark.distance_n = math.min(1, 1/(1 + spark.distanceFromOrigin))
			spark.inverseDelta = VecScale(spark.deltaFromOrigin, -1)
			spark.lookOriginDir = VecNormalize(spark.inverseDelta)
			local hitPoint = nil
			local hit, dist, normal, shape = QueryRaycast(spark.pos, spark.dir, spark.speed + 0.1, 0.025)

			-- Evolve the spark

			-- Fizzling verses splitting is what mostly determines the
			-- length of the explosion.
			
			-- fizzling, when a spark dies spontaneously
			-- the sparks further away from the center of the cloud will die out
			-- faster than the closer ones
			local fizzleDistance_n = math.min((1 + TOOL.sparkFizzleFalloffRadius.value)/(1 + spark.distanceFromOrigin), 1) ^ 0.5 
			local chance = TOOL.sparkFizzleFreq.value
			chance = math.max(math.ceil(chance * fizzleDistance_n), 1)
			if chance >= 1 and math.random(1, chance) == 1 then -- there's a bug, that's the only reason for the >= 1 check
				-- fizzled
				sparkStillAlive = false
			elseif hit then
				-- hit something, make hole
				MakeHole(spark.pos, TOOL.sparkHoleSoftRad.value, TOOL.sparkHoleMediumRad.value, TOOL.sparkHoleHardRad.value)
				Paint(spark.pos, 0.8, "explosion")

				-- hit following
				local body = GetShapeBody(shape)
				if body ~= nil then 
					local velocity = GetProperty(body, "velocity")
					if VecLength(velocity) < TOOL.sparkDeathSpeed.value then 
						-- stationary object or it slowed down too much
						-- if the angle is shallow allow a split, otherwise end the spark
						local dot = math.abs(VecDot(normal, spark.dir))
						if (dot < 0.5) then 
							spark.dir = VecScale(spark.dir, -1)
							forceSplit = true
						else
							sparkStillAlive = false
						end
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
				-- spark survives

				-- spark slows down
				spark.speed = math.max(spark.speed * (1 - TOOL.sparkSpeedReduction.value), TOOL.sparkDeathSpeed.value)

				-- Pushed by other explosion shocks
				spark.dir = VecNormalize(VecAdd(spark.dir, random_vec(TOOL.sparkJitter.value)))
				if blastEffectOrigin ~= nil then
					pushSparkFromOrigin(spark, 
					blastEffectOrigin, 
					TOOL.sparkBlastPushRadius.value, 
					TOOL.blastSpeed.value,
					0.5) 
				end

				-- pressure effects. 
				-- Torus effects - Pulling from behind the cloud and pushing from the front
				local pressureDistance_n = spark.distance_n  ^ 0.8
				local angleDot_n = VecDot(spark.lookOriginDir, VALUES.DIRECTIONAL_VECTOR)
				local torus_n = pressureDistance_n * angleDot_n
				local torus_mag = TOOL.sparkTorusMag.value * VALUES.PRESSURE_EFFECT_SCALE * #explosion.sparks * torus_n
				local torus_vector = VecScale(spark.lookOriginDir, torus_mag)
				pushSparkUniform(spark, torus_vector)

				-- pulling into the center
				local vacuum_mag = TOOL.sparkVacuumMag.value * VALUES.PRESSURE_EFFECT_SCALE * #explosion.sparks * pressureDistance_n
				local vacuum_vector = VecScale(spark.lookOriginDir, vacuum_mag ^ 0.5)
				pushSparkUniform(spark, vacuum_vector)

				-- pushing out
				local inflate_mag = TOOL.sparkInflateMag.value * VALUES.PRESSURE_EFFECT_SCALE * #explosion.sparks * pressureDistance_n * -1
				local inflate_vector = VecScale(spark.lookOriginDir, inflate_mag)
				pushSparkUniform(spark, inflate_vector)

				-- hurt the player if too close
				local player_pos = GetPlayerTransform().pos
				local dist = VecLength(VecSub(player_pos, spark.pos))
				local dist_n = dist / TOOL.ignitionRadius.value
				local hurt_n = 1 - math.min(1, dist_n) ^ 0.5
				if hurt_n > TOOL.sparkHurt.value then
					local health = GetPlayerHealth()
					SetPlayerHealth(health - (hurt_n * VALUES.SPARK_HURT_ADJUSTMENT))
				end

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
			
			if sparkStillAlive and spark.speed > TOOL.sparkDeathSpeed.value then
				spark.pos = VecAdd(spark.pos, VecScale(spark.dir, spark.speed))
				table.insert(newSparks, spark)
				local smokeVelocity = VecScale(spark.lookOriginDir, TOOL.blastSpeed.value)
				makeSparkEffect(spark)
				table.insert(sparkSpeeds, spark.speed)
				table.insert(positions, spark.pos)
				table.insert(dirs, spark.dir)
				table.insert(dists, spark.distanceFromOrigin)
			else
				-- dies into a puff of trailing smoke
				table.insert(newSmoke, spark)
			end
		end
		explosion.sparks = newSparks
		explosion.smoke = newSmoke

		-- spawn fire
		for probe=1, TOOL.ignitionProbes.value * #explosion.sparks do
			local ign_probe_dir = random_vec(1)
			local ign_probe_hit, ign_probe_dist, ign_probe_normal, ign_probe_shape = QueryRaycast(explosion.center, ign_probe_dir, TOOL.ignitionRadius.value)
			if ign_probe_hit then 
				local ign_probe_pos = VecAdd(explosion.center, VecScale(ign_probe_dir, ign_probe_dist))
				local mat = GetShapeMaterialAtPosition(ign_probe_shape, ign_probe_pos)
				if mat == "glass" then 
					MakeHole(ign_probe_pos, 0.2)
				else
					SpawnFire(ign_probe_pos)
					for ign=1, TOOL.ignitionCount.value do
						local ign_dir = random_vec(1)
						local ign_hit, ign_dist = QueryRaycast(ign_probe_pos, ign_dir, TOOL.ignitionRadius.value)
						if ign_hit then 
							local ign_pos = VecAdd(ign_probe_pos, VecScale(ign_dir, ign_dist))
							SpawnFire(ign_pos) 
						end
					end
				end
			end
		end

		if (#explosion.sparks + #explosion.smoke) > 0 then
			if #explosion.sparks > 0 then 
				explosion.life_n = bracket_value(#explosion.sparks / TOOL.sparksPerExplosion.value, 1, 0)
				explosion.center = average_vec(positions)
				explosion.averageDist = 0
				for j=1, #dists do
					explosion.averageDist = explosion.averageDist + dists[j]
				end
				explosion.averageDist = explosion.averageDist / #dists
				explosion.dir = VecNormalize(average_vec(dirs))
				explosion.splitFreq = math.floor(math.min(explosion.splitFreq + TOOL.sparkSplitFreqInc.value, TOOL.sparkSplitFreqEnd.value))
			end

			table.insert(newExplosions, explosion)
		end
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
	if position == nil then return end -- shape totally destroyed
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
	for a = 1, TOOL.sparksPerExplosion.value do
		local newSpark = createSparkInst(TOOL, 
		VecAdd(pos, random_vec(0.5)), 
		VecNormalize(random_vec(1)), 
		TOOL.blastSpeed.value)
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

function makeSparkEffect(spark)
	local movement = random_vec(1)
	local gravity = 0
	local colorHSV = spark.sparkColor
	local color = HSVToRGB(colorHSV)
	local intensity = TOOL.sparkLightIntensity.value
	local lifetime = TOOL.sparkPuffLife.value
	local puffColor = HSVToRGB(VALUES.DEFAULT_PUFF_COLOR)
	PointLight(spark.pos, color[1], color[2], color[3], intensity)

	-- fire puff
	ParticleReset()
	ParticleType("smoke")
	ParticleTile(math.random(0,1))
	ParticleRotation(((math.random() * 2) - 1) * 10)
	ParticleDrag(0.25)
	ParticleAlpha(1, 0, "easeout")
	ParticleRadius(math.random(TOOL.sparkTileRadMin.value, TOOL.sparkTileRadMax.value) * 0.1)
	ParticleColor(puffColor[1], puffColor[2], puffColor[3])
	ParticleGravity(gravity)
	SpawnParticle(spark.pos, movement, lifetime)
end

function makeSmoke(spark)
	local smokeColor = HSVToRGB(TOOL.smokeColor.value)
	ParticleReset()
	ParticleType("smoke")
	ParticleTile(math.random(0,1))
	ParticleRotation(((math.random() * 2) - 1) * 10)
	ParticleDrag(0)
	ParticleAlpha(1, 0, "easeout", 0.1, 0.5)
	ParticleRadius(TOOL.sparkSmokeTileRadius.value)
	ParticleColor(smokeColor[1], smokeColor[2], smokeColor[3])
	ParticleGravity(0)
	SpawnParticle(VecAdd(spark.pos, random_vec(0.2)), VecScale(VecAdd(spark.dir, random_vec(0.5)), spark.speed), TOOL.sparkSmokeLife.value)
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
	inst.smoke = {}
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
	inst.lookOriginDir = nil
	inst.distanceFromOrigin = 0
	inst.distance_n = 1
	inst.deltaFromOrigin = 0
	inst.inverseDelta = 0
	inst.smokeLife = TOOL.sparkPuffLife.value
	return inst
end

function getSparkLife(sparkSpeedValue)
	local delta = TOOL.sparkSplitSpeed.value - sparkSpeedValue
	local value = delta/(TOOL.sparkSplitSpeed.value - TOOL.sparkDeathSpeed.value)
	return bracket_value(value, 1, 0)
end

-- function createBombInst(pos)
-- 	local inst = {}
-- 	inst.trans = Transform(pos) --, QuatEuler(math.random(0,359),math.random(0,359),math.random(0,359)))
-- 	inst.shape = Spawn("MOD/prefab/Decoder.xml", trans, false, true)[2]
-- 	return inst
-- end
