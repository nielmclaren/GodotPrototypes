extends RigidBody2D

class_name Block

signal clicked

var held:bool = false
var click_offset:Vector2 = Vector2.ZERO
var diameter:float = 0

func _ready() -> void:
	var collision_shape:CollisionShape2D = $CollisionShape2D
	var half:Vector2 = collision_shape.get_shape().get_rect().size / 2
	diameter = sqrt(half.x * half.x + half.y * half.y)

func _input_event(_viewport:Viewport, event:InputEvent, _shape_idx:int) -> void:
	if event is InputEventMouseButton:
		var mouse_event:InputEventMouseButton = event
		if mouse_event.button_index == MOUSE_BUTTON_LEFT and mouse_event.pressed:
			click_offset = (get_global_mouse_position() - global_transform.origin).rotated(-rotation)
			clicked.emit(self)

func _physics_process(_delta:float) -> void:
	if held:
		var mouse:Vector2 = get_global_mouse_position()

		# Clicks further from the origin have a greater effect on the rotation.
		var rotation_delta:float = lerp(0.0, 0.4, click_offset.length() / diameter)

		rotation = rotate_toward(rotation, (mouse - global_transform.origin).angle() - click_offset.angle(), rotation_delta)
		global_transform.origin = mouse - click_offset.rotated(rotation)

func pickup() -> void:
	if held:
		return
	freeze = true
	held = true

func drop(impulse:Vector2 = Vector2.ZERO) -> void:
	if held:
		freeze = false
		apply_central_impulse(impulse.clampf(0, 4.0))
		held = false
		click_offset = Vector2.ZERO
