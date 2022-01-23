extends RigidBody2D
class_name BodySegment

export var max_health := 200.0

export (NodePath) onready var front_pos_node = get_node(front_pos_node) as Position2D
export (NodePath) onready var rear_pos_node = get_node(rear_pos_node) as Position2D
export (NodePath) onready var body_sprite = get_node(body_sprite) as Sprite
export (NodePath) onready var collision_box = get_node(collision_box) as CollisionShape2D
export (NodePath) onready var health = get_node(health) as Node2D
export (NodePath) onready var flash_animator = get_node(flash_animator) as AnimationPlayer

var tail_scene
export (PackedScene) var joint
export (PackedScene) var bubble_particles

var front_offset
var rear_offset
var front_pos
var rear_pos

# Segment information properties
var segment_scenes: Dictionary
var my_type: int
var base_velocity: Vector2

# Segment handling properties
var modifying := false

var my_index: int
var my_joint: BodyJoint
var forward_joint: BodyJoint
var segment_forward: RigidBody2D
var segment_rear: BodySegment
		
var goal_global_position: Vector2
var goal_global_rotation: float

var head_node: RigidBody2D

var new_segment: BodySegment
var new_joint: BodyJoint
var segments_layer: Node2D
var joints_layer: Node2D

export (bool) var is_tail := false
var killed := false


func _ready() -> void:
	
	health.max_health = max_health
	health.my_body = self
	health.init_health()
	
	if is_tail:
		GameControl.tail_reference = self
	else:
		tail_scene = load("res://Objects/BodyTail.tscn")
	
	front_pos = front_pos_node.position
	rear_pos = rear_pos_node.position
	
	front_offset = front_pos - position
	rear_offset = rear_pos - position
	
	SignalBus.connect("barracuda_head_left", self, "_flip_true")
	SignalBus.connect("barracuda_head_right", self, "_flip_false")
	
	set_damp()
	
	if not is_tail:
#	var segment_power = segment_scenes[my_type].instance()
		call_deferred("_add_segment_power")
#		var segment_power = SegmentTypes.lookup[my_type].instance()
#		add_child(segment_power)
#		segment_power.add_to_group("player_segment")
		
	segments_layer = GameControl.barracuda_layer.get_node("BarracudaSegments")
	joints_layer = GameControl.barracuda_layer.get_node("BarracudaJoints")


func _add_segment_power():
	var segment_power = LoadReference.lookup[my_type].instance()
	add_child(segment_power)
	segment_power.add_to_group("player_segment")


func _integrate_forces(state: Physics2DDirectBodyState) -> void:
	if GameControl.marked_for_deletion.has(self):
		if GameControl.marked_for_deletion[0] == self and not modifying:
			GameControl.marked_for_deletion.erase(self)
			_handle_removal()
	
	if state.linear_velocity.length() > GameProgression.max_speed and GameControl.barracuda_reference.speed_limited:
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


func _kill_segment() -> void:
	# Disable my collision
	collision_box.disabled = true
	var bubble_particles_instance = bubble_particles.instance()
	GameControl.particles_layer.add_child(bubble_particles_instance)
	bubble_particles_instance.global_position = global_position
	my_joint.queue_free()
	queue_free()
	

func handle_hit(projectile_properties: ProjectileProperties, node):
	if node == self and not killed:
		print("HANDLING HIT")
		health.handle_hit(projectile_properties.damage)
		flash_animator.play("DamageFlash")


func _handle_removal() -> void:
	modifying = true
	
	if len(GameControl.instanced_segments) == 1:
		SignalBus.emit_signal("barracuda_died", self)
		_kill_segment()
		return
	
	# Get relevant semgnets
	my_index = GameControl.instanced_segments.find(self)
	my_joint = GameControl.segment_joints_dict[self]
	
	if my_index == 0:
		segment_forward = GameControl.barracuda_reference
	else:
		segment_forward = GameControl.instanced_segments[my_index-1]
	
	if my_index == len(GameControl.instanced_segments)-1:
		segment_rear = GameControl.tail_reference
	else:
		segment_rear = GameControl.instanced_segments[my_index+1]
	
	forward_joint = GameControl.segment_joints_dict[segment_forward]
	
	goal_global_position = global_position
	goal_global_rotation = global_rotation
	
	# Remove from globals
	GameControl.segment_joints_dict.erase(self)
	GameControl.instanced_segments.erase(self)
	GameControl.segment_list.remove(my_index)

	# Safely detatch joints
	forward_joint.rear_joint.set_node_a(NodePath(""))  # Detach from front
	my_joint.rear_joint.set_node_a(NodePath("")) # Detach from rear following piece

	_kill_segment()
	
	segment_rear.global_position = goal_global_position
	segment_rear.global_rotation = goal_global_rotation
	
	# Attach the replacement joint
	forward_joint.rear_joint.set_node_a(segment_rear.get_path())
	
	modifying = false


func _add_and_connect_segment(segment: BodySegment, attaching_joint: BodyJoint, head_or_tail=false) -> BodySegment:
	segments_layer.add_child(segment)
	segment.global_position = attaching_joint.global_position + attaching_joint.rear_offset + segment.rear_offset
	attaching_joint.rear_joint.set_node_a(segment.get_path()) 
	if not head_or_tail:
		GameControl.instanced_segments.append(segment)
	return segment


func _add_new_joint(connecting_segment: RigidBody2D) -> BodyJoint:
	var attaching_joint = joint.instance()
	joints_layer.add_child(attaching_joint)
	
	attaching_joint.global_position = connecting_segment.global_position + connecting_segment.rear_offset - attaching_joint.front_offset
	attaching_joint.front_joint.set_node_a(connecting_segment.get_path())
	
	GameControl.segment_joints_dict[connecting_segment] = attaching_joint
	return attaching_joint
