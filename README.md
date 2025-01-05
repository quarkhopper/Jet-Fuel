# Jet Fuel - An explosive mod for Teardown
## Description
I created this mod to produce evolving volumes of fire following an expanding tree and including pseudo-physics (physics with corners gruesomely cut) that make ballooning, mushrooming fire. I was not satisfied with the way explosions looked in Teardown, or the way they looked in a lot of other mods. I really wanted that Michael bay look of billowing fireballs. I created an earlier mod called "Bay Bomb" that became modestly popular, but wanted to build something more interactive with the environment and behaved in a more realistic way. This mod allows to you tweak most aspects of the explosion (the the point you can create something really alien looking if you wanted). 
## Definitions
### Bomb
Any shape that can produce an explosion by breaking or on command.
### Canister
An object the player can spawn that functions as a bomb.
### Infused shape
A shape that has been infused by the player and becomes a bomb.
### Spark
One simulated point of fire that consists of a fire tile particle and point light source. A spark's motion is controlled by the simulation. Sparks have contact effects on surfaces, such as creating holes in materials. Spark lifespan is determined by the number of allowed splits and a random chance to fizzle out.
### Explosion
The result of a detonation of either a canister or an infused shape. An explosion adds sparks to the simulation.
### Simulation
The collection of all sparks and parameters affecting their behavior.
### Fireball
A subgroup of sparks that are associated by distance and controlled as a group by the simulation separately from other groups. Fireballs can be thought of as one group of fire sparks moving together in a toroidal motion upward (typically). The center of a fireball is used as an origin for measuring distance and relative motion to all sparks contained in that fireball, affecting their motion and lifespan. Sparks are assigned to fireballs dynamically as the simulation progresses.
### Smoke
A spark that has died (from fizzling or running out of splits) becomes a smoke particle. Smoke particles continue in a straight line for a short period of time before disappearing.
## General principles
The simulation runs through a number of phases every tick to push around units of fire called "sparks" that comprise the volume of fire in the explosion. The mushrooming motion of the sparks is due to the sparks splitting apart at random times and into random numbers of child sparks, and moved around by competing forces. The explosion lifetime is governed by the opposition of sparks splitting into new child sparks vs. the tendency to "fizzle" out at a constant frequency. 
The movement of sparks is governed by competing pressure forces generated by their relative location to an average location in groups called "fireballs". Other factors dictate spark behavior and give some unpredictability to the evolution of the explosion. 

When you blow up bombs, you're really creating centers of fire, but once the fire is free it is all considered one simulated mass of fire. In that respect, putting a line of bombs down isn't creating _more_ fire, it's just _spreading the fire around_ that's allowed to exist at the same time. If there's no detonation trigger value (i.e. it's set to -1) all your bombs explode at once and the available fire is spead among the explosions. Individual bombs also allow for chain reactions to occur, but the fire on-screen is still the same amount in total - the simulation limit (see the "Sparks simulation limit" option below).
## Flow diagram
In one tick, the following sequence is executed (with some generalization):
- All explosive items (bombs) are checked for having broken shapes. If the shape is broken, the bomb is added to the list of bombs to detonate (at the appropriate time, see "detonation trigger" option below).
- All bombs that are due to be detonated are either detonated or added to the list to be considered on the next tick (see "detonation trigger" option below)
- Fireball determination and calculations. All sparks, regardless of their source, are grouped into "fireballs" for the purposes of determining hot centers of pressure effects. This is the unit of the simulation that produces toroidal effects and mushrooming fire. Fireballs are grouped via proximity to an arbitrarily selected spark. 
- For every spark that has died in the last tick and become "smoke" has a smoke particle generated for it.
- Spark behavior and motion simulated
  - Spark may fizzled by random chance (see fizzle frequency option)
  - Sparks that hit things do damage to them (erosion) and will then split if they hit at a shallow angle OR fizzle if they hit at a steep angle (see erosion options)
  - Sparks that hit a moving object will split and continue to move at the speed of that object (hit following)
  - Spark speed is reduced (see speed options)
  - Fireball pressure effects are applied (see pressure options)
  - Player is hurt if too close to the spark (see spark hurt option)
  - Spark will split by random chance (see spark split options)
  - The simulation culls sparks if there are more sparks then the set limit (see sparks simulation limit option)
  - Sparks are turned into smoke particles if they are dead (fizzled or have dropped to "death" speed)
  - Spawn fires on objects near the fireball. If spawned on glass, a hole is made instead.
