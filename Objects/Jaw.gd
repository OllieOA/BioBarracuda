extends RigidBody2D


export (NodePath) onready var jaw_sprite = get_node(jaw_sprite) as Sprite
export (NodePath) onready var jaw_spring = get_node(jaw_spring) as DampedSpringJoint2D
export (NodePath) onready var jaw_pin = get_node(jaw_pin) as PinJoint2D
export (NodePath) onready var jaw_collider = get_node(jaw_collider) as CollisionShape2D

var attached := false
var flipped := false
var barracuda: RigidBody2D

func _ready() -> void:
	barracuda = self.get_parent()
	
	flipped = barracuda.flipped
	if flipped:
		jaw_sprite.flip_v = true
		jaw_spring.rotation_degrees = rotation_degrees + 180
#		jaw_pin.position.x = 50


func attach_jaw():
	if flipped:
		jaw_collider.position.y = -20
	
	global_rotation = barracuda.global_rotation
	global_position = barracuda.global_position
	jaw_spring.set_node_a(barracuda.get_path())
	jaw_pin.set_node_a(barracuda.get_path())
	attached = true
