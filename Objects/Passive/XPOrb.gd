extends RigidBody2D


export (NodePath) onready var orb_animator = get_node(orb_animator) as AnimationPlayer
export (NodePath) onready var absorb_animator = get_node(absorb_animator) as AnimationPlayer
export (NodePath) onready var appearance_nodes = get_node(appearance_nodes) as Node2D

export (NodePath) onready var glow_sprite = get_node(glow_sprite) as Sprite
export (NodePath) onready var glow_light = get_node(glow_light) as Light2D

export (Color) var orb_modulation = Color("32ff00")
export var value := 20

var absorbing := false
var target: Area2D
var dir_to_mouth: Vector2
var impulse_to_apply: Vector2

func _ready() -> void:
	
	glow_sprite.modulate = orb_modulation
	glow_light.color = orb_modulation
	
	linear_damp = 2
	orb_animator.play("Pulse")
	set_value()
	
	# Set timer
	yield(get_tree().create_timer(1.0), "timeout")


func set_value():
	var scale_factor = clamp(value / 10, 0.5, 7)
	appearance_nodes.scale = appearance_nodes.scale * scale_factor


func absorb() -> void:
	# TODO: Fix weird flash based on animation sync
	SignalBus.emit_signal("biomass_consumed", value)
	orb_animator.stop(false)
	absorb_animator.play("Absorb")
	yield(absorb_animator, "animation_finished")
	queue_free()
	

func _physics_process(delta: float) -> void:
	if absorbing:
		dir_to_mouth = target.global_position - global_position
		impulse_to_apply = dir_to_mouth * 2000 / clamp((pow(dir_to_mouth.length(), 2)), 1, INF)
		apply_central_impulse(impulse_to_apply)
		
		if dir_to_mouth.length() < 100:
			absorb()
	
