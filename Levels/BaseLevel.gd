extends Node2D

onready var character = $BarracudaCollection/Barracuda

export (NodePath) onready var particles_layer = get_node(particles_layer) as Node2D
export (NodePath) onready var enemy_layer = get_node(enemy_layer) as Node2D
export (NodePath) onready var orb_layer = get_node(orb_layer) as Node2D
export (NodePath) onready var projectile_layer = get_node(projectile_layer) as Node2D
export (NodePath) onready var navigation_layer = get_node(navigation_layer) as Navigation2D

export (NodePath) onready var ambient_player = get_node(ambient_player) as AudioStreamPlayer


func _ready() -> void:
	ambient_player.play()
	GameControl.particles_layer = particles_layer
	GameControl.enemy_layer = enemy_layer
	GameControl.orb_layer = orb_layer
	GameControl.projectile_layer = projectile_layer
	GameControl.navigation_layer = navigation_layer
