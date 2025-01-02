# Jet Fuel - A mod for Teardown
## Description
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
A subgroup of sparks that are associated by distance and controlled as a group by the simulation separately from other groups. Fireballs are can be thought of as one group of fire sparks moving together in a toroidal motion upward (typically). The center of a fireball is used as an origin for measuring distance and relative motion to all sparks contained in that fireball, affecting their motion and lifespan. Sparks are assigned to fireballs dynamically as the simulation progresses.
### Smoke
A spark that has died (from fizzling or running out of splits) becomes a smoke particle. Smoke particles continue in a straight line for a short period of time before disappearing.
## Game controls
### Detonate (default [X] key)
Will create an explosion at the location of every bomb shape (provided any voxels of the original shape remain). Bombs are detonated in order that they were planted/infused unless the player has toggled reverse mode to on. Bombs will be detonated when the simulated number of sparks (see the lower left screen) goes below the detonation trigger value (see options below). Note: all sparks share the same simulation limit (see options below). An explosions releases a certain number of sparks into the simulation which is bound to this limit. Once this limit is exceeded, sparks are randomly removed. This means that if you detonate several bombs simultaneously there will be smaller amounts of fire associated with each one. Raise the simulation limit to allow for more total fire if this is desired. 
### Plant (default LMB)
In sticky mode (default, see control below), A canister will be attached with a joint to any surface under the players target reticule. When sticky mode is off, a cansiter will be spawned directly in front of the player. 
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
Toggles sticky mode on and off. In sticky mode (default, see control below), A canister will be attached with a joint to any surface under the players target reticule. When sticky mode is off, a cansiter will be spawned directly in front of the player. 
## Game options
The following options are described in the order of appearance in columns going left to right. 
### Spark color
Color of spark (fire) point lights illuminating white "puff" tiles. Essentially, the color of the fireballs.
### Smoke color
Color of the smoke particles.
### Sparks simulation limit
Total number of sparks allowed in the simulation at the same time. When this limit is exceeded sparks are removed at random until below the limit. This applies to ALL fire from ALL bombs in the simulation.
### Bomb energy
The actual number of splits allowed per spark in the simulation. Every time a spark splits into new sparks, every child spark receives the decrementing split count of its parent. This effectively limits the lifespan of the fireball along with the fizzle frequency (see below).
### Bomb sparks
The number of sparks that are spawned by a bomb explosion. 
### Detotation trigger (sparks, next detonation)
The number of sparks that will allow the simulation to trigger the next explosion. When the total simulated number of sparks falls below this number, the next bomb, if any, will detonate. 
### Fireball sparks max (maximum number of sparks, fireball)
The maximum number of sparks that can be assigned together in a fireball before a new fireball is defined. The pressure variables (torus, vacuum, inflation - see below) apply to only one fireball and the sparks assigned to it. 
### Fireball sparks min (minimum number of sparks, fireball)
The minimum number of sparks that can be assigned together in a fireball before the fireball, and all sparks assigned to it, die. 
### Fireball radius (torus radius)
When sparks are dynamically assigned to a fireball, a random spark is chosen and any other sparks within this radius are considered part of that fireball unless the upper limit (see above) is reached.
### Blast power
The explosion power (as defined by Teardown: 0-4) that is triggered for each bomb detonation. 
### Blast speed
The speed sparks are given at detonation. This affects the initial area of fire surrounding the blast. 
### Spark hurt (to the player)
A number that determines how much the player is hurt by proximity to a spark, per tick. The ignition radius (see below) is used to calculate how much damage is given to the player by proximity to a spark. 
### Spark erosion soft
### Spark erosion medium
### Spark erosion hard
### Ignition and hurt radius
### Ignition probes
### Ignition count
### Impulse power
### Impulse radius
### Impulse trials (nearest number of shapes to attempt impulse)
### Torus pressure (fireball)
### Vacuum pressure (fireball)
### Inflation pressure (fireball)
### Spark spawns max
### Spark spawns min
### Spark split frequency start
### Spark split frequency end
### Spark split frequency increment
### Spark split direction variation
### Spark hit direction variation
### Spark split speed
### Spark split speed variation
### Spark speed reduction
### Spark jitter
### Spark puff life
### Smoke life (Spark smoke life)
### Spark tile size max
### Spark tile size min
### Smoke tile size
### Spark light intensity
## Other values (found in /script/Defs.lua, must be edited in code)
### 
