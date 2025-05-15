extends Node

const DEFAULT_CURSOR: Input.CursorShape = Input.CURSOR_ARROW

var curr_shape: Input.CursorShape = DEFAULT_CURSOR
var pending_shape: Input.CursorShape = DEFAULT_CURSOR
var clear_pending: bool = false
var shape_pending: bool = false


func _ready() -> void:
	#Input.set_custom_mouse_cursor(load("res://assets/cursor_arrow.png"), Input.CURSOR_ARROW, Vector2(5, 5))
	Input.set_custom_mouse_cursor(
		load("res://assets/cursor_translate.png"), Input.CURSOR_DRAG, Vector2(16, 16)
	)
	Input.set_custom_mouse_cursor(
		load("res://assets/cursor_rotate.png"), Input.CURSOR_CROSS, Vector2(16, 16)
	)

	CursorManager.cursor_set_shape(DEFAULT_CURSOR)


func _process(_delta: float) -> void:
	if shape_pending:
		if curr_shape != pending_shape:
			curr_shape = pending_shape
			Input.set_default_cursor_shape(pending_shape)

	elif clear_pending:
		curr_shape = DEFAULT_CURSOR
		Input.set_default_cursor_shape(DEFAULT_CURSOR)

	shape_pending = false
	clear_pending = false


func cursor_set_shape(shape: Input.CursorShape) -> void:
	pending_shape = shape
	shape_pending = true


func cursor_clear_shape() -> void:
	if curr_shape != DEFAULT_CURSOR:
		clear_pending = true
