extends Node2D

class_name Interactible

signal drag_start

enum MouseLocation { NONE, MOUNT, FIXTURE }

var interactible_scene: PackedScene

var drag_and_drop: DragAndDrop:
	get():
		return drag_and_drop
	set(v):
		drag_and_drop = v

var mount: StaticBody2D
var fixture: StaticBody2D

var initial_fixture_rotation: float = 0

var is_mouse_over:bool = false
var is_rotating: bool = false
var is_drag_original: bool = false
var is_drag_ghost: bool = false
var is_reverting: bool = false

var click_offset: Vector2 = Vector2.ZERO

func _ready() -> void:
	interactible_scene = load(scene_file_path) as PackedScene

	mount = $Mount
	fixture = $Fixture

	mount.input_pickable = true
	mount.add_collision_exception_with(fixture)
	mount.set_collision_layer_value(Constants.CollisionLayer.DEFAULT, true)
	mount.set_collision_layer_value(Constants.CollisionLayer.MOUNTS, true)
	mount.set_collision_layer_value(Constants.CollisionLayer.FIXTURES, false)
	mount.set_collision_layer_value(Constants.CollisionLayer.LASERS, false)
	mount.set_collision_layer_value(Constants.CollisionLayer.REVERSE_CAST, false)
	mount.set_collision_mask_value(Constants.CollisionLayer.DEFAULT, false)
	mount.set_collision_mask_value(Constants.CollisionLayer.MOUNTS, true)
	mount.set_collision_mask_value(Constants.CollisionLayer.FIXTURES, false)
	mount.set_collision_mask_value(Constants.CollisionLayer.LASERS, false)
	mount.set_collision_mask_value(Constants.CollisionLayer.REVERSE_CAST, false)
	mount.input_event.connect(_input_event)

	fixture.input_pickable = true
	fixture.add_collision_exception_with(mount)
	fixture.set_collision_layer_value(Constants.CollisionLayer.DEFAULT, true)
	fixture.set_collision_layer_value(Constants.CollisionLayer.MOUNTS, false)
	fixture.set_collision_layer_value(Constants.CollisionLayer.FIXTURES, true)
	fixture.set_collision_layer_value(Constants.CollisionLayer.LASERS, true)
	fixture.set_collision_layer_value(Constants.CollisionLayer.REVERSE_CAST, false)
	fixture.set_collision_mask_value(Constants.CollisionLayer.DEFAULT, false)
	fixture.set_collision_mask_value(Constants.CollisionLayer.MOUNTS, false)
	fixture.set_collision_mask_value(Constants.CollisionLayer.FIXTURES, true)
	fixture.set_collision_mask_value(Constants.CollisionLayer.LASERS, false)
	fixture.set_collision_mask_value(Constants.CollisionLayer.REVERSE_CAST, false)
	fixture.input_event.connect(_input_event)

	if initial_fixture_rotation != 0:
		fixture.rotation = initial_fixture_rotation
		initial_fixture_rotation = 0
	else:
		fixture.rotation = rotation
	rotation = 0

	mount.mouse_entered.connect(_mouse_entered)
	mount.mouse_exited.connect(_mouse_exited)
	fixture.mouse_entered.connect(_mouse_entered)
	fixture.mouse_exited.connect(_mouse_exited)

func _physics_process(_delta: float) -> void:
	if !GlobalState.is_game_input_enabled:
		return

	if is_rotating:
		fixture.rotation = rotate_toward(fixture.rotation, (get_global_mouse_position() - global_position).angle() - click_offset.angle(), 1)
		invalidate()

func is_colliding() -> bool:
	return is_mount_colliding()

func is_mount_colliding() -> bool:
	return mount and mount.test_move(mount.global_transform, Vector2.ZERO, null, 0.08, true)

func is_fixture_colliding() -> bool:
	return fixture and fixture.test_move(fixture.global_transform, Vector2.ZERO, null, 0.08, true)

func add_collision_exception_with(interactible: Interactible) -> void:
	mount.add_collision_exception_with(interactible.mount)
	fixture.add_collision_exception_with(interactible.mount)
	mount.add_collision_exception_with(interactible.fixture)
	fixture.add_collision_exception_with(interactible.fixture)

func set_is_drag_original(v: bool) -> void:
	is_drag_original = v
	invalidate()

func set_is_drag_ghost(v: bool) -> void:
	is_drag_ghost = v
	invalidate()

func set_is_reverting(v: bool) -> void:
	is_reverting = v

	mount.set_collision_layer_value(Constants.CollisionLayer.DEFAULT, false)
	mount.set_collision_layer_value(Constants.CollisionLayer.MOUNTS, false)
	mount.set_collision_layer_value(Constants.CollisionLayer.FIXTURES, false)
	mount.set_collision_layer_value(Constants.CollisionLayer.LASERS, false)
	mount.set_collision_layer_value(Constants.CollisionLayer.REVERSE_CAST, false)
	fixture.set_collision_layer_value(Constants.CollisionLayer.DEFAULT, false)
	fixture.set_collision_layer_value(Constants.CollisionLayer.MOUNTS, false)
	fixture.set_collision_layer_value(Constants.CollisionLayer.FIXTURES, false)
	fixture.set_collision_layer_value(Constants.CollisionLayer.LASERS, false)
	fixture.set_collision_layer_value(Constants.CollisionLayer.REVERSE_CAST, false)

	invalidate()

