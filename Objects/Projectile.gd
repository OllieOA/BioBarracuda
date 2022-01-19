extends Area2D
class_name Projectile

var projectile_properties: Dictionary
var speed: float
var direction: Vector2
var damage: float
var spread: float
var shot_ready := false

export (NodePath) onready var projectile_sprite = get_node(projectile_sprite) as Sprite 
export (NodePath) onready var projectile_collider = get_node(projectile_collider) as CollisionShape2D
export (NodePath) onready var shot_particles = get_node(shot_particles) as Particles2D

var rng = RandomNumberGenerator.new()


func _ready() -> void:
	rng.randomize()
	speed = projectile_properties["speed"]
	direction = projectile_properties["direction"]
	damage = projectile_properties["damage"]
	spread = projectile_properties["spread"]
	set_direction()

	yield(get_tree().create_timer(speed / 2000), "timeout")
	self.queue_free()


func _physics_process(delta: float) -> void:
	if shot_ready:
		var velocity = direction * speed
		global_position += velocity * delta


func set_direction():
	var projectile_random = rng.randfn(0.0, spread / 3)
	direction = direction.rotated(deg2rad(projectile_random))
	rotation = direction.angle()
	shot_ready = true


func _on_Projectile_body_entered(body: Node) -> void:
	if body.has_method("handle_hit"):
		body.handle_hit(projectile_properties, body)
		_projectile_hit()
	if body.is_in_group("CaveWalls"):
		_projectile_hit()


func _projectile_hit():
	speed = 0
	projectile_sprite.hide()
	projectile_collider.disabled = true
	shot_particles.emitting = true
	yield(get_tree().create_timer(shot_particles.lifetime + 0.2), "timeout")
	queue_free()
	
