extends Control

onready var settings_menu = $SettingsMenu
onready var settings_button = $SettingIconMargin/SettingsButton
onready var sfx_toggle = $SettingsMenu/SettingButtons/ToggleSFX
onready var music_toggle = $SettingsMenu/SettingButtons/ToggleMusic
onready var settings_tooltip = $SettingIconMargin/SettingsButton/SettingsLabelBase
onready var sfx_bus_id = AudioServer.get_bus_index("SFX")
onready var music_bus_id = AudioServer.get_bus_index("Music")
onready var menu_clicker = $MenuClick

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	settings_tooltip.hide()
	settings_menu.hide()
	settings_menu.mouse_filter = 2


func _on_SettingsButton_mouse_entered() -> void:
	settings_tooltip.show()


func _on_SettingsButton_mouse_exited() -> void:
	if not settings_button.pressed:
		settings_tooltip.hide()


func _on_ToggleSFX_pressed() -> void:
	menu_clicker.play()
	AudioServer.set_bus_mute(sfx_bus_id, not AudioServer.is_bus_mute(sfx_bus_id))


func _on_ToggleMusic_pressed() -> void:
	menu_clicker.play()
	AudioServer.set_bus_mute(music_bus_id, not AudioServer.is_bus_mute(music_bus_id))


func _on_SettingsButton_pressed() -> void:
	if settings_button.pressed:
		get_tree().paused = true
	else:
		get_tree().paused = false
	menu_clicker.play()
	settings_menu.visible = !settings_menu.visible
	if settings_menu.visible:
		settings_menu.set_mouse_filter(0)
	else:
		settings_menu.set_mouse_filter(2)

