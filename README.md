#Jet Fuel - A mod for Teardown
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
A subgroup of sparks that are associated by distance and controlled as a group by the simulation separately from other groups. Fireballs are can be thought of as one group of fire sparks moving together in a toroidal motion upward (typically). The center of a fireball is used as an origin for measuring distance and relative motion to all sparks contained in that fireball, affecting their motion and lifespan. 
### Smoke
A spark that has died (from fizzling or running out of splits) becomes a smoke particle. Smoke particles continue in a linear fashion for a short period of time before disappearing.
## Game controls
### Detonate key (default X)

## Game options
The following options are described in the order of appearance in columns going left to right. 
### Spark color
Color of fire sparks.
