extends Node2D

onready var character = $BarracudaCollection/Barracuda

export (NodePath) onready var particles_layer = get_node(particles_layer) as Node2D
export (NodePath) onready var enemy_layer = get_node(enemy_layer) as Node2D
export (NodePath) onready var orb_layer = get_node(orb_layer) as Node2D
export (NodePath) onready var projectile_layer = get_node(projectile_layer) as Node2D
export (NodePath) onready var player_projectile_layer = get_node(player_projectile_layer) as Node2D
export (NodePath) onready var enemy_projectile_layer = get_node(enemy_projectile_layer) as Node2D
export (NodePath) onready var navigation_layer = get_node(navigation_layer) as Navigation2D
export (NodePath) onready var canvas_layer = get_node(canvas_layer) as CanvasLayer

export (NodePath) onready var ambient_player = get_node(ambient_player) as AudioStreamPlayer

# CanvasLayerElements
export (NodePath) onready var progress_bars = get_node(progress_bars) as VBoxContainer
export (NodePath) onready var end_prompt = get_node(end_prompt) as MarginContainer
export (NodePath) onready var end_prompt_label = get_node(end_prompt_label) as Label
export (NodePath) onready var yes_button = get_node(yes_button) as TextureButton
export (NodePath) onready var no_button = get_node(no_button) as TextureButton

export (float) var level_max_biomass := 1000.0
export (int) var max_segments := 4


func _ready() -> void:
	end_prompt_label.text = "You are not yet strong enough\nto brave the ocean"
	yes_button.disabled = true
	ambient_player.play()
	GameControl.particles_layer = particles_layer
	GameControl.enemy_layer = enemy_layer
	GameControl.orb_layer = orb_layer
	GameControl.projectile_layer = projectile_layer
	GameControl.navigation_layer = navigation_layer
	
	GameProgression.max_segments_available_in_level = max_segments
	SignalBus.connect("barracuda_dead", self, "_stop_game")
	SignalBus.connect("level_unlocked", self, "_unlock_exit")
	call_deferred("_deferred_ready")


func _deferred_ready():
	progress_bars.update_ui()
	end_prompt.hide()
	GameProgression.enter_level()
	ProjectileManager.player_projectile_layer = player_projectile_layer
	ProjectileManager.enemy_projectile_layer = enemy_projectile_layer
	OrbManager.orb_layer_reference = get_tree().get_current_scene().get_node("OrbLayer")
	

func _on_GoalArea_body_entered(body: Node) -> void:
	# Prompt
	end_prompt.show()


func _on_No_pressed() -> void:
	end_prompt.hide()


func _on_Yes_pressed() -> void:
	_stop_game()
	SceneTransition.goto_scene("res://Assets/Level/Title/WinScreen.tscn")


func _stop_game() -> void:
	for child in canvas_layer.get_children():
		child.hide()


func _unlock_exit():
	yes_button.disabled = false
	end_prompt_label.text = "You now have the power to\nsurvive in the ocean!"
