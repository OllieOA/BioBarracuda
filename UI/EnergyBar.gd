extends VBoxContainer


export (NodePath) onready var energy_bar = get_node(energy_bar) as TextureProgress


func _ready() -> void:
	SignalBus.connect("properties_updated", self, "_update_properties")
	_update_properties()


func _process(delta: float) -> void:
	energy_bar.value = GameProgression.current_energy


func _update_properties():
	energy_bar.max_value = GameProgression.max_energy
