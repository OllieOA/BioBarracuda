extends Node

# Barracuda information
var segment_list: Array
var instanced_segments: Array
var segment_joints_dict: Dictionary

# Segment management information
var marked_for_deletion: Array
var marked_for_addition: Dictionary
var barracuda_reference: RigidBody2D
var tail_reference: BodySegment

# Layer information
var orb_layer: Node2D
var enemy_layer: Node2D
var barracuda_layer: Node2D
var particles_layer: Node2D
var projectile_layer: Node2D


func _ready() -> void:
	marked_for_deletion = []
	marked_for_addition = {}
	
	segment_list = []
	instanced_segments = []
	segment_joints_dict = {}
