extends VBoxContainer


export (NodePath) onready var overall_progress = get_node(overall_progress) as TextureProgress
export (NodePath) onready var biomass_progress = get_node(biomass_progress) as TextureProgress
export (NodePath) onready var max_segments_label = get_node(max_segments_label) as Label
export (NodePath) onready var tick_texture = get_node(tick_texture) as TextureRect

export (NodePath) onready var click_sound = get_node(click_sound) as AudioStreamPlayer
export (NodePath) onready var upgrade_button = get_node(upgrade_button) as TextureButton
export (NodePath) onready var upgrade_container = get_node(upgrade_container) as MarginContainer

export (NodePath) onready var option1_icon = get_node(option1_icon) as TextureRect
export (NodePath) onready var option2_icon = get_node(option2_icon) as TextureRect

export (NodePath) onready var option1_button = get_node(option1_button) as TextureButton
export (NodePath) onready var option2_button = get_node(option2_button) as TextureButton

var option1: int
var option2: int
var upgrade_selection: int

var ticks_updated := false


func _ready() -> void:
	upgrade_container.hide()
	upgrade_button.hide()
	SignalBus.connect("biomass_spent", self, "_update_max_biomass_cost")
	SignalBus.connect("max_segment_increase", self, "_update_max_segment_value")
	SignalBus.connect("segment_cost_increase", self, "_update_biomass_cost")
	SignalBus.connect("biomass_threshold_met", self, "_show_biomass_upgrade_button")
	SignalBus.connect("max_segments_updated", self, "_update_max_segment_value")
	
	
func update_ui():
	overall_progress.max_value = get_tree().get_current_scene().level_max_biomass
	_update_max_segment_value()
	_update_max_biomass_cost()
	
	print("DEBUG: MAX SEGMENTS ", GameProgression.curr_max_segments)
	print("DEBUG: CURR SEGMENTS ", GameProgression.n_segments)
	
	call_deferred("_add_ticks")
	
	
func _process(delta: float) -> void:
	overall_progress.value = GameProgression.overall_biomass_consumed
	biomass_progress.value = GameProgression.current_biomass
	
	_update_max_segment_value()


func _update_max_biomass_cost():
	biomass_progress.max_value = GameProgression.biomass_cost


func _update_max_segment_value():
	max_segments_label.text = "Segments Used: " + str(GameProgression.n_segments) + " of " + str(GameProgression.curr_max_segments)


func _add_ticks() -> void:
	if not ticks_updated:
		ticks_updated = true
		var tick_container = tick_texture.get_parent()
		for _n in range(GameProgression.max_segments_available_in_level-1):
			var next_tick = tick_texture.duplicate()
			tick_container.add_child(next_tick)


func _on_UpgradeButton_pressed() -> void:
#	get_tree().paused = true
#	SignalBus.emit_signal("upgrade_chosen")
	click_sound.play()
	option1 = GameProgression.rolled_segments[0]
	option2 = GameProgression.rolled_segments[1]
	var option1_texture = LoadReference.icon_lookup[option1]
	var option2_texture = LoadReference.icon_lookup[option2]
	
	var option1_tooltip = LoadReference.segment_tooltip[option1]
	var option2_tooltip = LoadReference.segment_tooltip[option2]
	
	option1_button.hint_tooltip = option1_tooltip
	option2_button.hint_tooltip = option2_tooltip
	
	option1_icon.texture = option1_texture
	option2_icon.texture = option2_texture

	if GameProgression.curr_max_segments == GameProgression.n_segments:
		option1_button.disabled = true
		option2_button.disabled = true
		
		option1_button.hint_tooltip = "Not enough biomass to\nsupport more segments!"
		option2_button.hint_tooltip = "Not enough biomass to\nsupport more segments!"

	upgrade_container.show()


func _show_biomass_upgrade_button() -> void:
	# Yag was here - TheYagich, 2022-01-23
	upgrade_button.show()


func _on_Option1_pressed() -> void:
	_close_upgrade_menu(option1)


func _on_Option2_pressed() -> void:
	_close_upgrade_menu(option2)


func _on_Heal_pressed() -> void:
	GameControl.barracuda_reference.handle_heal()
	_close_upgrade_menu(-1)
	
	
func _close_upgrade_menu(option):
#	get_tree().paused = false
	SignalBus.emit_signal("upgrade_purchased", option)
	upgrade_button.hide()
	upgrade_container.hide()
