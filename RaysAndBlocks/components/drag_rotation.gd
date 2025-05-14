class_name DragRotation
extends Node

@export var body: Node2D
@export var handle: Area2D

var is_mouse_over: bool = false
var is_rotating: bool = false
var click_offset: Vector2 = Vector2.ZERO


func _ready() -> void:
	handle.input_pickable = true
	handle.mouse_entered.connect(_mouse_entered)
	handle.mouse_exited.connect(_mouse_exited)
	handle.input_event.connect(_input_event)


func _physics_process(_delta: float) -> void:
	if !GlobalState.is_game_input_enabled:
		return

	if is_rotating:
		var to_mouse: Vector2 = body.get_global_mouse_position() - body.global_position
		body.rotation = rotate_toward(body.rotation, to_mouse.angle() - click_offset.angle(), 1)


func _mouse_entered() -> void:
	is_mouse_over = true
	CursorManager.cursor_set_shape(Input.CURSOR_CROSS)


func _mouse_exited() -> void:
	is_mouse_over = false
	if !is_rotating:
		CursorManager.cursor_set_shape(Input.CURSOR_ARROW)


func _input_event(viewport: Viewport, event: InputEvent, _shape_idx: int) -> void:
	if event is InputEventMouseButton:
		var mouse_event: InputEventMouseButton = event
		if mouse_event.button_index == MOUSE_BUTTON_LEFT and mouse_event.pressed:
			_mouse_pressed()
			viewport.set_input_as_handled()


func _mouse_pressed() -> void:
	if !GlobalState.is_game_input_enabled:
		return

	is_rotating = true
	click_offset = handle.get_local_mouse_position()


func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		var mouse_event: InputEventMouseButton = event
		if mouse_event.button_index == MOUSE_BUTTON_LEFT and !mouse_event.pressed:
			_mouse_released()


func _mouse_released() -> void:
	if !GlobalState.is_game_input_enabled:
		return

	if is_rotating:
		is_rotating = false
		CursorManager.cursor_set_shape(Input.CURSOR_ARROW)
