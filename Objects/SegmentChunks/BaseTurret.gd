extends Node2D
class_name BaseTurret


export (PackedScene) var projectile_scene
export (Resource) var turret_properties = turret_properties as TurretProperties

export (NodePath) onready var bullet_spawn_pos = get_node(bullet_spawn_pos) as Position2D
export (NodePath) onready var turret_static_sprite = get_node(turret_static_sprite) as Sprite
export (NodePath) onready var turret_barrel_sprite = get_node(turret_barrel_sprite) as Sprite
export (NodePath) onready var cooldown_timer = get_node(cooldown_timer) as Timer

var projectile_instance
var my_segment: RigidBody2D
var shooting: bool


func _ready() -> void:
	my_segment = self.get_parent()
	add_to_group("player_segment")
	cooldown_timer.set_wait_time(turret_properties.shot_cooldown)


func _process(delta: float) -> void:
	turret_barrel_sprite.global_rotation = lerp(turret_barrel_sprite.global_rotation, (get_global_mouse_position() - global_position).angle(), turret_properties.rotation_factor)
	if shooting:
		shoot()
	
	
func _unhandled_input(event: InputEvent):
	if is_in_group("player_segment"):
		if event is InputEventMouseButton:
			if event.is_action_pressed("shoot") and event.is_pressed():
				shooting = true
			elif not event.is_pressed():
				shooting = false


func shoot():
	if cooldown_timer.is_stopped():
		# Attempt to shoot
		if GameProgression.current_energy >= turret_properties.shot_cost:
			GameProgression.current_energy -= turret_properties.shot_cost
			for n in range(turret_properties.projectiles_to_spawn):
				projectile_instance = _instantiate_bullet()
				if n != 0:
					projectile_instance.play_shot_audio = false
				SignalBus.emit_signal("player_projectile_fired", projectile_instance)
			cooldown_timer.start()


func _instantiate_bullet() -> Area2D:
	projectile_instance = projectile_scene.instance()
	var projectile_position = bullet_spawn_pos.global_position
	projectile_instance.projectile_properties.instance_position = projectile_position
	var projectile_heading = projectile_position.direction_to(get_global_mouse_position()).normalized()
	projectile_instance.projectile_properties.instance_heading = projectile_heading

	my_segment.apply_central_impulse(turret_properties.impulse * projectile_heading.rotated(PI))
	
	return projectile_instance
