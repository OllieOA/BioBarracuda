extends Area2D
class_name Projectile

export (Resource) var projectile_properties = projectile_properties as ProjectileProperties
var direction: Vector2
var shot_ready := false

export (NodePath) onready var projectile_sprite = get_node(projectile_sprite) as Sprite 
export (NodePath) onready var projectile_collider = get_node(projectile_collider) as CollisionShape2D
export (NodePath) onready var shot_particles = get_node(shot_particles) as Particles2D
export (NodePath) onready var hit_noise = get_node(hit_noise) as AudioStreamPlayer2D
export (NodePath) onready var shot_noise = get_node(shot_noise) as AudioStreamPlayer2D

var play_shot_audio := true

var rng = RandomNumberGenerator.new()


func _ready() -> void:
	rng.randomize()
	direction = projectile_properties.instance_heading
	set_direction()
	set_collision()

	if play_shot_audio:
		var random_pew_stream = projectile_properties.pew_noise_list[rng.randi_range(0, 2)]
		shot_noise.stream = random_pew_stream
		shot_noise.play()
	
	var random_hit_stream = projectile_properties.hit_noise_list[rng.randi_range(0, 2)]
	hit_noise.stream = random_hit_stream


func _physics_process(delta: float) -> void:
	if shot_ready:
		var velocity = direction * projectile_properties.speed
		global_position += velocity * delta


func set_direction():
	var projectile_random = rng.randfn(0.0, projectile_properties.spread / 3)
	direction = direction.rotated(deg2rad(projectile_random))
	rotation = direction.angle()
	shot_ready = true


func set_collision():
	if projectile_properties.player_dun_shootin:
		# Player projectile
		self.set_collision_layer_bit(4, 0)
		self.set_collision_mask_bit(0, 0)
		self.set_collision_mask_bit(1, 0)
	else:
		# Enemy projectile
		self.set_collision_layer_bit(2, 0)
		self.set_collision_mask_bit(3, 0)


func _on_Projectile_body_entered(body: Node) -> void:
	if body.has_method("handle_hit"):
		body.handle_hit(projectile_properties, body)
		_projectile_hit()
	if body.is_in_group("CaveWalls"):
		_projectile_hit()


func _projectile_hit():
	projectile_properties.speed = 0
	projectile_sprite.hide()
	projectile_collider.disabled = true
	shot_particles.emitting = true
	hit_noise.play()
	
	yield(hit_noise, "finished")
	queue_free()
	