func invalidate() -> void:
	drag_and_drop.invalidate()

func validate() -> void:
	if is_reverting:
		return

	if is_mount_colliding():
		if is_drag_original:
			_mount_rgba(1.0, 0.2, 0.2, 0.7)
		elif is_drag_ghost:
			_mount_rgba(1.0, 0.2, 0.2, 0.7)
		else:
			_mount_rgba(1.0, 0.2, 0.2, 1.0)
	else:
		if is_drag_original:
			_mount_rgba(1.0, 1.0, 1.0, 0.7)
		elif is_drag_ghost:
			_mount_rgba(1.0, 1.0, 1.0, 0.7)
		else:
			_mount_rgba(1.0, 1.0, 1.0, 1.0)

	if is_fixture_colliding():
		fixture.set_collision_layer_value(Constants.CollisionLayer.LASERS, false)
		if is_drag_original:
			_fixture_rgba(1.0, 0.2, 0.2, 0.7)
		elif is_drag_ghost:
			_fixture_rgba(1.0, 0.2, 0.2, 0.7)
		else:
			_fixture_rgba(1.0, 0.2, 0.2, 1.0)
	else:
		if is_drag_original:
			fixture.set_collision_layer_value(Constants.CollisionLayer.LASERS, false)
			_fixture_rgba(1.0, 1.0, 1.0, 0.7)
		elif is_drag_ghost:
			fixture.set_collision_layer_value(Constants.CollisionLayer.LASERS, true)
			_fixture_rgba(1.0, 1.0, 1.0, 0.7)
		else:
			fixture.set_collision_layer_value(Constants.CollisionLayer.LASERS, true)
			_fixture_rgba(1.0, 1.0, 1.0, 1.0)

func _mouse_entered() -> void:
	if !GlobalState.is_game_input_enabled:
		return

	is_mouse_over = true
	_refresh_cursor()

	# TODO: Shouldn't force all interactibles to validate.
	invalidate()

func _mouse_exited() -> void:
	# Hovering mount and fixture will generate two enter events and leaving one for the other will generate an exit event.
	# So check whether we're still hovering mount or fixture.
	is_mouse_over = _get_mouse_location() != MouseLocation.NONE

	_refresh_cursor()

	# TODO: Shouldn't force all interactibles to validate.
	invalidate()

func _refresh_cursor() -> void:
	if is_drag_ghost:
		CursorManager.cursor_set_shape(Input.CURSOR_DRAG)
	elif is_rotating:
		CursorManager.cursor_set_shape(Input.CURSOR_CROSS)
	elif is_mouse_over:
		var mouse_location: MouseLocation = _get_mouse_location()
		match mouse_location:
			MouseLocation.MOUNT:
				CursorManager.cursor_set_shape(Input.CURSOR_DRAG)
			MouseLocation.FIXTURE:
				CursorManager.cursor_set_shape(Input.CURSOR_CROSS)
			MouseLocation.NONE:
				CursorManager.cursor_set_shape(Input.CURSOR_ARROW)
	else:
		CursorManager.cursor_set_shape(Input.CURSOR_ARROW)

func _get_mouse_location() -> MouseLocation:
	var mount_rect: Rect2 = ($Mount/CollisionShape2D as CollisionShape2D).shape.get_rect()
	if mount_rect.has_point(mount.get_local_mouse_position()):
		return MouseLocation.MOUNT
	var fixture_rect: Rect2 = ($Fixture/CollisionShape2D as CollisionShape2D).shape.get_rect()
	if fixture_rect.has_point(fixture.get_local_mouse_position()):
		return MouseLocation.FIXTURE
	return MouseLocation.NONE

func _input_event(viewport: Viewport, event: InputEvent, _shape_idx: int) -> void:
	if event is InputEventMouseButton:
		var mouse_event: InputEventMouseButton = event
		if mouse_event.button_index == MOUSE_BUTTON_LEFT and mouse_event.pressed:
			_mouse_pressed()
			viewport.set_input_as_handled()

func _mouse_pressed() -> void:
	if !GlobalState.is_game_input_enabled:
		return

	click_offset = fixture.get_local_mouse_position()

	var mouse_location: MouseLocation = _get_mouse_location()
	match mouse_location:
		MouseLocation.MOUNT:
			drag_start.emit(self)
		MouseLocation.FIXTURE:
			is_rotating = true
		MouseLocation.NONE:
			pass

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		var mouse_event: InputEventMouseButton = event
		if mouse_event.button_index == MOUSE_BUTTON_LEFT and !mouse_event.pressed:
			_mouse_released()

func _mouse_released() -> void:
	if !GlobalState.is_game_input_enabled:
		return

	is_rotating = false
	CursorManager.cursor_set_shape(Input.CURSOR_ARROW)

func _mount_rgba(r: float, g: float, b: float, a: float) -> void:
	mount.modulate.r = r
	mount.modulate.g = g
	mount.modulate.b = b
	mount.modulate.a = a

func _fixture_rgba(r: float, g: float, b: float, a: float) -> void:
	fixture.modulate.r = r
	fixture.modulate.g = g
	fixture.modulate.b = b
	fixture.modulate.a = a

func clone() -> Variant:
	var cloned: Interactible = interactible_scene.instantiate()
	cloned.global_transform = global_transform
	cloned.initial_fixture_rotation = fixture.rotation
	cloned.drag_and_drop = self.drag_and_drop
	return cloned