- Objects are impulsed by fireballs
## Game controls
### Detonate (default [X] key)
Will create an explosion at the location of every bomb shape (provided any voxels of the original shape remain). Bombs are detonated in order that they were planted/infused unless the player has toggled reverse mode to on. Bombs will be detonated when the simulated number of sparks (see the lower left screen) goes below the detonation trigger value (see options below). Note: all sparks share the same simulation limit (see options below). An explosion releases a certain number of sparks into the simulation which is bound to this limit. Once this limit is exceeded, sparks are randomly removed. This means that if you detonate several bombs simultaneously there will be smaller amounts of fire associated with each one. Raise the simulation limit to allow for more total fire if this is desired. 
### Plant (default LMB)
In sticky mode (default, see control below), A canister will be attached with a joint to any surface under the players target reticule. When sticky mode is off, a canister will be spawned directly in front of the player. In infuse mode, you can infuse any shape to __make it a bomb__. Clicking on an existing bomb will un-infuse it as well, including canisters (try it)!
### Clear (default [V] key)
Clears all canisters, un-infuses all shapes, and removes all sparks (fire) from the simulation. Does NOT remove fires started by the simulation. 
### Options (default [O] key)
Opens the options menu for the simulation.
### Infuse on/off (default [I] key)
Toggles infuse mode on and off. Infuse mode allows the player to designate any shape under the target reticule to be a bomb. The shape under the reticule will be outlined in white if it is not yet infused, yellow if it has been infused, and red if it will detonate soon. Clicking on an infused shape will un-infuse it. 
### Single on/off (default [B] key)
Toggles single detonation mode on and off. In this mode, pressing the detonation key will only trigger the first planted/infused bomb to detonate. In reverse mode (see below), only the last planted/infused shape will detonate. Other detonations may occur if other bomb shapes are broken as a result.
### Reverse on/off (default [N] key)
Toggles reverse detonation mode on and off. In reverse mode, the last bomb planted will be detonated first.
### Sticky on/off (default [M] key)
Toggles sticky mode on and off. In sticky mode (default, see control below), A canister will be attached with a joint to any surface under the player's target reticule. When sticky mode is off, a canister will be spawned directly in front of the player. 
## Game options
The following options are described in the order of appearance in columns going left to right. 

All calculations are in pseudo-code for clarity. 

Brackets around words `[like this]` should be treated as a single variable. 

Variables with `_n` at the end `likeThis_n` are normalized (guaranteed to be between 0 and 1).

Variables with `_v` at the end `likeThis_v` are 3D vectors.

Variables with `_uv` at the end `likeThis_uv` are unit 3D vectors (length 1).

Variables in all caps with underscore spaces `LIKE_THIS` are constants that are defined in `/script/Defs.lua` for those who have copied the mod locally and wish to change them. 

