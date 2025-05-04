extends StaticBody2D

class_name Interactible

signal drag_start

var interactible_scene: PackedScene

# TODO: Change to Enum.
const STATE_DEFAULT: int = 0
const STATE_HOVER: int = 1
const STATE_GHOST: int = 2
const STATE_GHOST_REVERT: int = 3
const STATE_GHOST_COLLISION: int = 4

# Whether this body should be snapped to the grid.
var is_snapped: bool = true

var is_mouse_over:bool = false
var is_dragging: bool = false
var is_rotating: bool = false

# Remember the last valid rotation for reverting bad rotate actions.
var prev_rotation: float = 0

var click_offset: Vector2 = Vector2.ZERO

# Mouse presses within the drag handle radius initiate drag and drop. Outside of
# that radius they initiate rotations.
var drag_handle_radius: float = 0

func _enter_tree() -> void:
	# Use transform notifications for snapping to a grid.
	set_notify_transform(true)

func _notification(what: int) -> void:
	if what == NOTIFICATION_TRANSFORM_CHANGED and is_snapped:
		position = snapped(position, Constants.CELL_SIZE)

func _ready() -> void:
	input_pickable = true

	interactible_scene = load(scene_file_path) as PackedScene

	prev_rotation = rotation

	mouse_entered.connect(_mouse_entered)
	mouse_exited.connect(_mouse_exited)

func _mouse_entered() -> void:
	is_mouse_over = true
	set_edit_state(STATE_HOVER)

func _mouse_exited() -> void:
	is_mouse_over = false
	if !is_dragging and !is_rotating:
		CursorManager.cursor_set_shape(Input.CURSOR_ARROW)
		set_edit_state(STATE_DEFAULT)

func _get_radius(shape: Shape2D) -> float:
	var size: Vector2 = shape.get_rect().size
	return size.length() / 2

func _physics_process(_delta: float) -> void:
	_update_mouse_cursor()

	if is_rotating:
		rotation = rotate_toward(rotation, (get_global_mouse_position() - global_position).angle() - click_offset.angle(), 1)

		var collision: KinematicCollision2D = move_and_collide(Vector2.ZERO, true)
		if collision:
			set_edit_state(STATE_GHOST_COLLISION)
		else:
			set_edit_state(STATE_HOVER)

func _update_mouse_cursor() -> void:
	if is_dragging:
		CursorManager.cursor_set_shape(Input.CURSOR_DRAG)

	elif is_rotating:
		CursorManager.cursor_set_shape(Input.CURSOR_CROSS)

	elif is_mouse_over:
		var mouse_dist: float = get_local_mouse_position().length()
		if mouse_dist < drag_handle_radius:
			CursorManager.cursor_set_shape(Input.CURSOR_DRAG)
		else:
			CursorManager.cursor_set_shape(Input.CURSOR_CROSS)

func _input_event(viewport: Viewport, event: InputEvent, _shape_idx: int) -> void:
	if event is InputEventMouseButton:
		var mouse_event: InputEventMouseButton = event
		if mouse_event.button_index == MOUSE_BUTTON_LEFT and mouse_event.pressed:
			_mouse_pressed()
			viewport.set_input_as_handled()

func _mouse_pressed() -> void:
	click_offset = get_local_mouse_position()

	var mouse_dist: float = get_local_mouse_position().length()
	if mouse_dist < drag_handle_radius:
		is_dragging = true
		drag_start.emit(self)
	else:
		is_rotating = true

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		var mouse_event: InputEventMouseButton = event
		if mouse_event.button_index == MOUSE_BUTTON_LEFT and !mouse_event.pressed:
			_mouse_released()

func _mouse_released() -> void:
	is_dragging = false
	is_rotating = false
	CursorManager.cursor_set_shape(Input.CURSOR_ARROW)

	set_edit_state(STATE_DEFAULT)

	var collision: KinematicCollision2D = move_and_collide(Vector2.ZERO, true)
	if collision:
		rotation = prev_rotation
	else:
		prev_rotation = rotation

func set_edit_state(state: int) -> void:
	match state:
		STATE_HOVER:
			modulate.a = 1.0
			modulate.r = 1.0
			modulate.g = 1.0
			modulate.b = 1.0
			is_snapped = true
			set_collision_layer_value(Constants.DEFAULT_COLLISION_LAYER, true)

		STATE_GHOST:
			modulate.a = 0.4
			modulate.r = 1.0
			modulate.g = 1.0
			modulate.b = 1.0
			is_snapped = true
			set_collision_layer_value(Constants.DEFAULT_COLLISION_LAYER, false)

		STATE_GHOST_COLLISION:
			modulate.a = 0.4
			modulate.r = 1.0
			modulate.g = 0.2
			modulate.b = 0.2
			is_snapped = true
			set_collision_layer_value(Constants.DEFAULT_COLLISION_LAYER, false)

		STATE_GHOST_REVERT:
			modulate.a = 0.4
			modulate.r = 1.0
			modulate.g = 0.2
			modulate.b = 0.2
			is_snapped = false
			set_collision_layer_value(Constants.DEFAULT_COLLISION_LAYER, false)

		_:
			modulate.a = 1.0
			modulate.r = 1.0
			modulate.g = 1.0
			modulate.b = 1.0
			is_snapped = true
			set_collision_layer_value(Constants.DEFAULT_COLLISION_LAYER, true)

func clone() -> Variant:
	var interactible: Interactible = interactible_scene.instantiate()
	return interactible
