extends Node2D

var ai_active: bool
var point_reached: bool
var goal_point: Vector2
var my_body: RigidBody2D
var heading_x: float
var heading_y: float
var random_torque: float

var drift_origin: Vector2
var rng = RandomNumberGenerator.new()


func _ready() -> void:
	rng.randomize()
	drift_origin = global_position
	point_reached = false
	goal_point = drift_origin + Vector2(300 * randf(), 300 * randf())


func begin(node: RigidBody2D):
	ai_active = true
	print("AI ACTIVE")
	my_body = node


func _physics_process(delta: float) -> void:
	if ai_active:
		if not point_reached:
			if global_position.distance_to(goal_point) < 50:
				point_reached = true
			else:
				heading_x = lerp(my_body.linear_velocity.normalized().x, global_position.direction_to(goal_point).normalized().x, 0.1)
				heading_y = lerp(my_body.linear_velocity.normalized().y, global_position.direction_to(goal_point).normalized().y, 0.1)
				my_body.apply_central_impulse(800 * Vector2(heading_x, heading_y))
				random_torque = 5000 * (2 * randf() - 1)
				my_body.apply_torque_impulse(random_torque)
				
		else:
			goal_point = drift_origin + Vector2(300 * randf(), 300 * randf())
			point_reached = false
	
