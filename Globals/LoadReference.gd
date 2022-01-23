extends Node

enum ThisIsAnEnumForWhatTheSegmentTypeCouldBe {
	BASIC_TURRET,
#	BASIC_SHIELD
#	BASIC_ENERGY_CACHE,
#	ADVANCED_SHIELD,
#	DOUBLE_TURRET,
	SPRAY_TURRET,
#	SPEED_FINS,
#	ADVANCED_ENERGY_CACHE,
#	ADVANCED_SHIELD,
#	BIOMASS_GENERATOR
}

# TODO fill preloads
var lookup := [
	preload("res://Objects/SegmentChunks/BasicTurret.tscn"),
	preload("res://Objects/SegmentChunks/ShotgunTurret.tscn")
]
