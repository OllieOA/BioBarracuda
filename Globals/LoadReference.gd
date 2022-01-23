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
	load("res://Objects/SegmentChunks/BasicTurret.tscn"),
	load("res://Objects/SegmentChunks/ShotgunTurret.tscn")
]

var icon_lookup := [
	load("res://Assets/Barracuda/SegmentTypes/BaseTurretICON.png"),
	load("res://Assets/Barracuda/SegmentTypes/ShotgunTurretICON.png")
]

var segment_unlock = [
	0,
	0
]


var segment_tooltip = [
	"Basic Turret\nReasonable range and fire rate",
	"Spray Gun\nA short burst of projectiles"
]
