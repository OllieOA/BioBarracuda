extends Control


export (NodePath) onready var pulse_animator = get_node(pulse_animator) as AnimationPlayer


func _ready() -> void:
	pulse_animator.play("Pulse")


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("space"):
		SceneTransition.goto_scene("res://Levels/Level1.tscn")
