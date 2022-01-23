extends Node

var player_projectile_layer: Node2D
var enemy_projectile_layer: Node2D


func _ready() -> void:
	randomize()
	SignalBus.connect("player_projectile_fired", self, "_handle_player_projectile")
	SignalBus.connect("enemy_projectile_fired", self, "_handle_enemy_projectile")
	
	# Get projectile layer
	player_projectile_layer = get_tree().get_current_scene().get_node("ProjectileLayer/PlayerProjectileLayer")
	enemy_projectile_layer = get_tree().get_current_scene().get_node("ProjectileLayer/EnemyProjectileLayer")


func _handle_player_projectile(projectile_instance: Projectile):
	projectile_instance.projectile_properties.player_dun_shootin = true
	projectile_instance.global_position = projectile_instance.projectile_properties.instance_position
	player_projectile_layer.add_child(projectile_instance)


func _handle_enemy_projectile(projectile_instance: Projectile):
	projectile_instance.projectile_properties.player_dun_shootin = false
	projectile_instance.global_position = projectile_instance.projectile_properties.instance_position
	enemy_projectile_layer.add_child(projectile_instance)

