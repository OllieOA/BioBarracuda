extends RigidBody2D
class_name BaseEnemy

export var max_health := 100.0
export var biomass := 30.0
export var attack_cooldown := 1.0
var attack_cooled_down := true
export var eye_detection := false

export (NodePath) onready var body_sprite = get_node(body_sprite) as Sprite
export (NodePath) onready var flash_animator = get_node(flash_animator) as AnimationPlayer

export (NodePath) onready var ai = get_node(ai) as Node
export (NodePath) onready var health = get_node(health) as Node2D
export (NodePath) onready var detection_area = get_node(detection_area) as Area2D
export (NodePath) onready var sight_line = get_node(sight_line) as RayCast2D
export (Array, AIStateMachine.States) var allowed_states
export (AIStateMachine.States) var init_state
export (AIStateMachine.Behaviours) var behaviour = AIStateMachine.Behaviours.PASSIVE
export (AIStateMachine.Attacks) var attack_style = AIStateMachine.Attacks.RUSH

export var static_body := true

var killed := false
var sight_limit_degrees  # A scan range in the y (rotated with player)
var spawn_origin

# Drift AI stuff
var drift_active := false
var target_point: Vector2
var drift_point_reached := true
var drift_timer


func _ready() -> void:
	randomize()
	ai.init_ai(self, allowed_states, init_state)
	health.max_health = max_health
	health.my_body = self
	health.init_health()
	
	sight_limit_degrees = 20
	spawn_origin = global_position


func handle_hit(projectile_properties: ProjectileProperties, node):
	if node == self and not killed:
		health.handle_hit(projectile_properties.damage)
		flash_animator.play("DamageFlash")


func scan() -> bool:
	for deg in range(-sight_limit_degrees, sight_limit_degrees):
		sight_line.rotation = deg
		
		if sight_line.is_colliding() and sight_line.get_collider().is_in_group("barracuda"):
			return true
	return false


#func _on_DetectionArea_body_entered(body: Node) -> void:
#	if body.is_in_group("barracuda"):
#		attack()
#

func _physics_process(delta: float) -> void:
	if drift_active:
		
		if drift_timer == null:
			drift_timer = Timer.new()
			drift_timer.set_wait_time(10.0)
			add_child(drift_timer)
			drift_timer.connect("timeout", self, "_drift_timeout")
			drift_timer.start()
		
		if not drift_point_reached:
			if global_position.distance_to(target_point) < 50:
				drift_point_reached = true
			else:
				var heading_x = lerp(linear_velocity.normalized().x, global_position.direction_to(target_point).normalized().x, 0.1)
				var heading_y = lerp(linear_velocity.normalized().y, global_position.direction_to(target_point).normalized().y, 0.1)
				apply_central_impulse(800 * Vector2(heading_x, heading_y))
				var random_torque = 5000 * (2 * randf() - 1)
				apply_torque_impulse(random_torque)
				
		else:
			target_point = spawn_origin + Vector2(400 * randf(), 400 * randf())
			drift_point_reached = false


func attack():
	pass


func _drift_timeout():
	drift_point_reached = true
	drift_timer.start()














