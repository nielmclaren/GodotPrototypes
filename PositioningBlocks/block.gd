extends RigidBody2D

signal clicked

var held = false
var click_offset = Vector2.ZERO
var diameter = 0

func _ready():
	var half = $CollisionShape2D.get_shape().get_rect().size / 2
	diameter = sqrt(half.x * half.x + half.y * half.y)

func _input_event(_viewport, event, _shape_idx):
	if event is InputEventMouseButton \
			and event.button_index == MOUSE_BUTTON_LEFT \
			and event.pressed:
		click_offset = (get_global_mouse_position() - global_transform.origin).rotated(-rotation)
		clicked.emit(self)

func _physics_process(_delta):
	if held:
		var mouse = get_global_mouse_position()

		# Clicks further from the origin have a greater effect on the rotation.
		var rotation_delta = lerp(0.0, 0.4, click_offset.length() / diameter)

		rotation = rotate_toward(rotation, (mouse - global_transform.origin).angle() - click_offset.angle(), rotation_delta)
		global_transform.origin = mouse - click_offset.rotated(rotation)

func pickup():
	if held:
		return
	freeze = true
	held = true

func drop(impulse=Vector2.ZERO):
	if held:
		freeze = false
		apply_central_impulse(impulse.clampf(0, 4.0))
		held = false
		click_offset = Vector2.ZERO
