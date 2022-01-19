# BioBarracuda Ideas
##  Theme
Ocean - Game takes place in an ocean cove and you want to get to the depths through the cave system. 

You are a barracuda that has been bio-engineered, and escaped from the scientists that did this to you. You have incredible abilities! You can grow your body to convert energy into projectiles, generate shields, and more! Escape out the bottom of the cave, but beware of the horrors of the depths - you might not be the only thing that has escaped from the facility.

## Wildcards

- Sound of Y'all - Make all sounds with our mouths - Yes
- Fishy Business - Have a fishing minigame - I don't think so - maybe an attack on fish can be 
- It's Treeson Then - Have our favourite quote or pun in the game - If the thought arises
	- "It's a lovely morning in the village and you are a horrible barracuda"

## Segments
The game will basically be a roguelite kind of feel, where you fill a meter and generate a new body segment. Once you reach a certain length you can dive deeper, but enemies are harder.

Building algorithm

add_segment(segment_to_add)
	get the current array of segments
	insert new segment at array index 1
	detach head from array_index 2
	push the head forward
	instance segment at position
	connect joint

rebuild_barracuda

remove_segment(pos)
	


Segments include
- Basic shield (Level 1)
- Basic gun (Level 1)
- Basic energy cache (Level 1)
- Double gun (Level 2)
- Spray gun (Level 2)
- Speed fins (increase dash) (Level 2)
- Advanced energy cache (Level 3)
- Advanced shield (Level 3)
- Biomass generator

### Balance
Level 1 - Start with 2 segments, End level with 6, have ~8 opportunities to grow
Level 2 - 

### Passives
MiscBlob
- Every level
- Floating
- Small biomass

CoralBlob
- Every level
- On walls
- Small biomass

BioEngineered Blob
- Hidden in level (not respawnable)

### Enemies
The enemies will be a combination of these mechanics
- Run away (lol)
- Dash
- Turret
- Shield
- Multi-stage??
- Pulse (Directed)
- Full pulse(??)


#### Level 1
Basic Small Fish
- Does not attack - only runs
- Medium biomass

Basic Spiked Fish
- Ram attack at nearest segment within range (not head)
- Contact damage
- High biomass

Basic Turret Coral
- Wall based turret shot - poor accuracy
- Ranged projectile
- Medium biomass

#### Level 2
Basic Small Fish (again)

Advanced Spiked Fish
- More aggressive ramming

Floating turret
- Move around the map and chase player while also firing

Double turret
- High biomass

#### Level 3
Triple turret
- Three turrets
- Medium biomass

Pulse turret
- Armoured electro pulse
- High biomass

#### Level 4 (Boss - Crab)
Two stage boss
- Stage 1 - static fight with turrets on an outer shell
- Stage 2 - rocket claws
- Stage 3 - crab body that pulses