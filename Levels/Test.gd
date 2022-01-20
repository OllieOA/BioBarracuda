extends Node2D

onready var velocity_label = $CanvasLayer/VelocityLabel
onready var data_label = $CanvasLayer/DataLabel
onready var character = $BarracudaCollection/Barracuda

export (NodePath) onready var particles_layer = get_node(particles_layer) as Node2D
export (NodePath) onready var enemy_layer = get_node(enemy_layer) as Node2D
export (NodePath) onready var orb_layer = get_node(orb_layer) as Node2D
export (NodePath) onready var projectile_layer = get_node(projectile_layer) as Node2D


func _ready() -> void:
	GameControl.particles_layer = particles_layer
	GameControl.enemy_layer = enemy_layer
	GameControl.orb_layer = orb_layer
	GameControl.projectile_layer = projectile_layer


func _process(delta: float) -> void:
	velocity_label.set_text("Velocity: " + str(character.linear_velocity) + " total: " + str(character.linear_velocity.length()))
	data_label.set_text("Player global position: " + str(character.global_position))

