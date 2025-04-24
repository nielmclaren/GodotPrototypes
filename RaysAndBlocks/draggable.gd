extends Node

class_name Draggable

signal clicked

var parent:RigidBody2D
var held:bool = false
var click_offset:Vector2 = Vector2.ZERO
var diameter:float = 0

func _ready() -> void:
	parent = get_parent()
	
	var collision_shape:CollisionShape2D = parent.get_node("CollisionShape2D")
	var half:Vector2 = collision_shape.get_shape().get_rect().size / 2
	diameter = sqrt(half.x * half.x + half.y * half.y)

func input_event(_viewport:Viewport, event:InputEvent, _shape_idx:int) -> void:
	if event is InputEventMouseButton:
		var mouse_event:InputEventMouseButton = event
		if mouse_event.button_index == MOUSE_BUTTON_LEFT and mouse_event.pressed:
			click_offset = (parent.get_global_mouse_position() - parent.global_transform.origin).rotated(-parent.rotation)
			clicked.emit(self)

func _physics_process(_delta:float) -> void:
	if held:
		var mouse:Vector2 = parent.get_global_mouse_position()

		# Clicks further from the origin have a greater effect on the rotation.
		var rotation_delta:float = _lerpf(0.4 * diameter, diameter, 0.0, 1.0, click_offset.length())
		parent.rotation = rotate_toward(parent.rotation, (mouse - parent.global_transform.origin).angle() - click_offset.angle(), rotation_delta)

		parent.global_transform.origin = mouse - click_offset.rotated(parent.rotation)

func pickup() -> void:
	if held:
		return
	parent.freeze = true
	held = true

func drop(impulse:Vector2 = Vector2.ZERO) -> void:
	if held:
		parent.freeze = false
		parent.apply_central_impulse(impulse.clampf(0, 4.0))
		held = false
		click_offset = Vector2.ZERO

func _lerpf(in_low:float, in_high:float, out_low:float, out_high:float, value:float) -> float:
	return clampf((value - in_low) / (in_high - in_low) * (out_high - out_low) + out_low, out_low, out_high)
