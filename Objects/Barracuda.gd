extends RigidBody2D


# Get components of barracuda
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
export (NodePath) onready var speed_noise = get_node(speed_noise) as AudioStreamPlayer

var segments_layer: Node2D
var joints_layer: Node2D

# Contruction stuff

export (PackedScene) var tail
export (PackedScene) var segment_scene
export (PackedScene) var joint
export (PackedScene) var jaw_scene

var rear_offset: Vector2

# Spring stuff
var modifying: bool
var my_joint: BodyJoint
var segment_rear: BodySegment
var new_joint: BodyJoint
var goal_global_position: Vector2
var goal_global_rotation: float
var new_segment: BodySegment

var bite_torque_init: float
var bite_torque: float
var spring_length_init: float
var spring_length: float
var flipped: bool
var biteable: bool
var killed := false

var rng = RandomNumberGenerator.new()


func _ready():
	rng.randomize()
	modifying = false
	GameControl.barracuda_reference = self
	GameControl.barracuda_layer = get_parent()
	speed_limited = true
	biteable = true
	
	# Get metas
	segments_layer = get_parent().get_node("BarracudaSegments")
	joints_layer = get_parent().get_node("BarracudaJoints")
	bite_torque_init = 150000
	bite_torque = bite_torque_init
	
	# Construct physics properties
	set_linear_damp(GameProgression.linear_damp_value)
	set_angular_damp(GameProgression.angular_damp_value)

	SignalBus.connect("barracuda_head_left", self, "_head_left")
	SignalBus.connect("barracuda_head_right", self, "_head_right")
	SignalBus.connect("segment_killed", self, "_end_game")
	SignalBus.connect("upgrade_purchased", self, "_add_segment")
	
	rear_offset = rear_pos.global_position - global_position
	
	_add_tail()
	_add_jaw()
	_add_init_segment(LoadReference.ThisIsAnEnumForWhatTheSegmentTypeCouldBe.BASIC_TURRET)
	

func _process(delta: float) -> void:
	if GameProgression.current_energy < GameProgression.max_energy:
		var new_energy = GameProgression.current_energy + GameProgression.energy_rechage_rate * delta
		GameProgression.current_energy = clamp(GameProgression.current_energy, new_energy, GameProgression.max_energy)
	
	
	var heading_direction = linear_velocity.dot(Vector2(1, 0))
#	var heading_speed = 

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
	
	if not killed:
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
#	var heading_vector = front_pos - rear_pos
	global_rotation = 0
	
	# Create the head joint
	var head_joint = _add_new_joint(self)
	
	# Iterate over the list
	var curr_attaching_joint = head_joint
	var curr_segment = self
	var new_segment
	
	for segment_n in range(len(GameControl.segment_list)):
		var segment_info = GameControl.segment_list[segment_n]
		var segment_base_scene = segment_info[0]
		var segment_type = segment_info[1]
		new_segment = segment_base_scene.instance()
		new_segment.set_type(segment_type)
		
		curr_segment = _add_and_connect_segment(new_segment, curr_attaching_joint)
		curr_segment.reset_health()
		curr_attaching_joint = _add_new_joint(curr_segment)
		
	# Then add tail
	var tail_node = tail.instance()
	_add_and_connect_segment(tail_node, curr_attaching_joint, true)
	
	
#### SEGMENT ADDITION
func _add_init_segment(type: int):
	var segment_properties = [segment_scene, type]
	GameControl.segment_list.push_back(segment_properties)
	GameProgression.calc_new_properties()
	
	_rebuild_barracuda()
	
	
func _add_segment(type: int):
	
	if type >= 0:
		var segment_properties = [segment_scene, type]
		GameControl.segment_list.push_back(segment_properties)
		GameProgression.calc_new_properties()
		_rebuild_barracuda()
		

func _add_new_joint(connecting_segment: RigidBody2D) -> RigidBody2D:
	var attaching_joint = joint.instance()
	joints_layer.add_child(attaching_joint)
	
	attaching_joint.global_position = (connecting_segment.global_position + connecting_segment.rear_offset - attaching_joint.front_offset)
	attaching_joint.front_joint.set_node_a(connecting_segment.get_path())
	
	GameControl.segment_joints_dict[connecting_segment] = attaching_joint
	return attaching_joint


func _add_and_connect_segment(segment: RigidBody2D, attaching_joint: RigidBody2D, head_or_tail=false) -> RigidBody2D:
	segments_layer.add_child(segment)
	segment.global_position = (attaching_joint.global_position + attaching_joint.rear_offset + segment.rear_offset)
	attaching_joint.rear_joint.set_node_a(segment.get_path()) 
	if not head_or_tail:
		GameControl.instanced_segments.append(segment)
	return segment


func _clear_segments_and_joints() -> void:
	# First populate the heal array
	GameControl.health_dict = {}
	for seg_n in range(len(GameControl.instanced_segments)):
		GameControl.health_dict[seg_n] = GameControl.instanced_segments[seg_n].health.health
	get_tree().call_group("barracuda_segments_and_joints", "queue_free")
	GameControl.instanced_segments = []
	GameControl.segment_joints_dict = {}


func mark_remove_segment(segment: BodySegment) -> void:
	GameControl.marked_for_deletion.append(segment)


func _add_jaw() -> void:
	jaw_node.queue_free()
	jaw_node = jaw_scene.instance()
	add_child(jaw_node)
	
	
func _add_tail() -> void:
	var head_joint = _add_new_joint(self)
	var tail_instance = tail.instance()
	var _tail_reference = _add_and_connect_segment(tail_instance, head_joint, true)


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("bite") and biteable:
		_bite()
	if event.is_action_pressed("reset"):
		_rebuild_barracuda()


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
	if body.is_in_group("orbs"):
		body.absorbing = true
		body.target = absorb_area


func _on_AbsorbArea_body_exited(body: Node) -> void:
	if body.is_in_group("orbs"):
		body.absorbing = false
		body.target = null


func handle_heal():
	for segment in GameControl.instanced_segments:
		if not segment.is_tail:
			segment.handle_heal()


func handle_hit(damage, node) -> void:
	if not killed:
		if node == self or node == GameControl.tail_reference:
			var individual_damage = damage / len(GameControl.instanced_segments)
			for segment in GameControl.instanced_segments:
				segment.handle_hit(individual_damage, segment)


func _end_game():
	if len(GameControl.instanced_segments) == 0:
		killed = true
		GameControl.tail_reference.apply_central_impulse(Vector2(rng.randf() * 800, rng.randf() * 800))
		GameControl.barracuda_reference.apply_central_impulse(Vector2(rng.randf() * 800, rng.randf() * 800))
		
		GameControl.tail_reference.applied_force = Vector2(0, 980/2)
		GameControl.barracuda_reference.applied_force = Vector2(0, 980/2)
		
		SignalBus.emit_signal("barracuda_dead")