Vector math, where applicable: `(dot)` indicates the vector dot product operator, `(cross)` indicates a cross product operator
### Spark color
Color of spark (fire) point lights illuminating white "puff" tiles. Essentially, the color of the fireballs.
### Smoke color
Color of the smoke particles.
### Sparks simulation limit
Total number of sparks allowed in the simulation at the same time. When this limit is exceeded sparks are removed at random until below the limit. This applies to ALL fire from ALL bombs in the simulation.
### Bomb energy
The actual number of spark splits __distributed among all sparks in one bomb explosion__. Every tick, there's a chance a spark will split into child sparks, and when that happens, the child sparks are initialized with the remaining split count of its parent. This effectively limits the lifespan of the fireball along with the fizzle frequency (see below). This number is the number of splits __distributed into all the sparks for one explosion__, meaning, depending on how many sparks are in the explosion (see "bomb sparks" option below), all these splits may be distributed into very few sparks making them very __long-lived__, or into many sparks making the overall explosion very __short-lived__.
### Bomb sparks
The number of sparks that are spawned by a bomb explosion. 
### Detotation trigger (sparks, next detonation)
The number of sparks that will allow the simulation to trigger the next explosion. When the total simulated number of sparks falls below this number, the next bomb, if any, will detonate. A value of -1 will cause the simulation to ignore triggering and detonate all bombs simultaneously.
### Fireball sparks max (maximum number of sparks, fireball)
The maximum number of sparks that can be assigned together in a fireball before a new fireball is defined. The pressure variables (torus, vacuum, inflation - see below) apply to only one fireball and the sparks assigned to it. 
### Fireball radius (torus radius)
When sparks are dynamically assigned to a fireball, a random spark is chosen and any other sparks within this radius are considered part of that fireball unless the upper limit (see above) is reached.
### Blast power
The explosion power (as defined by Teardown: 0-4) that is triggered for each bomb detonation. 
### Blast speed
The speed sparks are given at detonation. This affects the initial area of fire surrounding the blast. 
### Spark hurt (to the player)
A number that determines the point at which the player is hurt by proximity to a spark. The ignition radius (see below) is used to calculate how much damage is given to the player by proximity to a spark. 
#### Calculation 
>     dist_n = [distance from spark] / [ignition radius]
>     hurt_n = minimum(1, dist_n) ^ 0.5
>     if hurt_n > [spark hurt] {
>         [new player heath] = [current player health] - (hurt_n * SPARK_HURT_SCALE)
>     }
For the value of `SPARK_HURT_SCALE`, see "other values" below. 
### Spark erosion soft
The number of voxels removed from soft materials on hit by a spark
### Spark erosion medium
The number of voxels removed from medium materials on hit by a spark
### Spark erosion hard
The number of voxels removed from hard materials on hit by a spark
### Ignition and hurt radius
Radius used in starting fires from the center of a fireball. Ignition occurs in two phases: a raycast is done from the center of the fireball and, if it hits a surface, a second set of raycasts are done from that point. If the second raycast hits an object then a fire is started at that point. Essentially, a raycast and a "bounce" is done to find the location to start a fire. This radius is also used to determine how far away a player can be hurt by a spark. 
### Ignition probes
The number of initial raycasts done from the center of a fireball, per spark, to find a location to do a "bounce" and one further raycast to find locations to start a fire.
### Ignition count
The number of secondary raycasts on "bounce" to find the location to start a fire. The total number of POTENTIAL fires started by a fireball is `[ignition probes] * [sparks in the fireball] * [ignition count]`.
### Impulse power
The amount of impulse applied to a body by a fireball to surrounding objects. This is the power that sucks things up into the explosion and shoots them out. Some objects may even be held _inside_ of fireballs until they die and then dropped, flaming to the ground. 
#### Calculation
>     imp_n = 1 - bracket([distance to fireball center] / [impulse radius], 1, 0)
>     imp_mag = imp_n * [impulse power] * [number of fireball sparks] * IMPULSE_SCALE
For the value of `IMPULSE_SCALE`, see "other values" below.
Note: negative impulse pulls objects toward the center of the fireball, positive pushes objects away.
### Impulse radius
The maximum radius from the center of the fireball to impulse objects. 
### Impulse trials (nearest number of shapes to attempt impulse)
The maximum number of shapes that can be impulsed (within the radius above) by a fireball.
### Pressure options
There are three options that deal with pressure within a fireball . They are:
- Torus pressure
- Vacuum pressure
- Inflation pressure

It is the balance of these forces that primarily affects fireball shape and movement, among other minor factors described in this document.
- __Torus__ pressure describes the push that sparks experience moving them through the fireball in the direction of travel, diminishing with distance. The calculation uses a vector dot product that creates more pressure when a spark is near the axis of travel.
- __Vacuum__ pressure pushes sparks into the center of a fireball, regardless of the orientation of the spark to the fireball center. Like torus pressure, the effect diminishes with distance.
- __Inflation__ pressure pushes sparks away from the center of a fireball, regardless of the orientation of the spark to the fireball center. This effect also diminishes with distance.

