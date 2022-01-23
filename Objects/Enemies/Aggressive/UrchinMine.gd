extends BaseEnemy

var cooldown_timer

func _ready() -> void:
	
	cooldown_timer = Timer.new()
	add_child(cooldown_timer)
	cooldown_timer.set_wait_time(attack_cooldown)
	cooldown_timer.one_shot = true
	cooldown_timer.connect("timeout", self, "_attack_cooled_down_timeout")


func attack() -> void:
	if attack_cooled_down:
		attack_cooled_down = false
		_spawn_projectiles()
		body_sprite.frame = 1
		
		cooldown_timer.start()


func _attack_cooled_down_timeout():
	attack_cooled_down = true

	
func _spawn_projectiles():
	var num_projectiles = 8
	var spawn_radius = 80
	var deg_increment = 360 / num_projectiles
	var curr_angle = 0
	var new_vector = Vector2.ZERO
	
	for n in range(num_projectiles):
		curr_angle += deg_increment
		new_vector = Vector2.ZERO + Vector2(spawn_radius, 0).rotated(deg2rad(curr_angle) + global_rotation)
		
		var projectile_instance = load(ProjectileProperties.new().lookup[ProjectileProperties.Type.URCHIN]).instance()
		var projectile_launch = global_position + new_vector
		
		if n != 0:
			projectile_instance.play_shot_audio = false
		projectile_instance.projectile_properties.instance_position = projectile_launch
		projectile_instance.projectile_properties.instance_heading = new_vector.normalized()
		
		SignalBus.emit_signal("enemy_projectile_fired", projectile_instance)
		
		
	yield(get_tree().create_timer(1.0), "timeout")
	body_sprite.frame = 0
