extends Node2D

export (NodePath) onready var health_bar = get_node(health_bar) as TextureProgress

var max_health : float
var health : float
var my_body
var health_bar_offset

func _ready() -> void:
	pass


func init_health() -> void:
	health_bar.max_value = max_health
	health = max_health
	health_bar.value = health
	
	health_bar_offset = global_position - my_body.global_position
	set_as_toplevel(true)


func _process(delta: float) -> void:
	if health_bar.value != health:
		# Why the check? Is it a setter? - ModgProg - 2022-01-24
		health_bar.value = health
	
	if health_bar.visible and health >= max_health - 0.1:
		health_bar.visible = false
	elif not health_bar.visible and health < max_health:
		health_bar.visible = true
	else:
		global_position = my_body.global_position + health_bar_offset


func handle_hit(damage):
	if health < damage:
		handle_kill()
		return
	health -= damage
	health_bar.value = health
	
	
func handle_heal():
	health = max_health
	health_bar.visible = false
	
	
func handle_kill():
	if my_body.is_in_group("barracuda_segments"):
		my_body.mark_remove_segment(my_body)
	else:
		my_body.killed = true
		my_body.queue_free()
		emit_signal("enemy_killed", my_body)
		OrbManager.generate_orbs(my_body.biomass, global_position)
	
