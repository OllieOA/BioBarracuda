extends Node

var orb_layer_reference: Node2D
var rng = RandomNumberGenerator.new()
var xp_orb_scene = preload("res://Objects/Enemies/Passive/XPOrb.tscn")

func _ready() -> void:
	rng.randomize()

#	# Get orb layer
#	orb_layer_reference = get_tree().get_current_scene().get_node("OrbLayer")


func generate_orbs(value: float, spawn_position: Vector2):
	
	# Generate orb proportions
	var n_orbs: int = rng.randi_range(3, 5)
	var proportions := []
	
	for i in range(n_orbs - 1):
		var new_value = rng.randf_range(value / 4, value / 2)
		proportions.append(new_value)
		value -= new_value
	proportions.append(value)
	
	# Instantiate orbs with random impulse directions
	for proportion in proportions:
		_instantiate_orb(proportion, spawn_position)


func _instantiate_orb(value, pos):
	var xp_orb = xp_orb_scene.instance()
	xp_orb.value = value
	orb_layer_reference.add_child(xp_orb)
	xp_orb.global_position = pos
	
	var rand_vector = Vector2(rng.randf_range(-1.0, 1.0), rng.randf_range(-1.0, 1.0)).normalized()
	xp_orb.apply_central_impulse(rand_vector * rng.randf_range(100, 500))
