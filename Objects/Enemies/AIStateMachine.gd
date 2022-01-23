extends Node
class_name AIStateMachine


signal state_changed(new_state)

enum States {
	DRIFT,
	PATROL,  # Swim around more purposefully than drifting
	RETURN,  # Return to spawn pos
	ENGAGE,
	ATTACK_COOLDOWN,
	CHASE  # Go to last seen location, sweep for vision, and then return to chill
}

enum Attacks {
	DASH,
	SHOOT,
	RUSH
}

enum Behaviours {
	COWARD,
	PASSIVE,
	AGGRESSIVE
}


var allowed_states := []

var current_state: int
var owner_node: RigidBody2D

var rng = RandomNumberGenerator.new()
var target_point: Vector2
var path: Array
var drift_point_reached := false


func _ready() -> void:
	connect("state_changed", self, "_handle_state_change")


func init_ai(node, allowable_states, init_state):
	allowed_states = allowable_states
	rng.randomize()
	owner_node = node
	allowed_states = owner_node.allowed_states
	set_state(init_state)


func set_state(new_state: int) -> void:
	if new_state == current_state:
		return
	elif not allowed_states.has(new_state):
		return 
		
	current_state = new_state
	
	emit_signal("state_changed", current_state)


func get_new_path(point1, point2) -> PoolVector2Array:
	var new_path = GameControl.navigation_layer.get_simple_path(point1, point2)
	return new_path.resize(5)


func _process(delta: float) -> void:
	if owner_node.scan() and owner_node.eye_detection:
		# Player detected
		set_state(States.ENGAGE)
	
	match current_state:
		States.ENGAGE:
			owner_node.attack()
		States.PATROL:
			pass
		States.DRIFT:
			owner_node.drift_active = true
			
		States.RETURN:
			if path.empty():
				target_point = owner_node.spawn_origin
				path = get_new_path(owner_node.global_position, target_point)


func _close_enough():
	if owner_node.global_position.distance_to(path[0]):
		pass


func _on_DetectionArea_body_entered(body: Node) -> void:
	if body.is_in_group("barracuda"):
		set_state(States.ENGAGE)


func _handle_state_change():
	print(current_state)
