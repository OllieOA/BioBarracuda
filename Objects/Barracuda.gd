extends RigidBody2D


# Get components of barracude
var curr_speed: float

# Physics stuff
var heading: Vector2
var speed_limited: bool

export (NodePath) onready var front_pos = get_node(front_pos) as Position2D
export (NodePath) onready var rear_pos = get_node(rear_pos) as Position2D
export (NodePath) onready var top_sprite = get_node(top_sprite) as Sprite
export (NodePath) onready var jaw_node = get_node(jaw_node) as RigidBody2D  # Initialised only
export (NodePath) onready var head_collider = get_node(head_collider) as CollisionShape2D
export (NodePath) onready var absorb_area = get_node(absorb_area) as Area2D

var segments: Node2D
var joints: Node2D

# Contruction stuff

export (PackedScene) var tail
export (PackedScene) var segment
export (PackedScene) var joint
export (PackedScene) var jaw_scene

var rear_offset: Vector2

# Spring stuff
var bite_torque_init: float
var bite_torque: float
var spring_length_init: float
var spring_length: float
var flipped: bool
var biteable: bool

# Segment management
var mark_for_removal: Array


func _ready():
	mark_for_removal = []
	speed_limited = true
	biteable = true
	# Get metas
	segments = get_tree().get_current_scene().get_node("BarracudaCollection/BarracudaSegments")
	joints = get_tree().get_current_scene().get_node("BarracudaCollection/BarracudaJoints")
	bite_torque_init = 150000
	bite_torque = bite_torque_init
	
	# Construct physics properties
	set_linear_damp(GameProgression.linear_damp_value)
	set_angular_damp(GameProgression.angular_damp_value)

	SignalBus.connect("barracuda_head_left", self, "_head_left")
	SignalBus.connect("barracuda_head_right", self, "_head_right")
	
	rear_offset = rear_pos.global_position - global_position
	
	_add_segment(segment, "BasicTurret")
	_rebuild_barracuda()
	
	_add_jaw()
	
	
func _process(delta: float) -> void:
	var heading_direction = linear_velocity.dot(Vector2(1, 0))

	if heading_direction < -150 and not top_sprite.flip_v:
		SignalBus.emit_signal("barracuda_head_left")
		
	elif heading_direction > 150 and top_sprite.flip_v:
		SignalBus.emit_signal("barracuda_head_right")

	
func _head_left() -> void:
	flipped = true
	top_sprite.flip_v = true
	bite_torque = -bite_torque_init
	head_collider.position.y = 20
	_add_jaw()
	

func _head_right() -> void:
	flipped = false
	top_sprite.flip_v = false
	bite_torque = bite_torque_init
	head_collider.position.y = -20
	_add_jaw()


func _physics_process(delta: float) -> void:	
	if jaw_node != null:
		if not jaw_node.attached:
			jaw_node.attach_jaw()
	heading = Input.get_vector("left", "right", "up", "down")
	heading.normalized()

	apply_central_impulse(heading * GameProgression.acceleration)
	
	# Update rotation
	if heading != Vector2.ZERO:
		rotation = lerp_angle(rotation, heading.angle(), 0.1)


func _integrate_forces(state: Physics2DDirectBodyState) -> void:
	if state.linear_velocity.length() > GameProgression.max_speed and speed_limited:
		state.linear_velocity = state.linear_velocity.normalized() * GameProgression.max_speed


func _rebuild_barracuda():
	# Queuefree all of the segments
	_clear_segments_and_joints()
	global_rotation_degrees = 0
	
	# Create the head joint
	var head_joint = _add_new_joint(self)
	
	# Iterate over the list
	var curr_attaching_joint = head_joint
	var curr_segment = self
	var new_segment
	
	for segment in GameProgression.segment_list:
		var segment_base_scene = segment[0]
		var segment_type = segment[1]
		new_segment = segment_base_scene.instance()
		new_segment.set_type(segment_type)
		
		curr_segment = _add_and_connect_segment(new_segment, curr_attaching_joint)
		curr_attaching_joint = _add_new_joint(curr_segment)
		GameProgression.instanced_segments.append(curr_segment)
		GameProgression.segment_joints_dict[curr_segment] = curr_attaching_joint
	# Then add tail
	var tail_node = tail.instance()
	_add_and_connect_segment(tail_node, curr_attaching_joint)
	
	
#### SEGMENT ADDITION

func _add_segment(segment_to_add: PackedScene, type: String):
	GameProgression.segment_list.push_front([segment_to_add, type])
	GameProgression.calc_new_properties()
	_rebuild_barracuda()
	

func _add_new_joint(connecting_segment: RigidBody2D) -> RigidBody2D:
	var attaching_joint = joint.instance()
	joints.add_child(attaching_joint)
	attaching_joint.global_position = connecting_segment.global_position + connecting_segment.rear_offset - attaching_joint.front_offset
	attaching_joint.front_joint.set_node_a(connecting_segment.get_path())
#	attaching_joint.global_position = attaching_joint.global_position - (attaching_joint.global_position - global_position) / 5  # TRY THIS
	return attaching_joint


func _add_and_connect_segment(segment: RigidBody2D, attaching_joint: RigidBody2D) -> RigidBody2D:
	segments.add_child(segment)
	segment.global_position = attaching_joint.global_position + attaching_joint.rear_offset + segment.rear_offset
	attaching_joint.rear_joint.set_node_a(segment.get_path()) 
	
	return segment


func _clear_segments_and_joints() -> void:
	get_tree().call_group("barracuda_segments_and_joints", "queue_free")
	GameProgression.instanced_segments = []
	GameProgression.segment_joints_dict = {}


func _mark_remove_segment(segment: BodySegment) -> void:
	GameControl.marked_for_deletion.append(segment)


func _add_jaw() -> void:
	jaw_node.queue_free()
	
	jaw_node = jaw_scene.instance()
	add_child(jaw_node)

#### SEGMENT SUBTRACTION

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("increase"):
		_add_segment(segment, "BasicTurret")
	if event.is_action_pressed("bite") and biteable:
		_bite()
	if event.is_action_pressed("reset"):
		pass
	if event.is_action_pressed("temp_destroy_segment_2"):
		var seg2 = GameProgression.instanced_segments[1]
		_mark_remove_segment(seg2)


func _bite():
	biteable = false
	speed_limited = false
	var dash_direction = global_position.direction_to(get_global_mouse_position()).normalized()
	apply_central_impulse(GameProgression.dash_strength * dash_direction)
	apply_torque_impulse(-bite_torque)
	jaw_node.apply_torque_impulse(bite_torque * 0.5)
	yield(get_tree().create_timer(0.2), "timeout")
	speed_limited = true
	
	yield(get_tree().create_timer(GameProgression.dash_cooldown), "timeout")
	biteable = true


func _on_AbsorbArea_body_entered(body: Node) -> void:
	body.absorbing = true
	body.target = absorb_area


func _on_AbsorbArea_body_exited(body: Node) -> void:
	body.absorbing = false
	body.target = null
