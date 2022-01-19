extends Node

var player_projectile_layer: Node2D
var enemy_projectile_layer: Node2D


func _ready() -> void:
	randomize()
	SignalBus.connect("player_projectile_fired", self, "_handle_player_projectile")
	
	# Get projectile layer
	player_projectile_layer = get_tree().get_current_scene().get_node("ProjectileLayer/PlayerProjectileLayer")


func _handle_player_projectile(projectile_properties):
	var projectile = projectile_properties["instance"]
	projectile.projectile_properties = projectile_properties
	player_projectile_layer.add_child(projectile)
	projectile.global_position = projectile_properties["position"]
