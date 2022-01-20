extends Node

# Increasable stats
var max_speed
var max_speed_base := 1000.0
var max_speed_bonus_segments := 0
var max_speed_bonus_factor := 50.0

var acceleration
var acceleration_base = 200.0
var acceleration_bonus_segments = 0
var acceleration_bonus_factor = 50.0

var dash_strength
var dash_strength_base = 5000.0
var dash_strength_bonus_segments = 0
var dash_strength_bonus_factor = 1000.0


var dash_cooldown
#var dash_cooldown_base = 1.8
var dash_cooldown_base = 0.5
var dash_cooldown_bonus_segments = 0
var dash_cooldown_bonus_factor = -0.3

# Flat stats
var linear_damp_value
var linear_damp_value_base = 5
var linear_damp_segment_factor = -0.2

var angular_damp_value
var angular_damp_value_base = 9
var angular_damp_segment_factor = -0.1

var n_segments: int
var current_biomass: float = 0.0


func _ready() -> void:
	
	calc_new_properties()
	
	linear_damp_value = linear_damp_value_base
	angular_damp_value = angular_damp_value_base
	
	SignalBus.connect("biomass_consumed", self, "_consume_biomass")
	
	
func calc_new_properties():
	n_segments = len(GameControl.segment_list)
	
	acceleration = 200 + acceleration_base * n_segments + acceleration_bonus_factor * acceleration_bonus_segments
	max_speed = max_speed_base + max_speed_bonus_factor * max_speed_bonus_segments
	dash_strength = dash_strength_base + dash_strength_bonus_factor * dash_strength_bonus_segments
	dash_cooldown = dash_cooldown_base + dash_cooldown_bonus_factor * dash_cooldown_bonus_segments
	
	linear_damp_value = linear_damp_value_base + linear_damp_segment_factor * n_segments
	angular_damp_value = angular_damp_value_base + angular_damp_segment_factor * n_segments
	
	
func _consume_biomass(amount):
	current_biomass += amount
