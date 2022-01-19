extends Node2D

export (NodePath) onready var front_joint = get_node(front_joint) as PinJoint2D
export (NodePath) onready var rear_joint = get_node(rear_joint) as PinJoint2D
export (NodePath) onready var joint_sprite = get_node(joint_sprite) as Sprite

var front_offset
var rear_offset

func _ready() -> void:
	front_offset = front_joint.position - position
	rear_offset = rear_joint.position - position
