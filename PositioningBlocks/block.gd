extends RigidBody2D

signal clicked

var held = false
var click_offset = Vector2.ZERO

func _input_event(_viewport, event, _shape_idx):
	if event is InputEventMouseButton \
			and event.button_index == MOUSE_BUTTON_LEFT \
			and event.pressed:
		click_offset = get_global_mouse_position() - global_transform.origin
		clicked.emit(self)

func _physics_process(_delta):
	if held:
		global_transform.origin = get_global_mouse_position() - click_offset

func pickup():
	if held:
		return
	freeze = true
	held = true

func drop(impulse=Vector2.ZERO):
	if held:
		freeze = false
		apply_central_impulse(impulse)
		held = false
		click_offset = Vector2.ZERO
