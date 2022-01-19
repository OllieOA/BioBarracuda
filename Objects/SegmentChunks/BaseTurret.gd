extends Node2D


export (PackedScene) var Bullet
export (NodePath) onready var bullet_spawn_pos = get_node(bullet_spawn_pos) as Position2D
export (NodePath) onready var turret_sprite = get_node(turret_sprite) as Sprite
export (NodePath) onready var cooldown_timer = get_node(cooldown_timer) as Timer


var turret_properties
var projectile_properties
var my_segment: RigidBody2D
var shooting: bool


func init(
	turret_rotation_factor := 1, 
	turret_modulation := Color("ffffff"), 
	turret_cooldown := 0.5,
	turret_impulse := 200.0,
	turret_number := 2,
	projectile_speed := 2000.0,
	projectile_damage := 20.0,
	projectile_spread := 10.0
	) -> void:
		
		turret_properties = {
			"rotation_factor": turret_rotation_factor,
			"modulation": turret_modulation,
			"cooldown": turret_cooldown,
			"impulse": turret_impulse,
			"number": turret_number
		}
		
		projectile_properties = {
			"speed": projectile_speed,
			"damage": projectile_damage,
			"spread": projectile_spread
		}


func _ready() -> void:
	turret_sprite.modulate = turret_properties["modulation"]
	my_segment = self.get_parent()
	cooldown_timer.set_wait_time(turret_properties["cooldown"])


func _process(delta: float) -> void:
	look_at(get_global_mouse_position())
	if shooting:
		_shoot()
	
	
func _input(event: InputEvent):
	if event is InputEventMouseButton:
		if event.is_action_pressed("shoot") and event.is_pressed():
			shooting = true
		elif not event.is_pressed():
			shooting = false


func _shoot():
	if cooldown_timer.is_stopped():
		for n in range(turret_properties["number"]):
			var properties = _instantiate_bullet()
			SignalBus.emit_signal("player_projectile_fired", properties)
		cooldown_timer.start()


func _instantiate_bullet() -> Area2D:
	var bullet_instance = Bullet.instance()
	var bullet_position = bullet_spawn_pos.global_position
	var bullet_direction = bullet_position.direction_to(get_global_mouse_position()).normalized()
	projectile_properties["position"] = bullet_position
	projectile_properties["direction"] = bullet_direction
	projectile_properties["instance"] = bullet_instance
	my_segment.apply_central_impulse(turret_properties["impulse"] * bullet_direction.rotated(PI))
	
	return projectile_properties
