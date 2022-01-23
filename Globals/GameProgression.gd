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

# Energy stats
var current_energy
var base_energy := 100
var max_energy: float
var max_energy_bonus_segments: int
var max_energy_bonus_factor: float

var energy_rechage_rate
var base_energy_recharge := 10
var base_energy_recharge_bonus_segments := 0
var base_energy_recharge_bonus_factor : float

# Current Game Numbers
var n_segments: int
var max_segments_available_in_level: int
var curr_max_segments: int
var base_max_segments := 2
var current_biomass: float = 0.0
var stage_biomass_limit: float = 100.0

var overall_biomass_limit: float = 400.0
var overall_biomass_consumed: float = 0.0
var biomass_upgrade_number: int = 0
var biomass_cost: float
var biomass_cost_base: float = 100
var biomass_cost_increase_factor: float = 50

var biomass_threshold_met := false
var segment_pool: Array
var rolled_segments: Array

var segment_unlock_threshold: float
var segment_unlock_increment: float

var biomass_consumable := true

var rng = RandomNumberGenerator.new()


func _ready() -> void:
	rng.randomize()
	segment_pool = []
	calc_new_properties()
	
	linear_damp_value = linear_damp_value_base
	angular_damp_value = angular_damp_value_base
	
	SignalBus.connect("biomass_consumed", self, "_consume_biomass")
	SignalBus.connect("upgrade_purchased", self, "_get_new_biomass_cost")
	SignalBus.connect("biomass_threshold_met", self, "_roll_options")
	current_energy = base_energy
	
	curr_max_segments = base_max_segments
	biomass_cost = biomass_cost_base


func enter_level():
	segment_unlock_threshold = get_tree().get_current_scene().level_max_biomass / get_tree().get_current_scene().max_segments
	segment_unlock_increment = segment_unlock_threshold


func _process(delta: float) -> void:
	if not biomass_threshold_met and current_biomass >= biomass_cost:
		biomass_threshold_met = true
		SignalBus.emit_signal("biomass_threshold_met")

	
func calc_new_properties():
	n_segments = len(GameControl.segment_list)
	
	# Movement
	acceleration = 200 + acceleration_base * n_segments + acceleration_bonus_factor * acceleration_bonus_segments
	max_speed = max_speed_base + (max_speed_bonus_factor * max_speed_bonus_segments)
	dash_strength = dash_strength_base + (dash_strength_bonus_factor * dash_strength_bonus_segments)
	dash_cooldown = dash_cooldown_base + (dash_cooldown_bonus_factor * dash_cooldown_bonus_segments)
	
	# Physics
	linear_damp_value = linear_damp_value_base + linear_damp_segment_factor * n_segments
	angular_damp_value = angular_damp_value_base + angular_damp_segment_factor * n_segments
	
	# Stats
	max_energy = base_energy + (max_energy_bonus_segments * max_energy_bonus_factor)
	energy_rechage_rate = base_energy_recharge + (base_energy_recharge_bonus_segments * base_energy_recharge_bonus_factor)
	SignalBus.emit_signal("properties_updated")
	
	
func _consume_biomass(amount):
	if biomass_consumable:
		current_biomass += amount
		overall_biomass_consumed += amount
		
		if overall_biomass_consumed > segment_unlock_threshold:
			curr_max_segments += 1
			segment_unlock_threshold = segment_unlock_increment * (curr_max_segments - 1)
			SignalBus.emit_signal("max_segments_updated")
			
		if curr_max_segments - 1 == max_segments_available_in_level:
			biomass_consumable = false
			SignalBus.emit_signal("level_unlocked")
		

func get_available_segments():
	max_segments_available_in_level = get_tree().get_current_scene().max_segments


func _get_new_biomass_cost(_option):
	biomass_threshold_met = false
	current_biomass -= biomass_cost
	
	biomass_upgrade_number += 1
	biomass_cost = biomass_cost_base + biomass_upgrade_number * biomass_cost_increase_factor
	SignalBus.emit_signal("biomass_spent")


func _roll_options():
	segment_pool = []
	rolled_segments = []
	
	for segment_type in LoadReference.ThisIsAnEnumForWhatTheSegmentTypeCouldBe:
		if LoadReference.segment_unlock[LoadReference.ThisIsAnEnumForWhatTheSegmentTypeCouldBe[segment_type]] <= biomass_upgrade_number:
			segment_pool.append(LoadReference.ThisIsAnEnumForWhatTheSegmentTypeCouldBe[segment_type])
	
	segment_pool.shuffle()
	rolled_segments.append(segment_pool[0])
	rolled_segments.append(segment_pool[1])
