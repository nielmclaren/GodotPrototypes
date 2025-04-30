extends Node

const DELAY: int = 50
var cursor_shape: Input.CursorShape = Input.CURSOR_ARROW
var updated: int = 0
var pending: bool = false

func _ready() -> void:
	Input.set_custom_mouse_cursor(load("res://cursor_arrow.png"), Input.CURSOR_ARROW, Vector2(5, 5))
	Input.set_custom_mouse_cursor(load("res://cursor_translate.png"), Input.CURSOR_DRAG, Vector2(16, 16))
	Input.set_custom_mouse_cursor(load("res://cursor_rotate.png"), Input.CURSOR_CROSS, Vector2(16, 16))

func _process(_delta: float) -> void:
	if pending:
		var now: int = Time.get_ticks_msec()
		if now - updated > DELAY:
			Input.set_default_cursor_shape(cursor_shape)
			pending = false

func cursor_set_shape(shape: Input.CursorShape) -> void:
	if cursor_shape != shape:
		cursor_shape = shape
		updated = Time.get_ticks_msec()
		pending = true
