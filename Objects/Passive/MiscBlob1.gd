extends RigidBody2D


export var health := 100.0
export var biomass := 30.0
export (NodePath) onready var flash_animator = get_node(flash_animator) as AnimationPlayer

export (NodePath) onready var ai = get_node(ai) as Node2D

var killed := false

func _ready() -> void:
	randomize()
	ai.begin(self)


func handle_hit(projectile_properties: Dictionary, node):
	if node == self:
		flash_animator.play("DamageFlash")
		health -= projectile_properties["damage"]
		if health <= 0 and not killed:
			SignalBus.emit_signal("enemy_killed")
			_kill_self(self)
			killed = true
	
	
func _kill_self(node):
	print("KILLING SELF")
	OrbManager.generate_orbs(biomass, global_position)
	node.queue_free()
