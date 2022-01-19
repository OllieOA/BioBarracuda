extends Node2D

onready var velocity_label = $CanvasLayer/VelocityLabel
onready var data_label = $CanvasLayer/DataLabel
onready var character = $BarracudaCollection/Barracuda


func _process(delta: float) -> void:
	velocity_label.set_text("Velocity: " + str(character.linear_velocity) + " total: " + str(character.linear_velocity.length()))