NOTE: for the following three pressure variables the variable `pressureDistance_n` is defined as:
>     sparkDistance_n = minimum(1, 1/(1 + [spark distance from origin]))
>     pressureDistance_n = sparkDistance_n ^ 0.8
In the following calculations, the values of `UP_VECTOR` and `PRESSURE_EFFECT_SCALE`, see the section "other values" below.
#### Torus pressure calculation
For one spark:
>     lookDir_uv = [Unit vector from spark to center of fireball]
>     angleDot_n = lookDir_uv (dot) UP_VECTOR
>     torus_n = pressureDistance_n * angleDot_n
>     torus_mag = [torus pressure] * PRESSURE_EFFECT_SCALE * [number of sparks in fireball] * torus_n
>     torus_vector_v = lookDir_uv * torus_mag
#### Vacuum pressure calculation
For one spark:
>     vacuum_mag = [vacuum pressure] * PRESSURE_EFFECT_SCALE * [number of sparks in fireball] * pressureDistance_n
>     vacuum_vector_v = lookDir_uv * vacuum_mag ^ 0.5
#### Inflation pressure calculation
For one spark:
>     inflate_mag = [inflation pressure] * PRESSURE_EFFECT_SCALE * [number of sparks in fireball] * pressureDistance_n * -1
>     inflate_vector_v = lookDir_uv * vacuum_mag ^ 0.5
### Spark spawns max
When a spark splits, this is the upper limit of child sparks (spawns) that will be randomly generated.
### Spark spawns min
When a spark splits, this is the lower limit of child sparks (spawns) that will be randomly generated.
### spark split frequency options:
Three options govern the frequency that a spark may split at the beginning and end of its life. All three of these frequency variables affect things as a __denominator__ in the form `1/n`, meaning that the bigger the number, the less frequent the occurrence. A value of 1 will, therefore, ensure something happens every tick. A very large value (say, in the hundreds or thousands) will happen very infrequently. 
The split options are:
- Spark split frequency start
- Spark split frequency end
- Spark split frequency increment

Sparks each have an internal split frequency number that increases over time, meaning that the spark is __less__ likely to split every tick. Every tick the number will continue to increase by the increment specified until it reaches the end frequency number. By default this goes from something fairly frequent (say, 1/10) to something very infrequent (say, 1/300). The actual determination of whether the spark will split is a random number between 1 and the frequency number, and a split will occur if a 1 is randomly drawn. 
### Spark split direction variation
A random vector is generated with components between `n` and `-n`, where `n` is the value of the option. This is then added to the directional vector of the spark at split spawn. 
### Spark hit following max speed
A spark can "follow" a moving object when it hits it, as though it is sticking to it. This value is that maximum speed that a spark will attempt to follow an object before disengaging. This effect is called "hit following" and allows fireballs to be shaped by objects moving through them. 
### Spark death speed
Speed at which a spark is considered "dead" and turns into a smoke particle. The age of a particle can be thought of as its speed value between split speed at birth and death speed as it slows down.
### Spark split speed
The base speed a spark travels at split spawn.
### Spark split speed variation
A random number from 1 to `n` will be added to the sparks speed at split spawn.
### Spark speed reduction
The amount of speed lost by a spark every tick. 
### Spark puff life
The lifetime of an individual spark "puff" particle __per tick__. Sparks are continuously simulated, but every tick a single particle "puff" and point light source is generated to marks its position. This lifetime is very short since it represents where a spark was at one point in time.
### Smoke life (Spark smoke life)
The lifetime of a single smoke particle. This lifetime is typically longer than the spark puff lifetime because a smoke particle is generated once and follows a straight line until it fades.
### Two options govern the size of a spark "puff" particle:
- Spark tile size max
- Spark tile size min

The size will be randomly determined every tick to be between these two numbers, inclusive.
### Smoke tile size
The size of a smoke particle. 
### Spark light intensity
Light intensity of the point light in a spark "puff" particle. 
## Other values (found in `/script/Defs.lua`, must be edited in code)
### The following values are constants that put the adjustable option within a convenient range
- `SPARK_HURT_SCALE`
- `IMPULSE_SCALE`
- `PRESSURE_EFFECT_SCALE`

### `PUFF_CONTRAST`
A number between 0 and 1 that determines the contrast of the fireball, regardless of spark color. This number actully is the __saturation value__ of the HSV color of the spark "puff" particle color. This puff is, by default, set to a monochromatic color in order to be illuminated by the associated point light. The point light color is set with the spark color option (see options above). 
### `UP_VECTOR`
The direction fireballs travel. This direction is used with the location of the spark in relation to the fireball center to determine toroidal motion. By default, this is set to (0,1,0) to set fireballs moving upward, as one would expect on Earth with a hot fireball. If another direction is desired, it can be set here. This can also be set to (0,0,0) to simulate explosions in zero gravity.
