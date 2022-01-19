extends RigidBody2D
class_name BodySegment

export (NodePath) onready var front_pos_node = get_node(front_pos_node) as Position2D
export (NodePath) onready var rear_pos_node = get_node(rear_pos_node) as Position2D
export (NodePath) onready var body_sprite = get_node(body_sprite) as Sprite
export (NodePath) onready var collision_box = get_node(collision_box) as CollisionShape2D

var barracuda_reference

var segment_scenes: Dictionary
var my_type: String

var base_velocity: Vector2

var front_offset
var rear_offset

var front_pos
var rear_pos

var removing := false


func _ready() -> void:
	front_pos = front_pos_node.position
	rear_pos = rear_pos_node.position
	
	front_offset = front_pos - position
	rear_offset = rear_pos - position
	
	SignalBus.connect("barracuda_head_left", self, "_flip_true")
	SignalBus.connect("barracuda_head_right", self, "_flip_false")
	
	set_damp()
	
	# Build the type
	segment_scenes = {
		"BasicTurret": preload("res://Objects/SegmentChunks/BaseTurret.tscn")
	}
	
	if my_type != "":
		var segment_power = segment_scenes[my_type].instance()
		segment_power.init(1.0, Color("ecff43"))
		add_child(segment_power)
		
	barracuda_reference = get_tree().get_current_scene().get_node("BarracudaCollection/Barracuda")


#func _physics_process(delta: float) -> void:
#	var heading_direction = rear_pos_node.global_position.direction_to(front_pos_node.global_position)
#	print(heading_direction)
#	var slave_impulse = 1.0 * GameProgression.acceleration * barracuda_reference.heading.rotated(heading_direction.angle())
#	apply_central_impulse(slave_impulse)
#
#
#func _integrate_forces(state: Physics2DDirectBodyState) -> void:
#	if state.linear_velocity.length() > GameProgression.max_speed and barracuda_reference.speed_limited:
#		state.linear_velocity = state.linear_velocity.normalized() * GameProgression.max_speed


func _integrate_forces(state: Physics2DDirectBodyState) -> void:
	if GameControl.marked_for_deletion.has(self):
		GameControl.marked_for_deletion.erase(self)
		_handle_removal()
	
	if state.linear_velocity.length() > GameProgression.max_speed and barracuda_reference.speed_limited:
		state.linear_velocity = state.linear_velocity.normalized() * GameProgression.max_speed


func set_type(type):
	my_type = type


func set_damp() -> void:
	set_linear_damp(GameProgression.linear_damp_value)
	set_angular_damp(GameProgression.angular_damp_value)


func _flip_true() -> void:
	body_sprite.flip_v = true
	
	
func _flip_false() -> void:
	body_sprite.flip_v = false

	
func _handle_removal() -> void:
	
	# Get relevant semgnets
	var my_index = GameProgression.instanced_segments.find(self)	
	var my_joint = GameProgression.segment_joints_dict[self]
	
	var segment_forward = GameProgression.instanced_segments[my_index-1]
	var segment_rear = GameProgression.instanced_segments[my_index+1]
	var forward_joint = GameProgression.segment_joints_dict[segment_forward]
			
	var goal_global_position = global_position
	var goal_global_rotation = global_rotation
			
	# Remove from globals
	GameProgression.segment_joints_dict.erase(self)
	GameProgression.instanced_segments.erase(self)
	GameProgression.segment_list.remove(my_index)
			
	# Safely detatch joints
	forward_joint.rear_joint.set_node_a(NodePath(""))  # Detach from front
	my_joint.rear_joint.set_node_a(NodePath("")) # Detach from rear following piece

	# Disable my collision
	collision_box.disabled = true
	
	segment_rear.global_position = goal_global_position
	segment_rear.global_rotation = goal_global_rotation
	
	# Attach the replacement joint
	forward_joint.rear_joint.set_node_a(segment_rear.get_path())

	my_joint.queue_free()
	queue_free()
