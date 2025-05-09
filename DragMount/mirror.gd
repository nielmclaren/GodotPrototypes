extends Node2D

class_name Mirror

signal drag_start

enum CollisionLayer { DEFAULT = 1, MOUNTS = 2, FIXTURES = 3 }

var mirror_scene: PackedScene

var mount: StaticBody2D
var fixture: StaticBody2D

var initial_fixture_rotation: float = 0

var drag_and_drop: DragAndDrop

var is_rotating: bool = false
var is_drag_original: bool = false
var is_drag_ghost: bool = false
var is_reverting: bool = false

var click_offset: Vector2 = Vector2.ZERO

func set_drag_and_drop(v: DragAndDrop) -> void:
	drag_and_drop = v

func _ready() -> void:
	mirror_scene = load(scene_file_path) as PackedScene

	mount = $Mount
	fixture = $Fixture

	mount.input_pickable = true
	mount.add_collision_exception_with(fixture)
	mount.set_collision_layer_value(CollisionLayer.DEFAULT, true)
	mount.set_collision_layer_value(CollisionLayer.MOUNTS, true)
	mount.set_collision_layer_value(CollisionLayer.FIXTURES, false)
	mount.set_collision_mask_value(CollisionLayer.DEFAULT, false)
	mount.set_collision_mask_value(CollisionLayer.MOUNTS, true)
	mount.set_collision_mask_value(CollisionLayer.FIXTURES, false)
	mount.input_event.connect(_mount_input_event)

	fixture.input_pickable = true
	fixture.add_collision_exception_with(mount)
	fixture.set_collision_layer_value(CollisionLayer.DEFAULT, true)
	fixture.set_collision_layer_value(CollisionLayer.MOUNTS, false)
	fixture.set_collision_layer_value(CollisionLayer.FIXTURES, true)
	fixture.set_collision_mask_value(CollisionLayer.DEFAULT, false)
	fixture.set_collision_mask_value(CollisionLayer.MOUNTS, false)
	fixture.set_collision_mask_value(CollisionLayer.FIXTURES, true)
	fixture.input_event.connect(_fixture_input_event)

	if initial_fixture_rotation != 0:
		fixture.rotation = initial_fixture_rotation
	else:
		fixture.rotation = rotation
	rotation = 0

func _physics_process(_delta: float) -> void:
	if is_rotating:
		fixture.rotation = rotate_toward(fixture.rotation, (get_global_mouse_position() - global_position).angle() - click_offset.angle(), 1)
		invalidate()

func is_colliding() -> bool:
	return is_mount_colliding()

func is_mount_colliding():
	return mount and mount.test_move(mount.global_transform, Vector2.ZERO, null, 0.08, true)

func is_fixture_colliding():
	return fixture and fixture.test_move(fixture.global_transform, Vector2.ZERO, null, 0.08, true)

func add_collision_exception_with_mirror(mirror: Mirror) -> void:
	mount.add_collision_exception_with(mirror.mount)
	fixture.add_collision_exception_with(mirror.mount)
	mount.add_collision_exception_with(mirror.fixture)
	fixture.add_collision_exception_with(mirror.fixture)

func set_initial_fixture_rotation(v: float) -> void:
	initial_fixture_rotation = v

func set_is_drag_original(v: bool) -> void:
	is_drag_original = v
	invalidate()

func set_is_drag_ghost(v: bool) -> void:
	is_drag_ghost = v
	invalidate()

func set_is_reverting(v: bool) -> void:
	is_reverting = v

	mount.set_collision_layer_value(CollisionLayer.DEFAULT, false)
	mount.set_collision_layer_value(CollisionLayer.MOUNTS, false)
	mount.set_collision_layer_value(CollisionLayer.FIXTURES, false)
	fixture.set_collision_layer_value(CollisionLayer.DEFAULT, false)
	fixture.set_collision_layer_value(CollisionLayer.MOUNTS, false)
	fixture.set_collision_layer_value(CollisionLayer.FIXTURES, false)

	invalidate()

func invalidate() -> void:
	drag_and_drop.invalidate()

func validate() -> void:
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
		if is_drag_original:
			_fixture_rgba(1.0, 0.2, 0.2, 0.7)
		elif is_drag_ghost:
			_fixture_rgba(1.0, 0.2, 0.2, 0.7)
		else:
			_fixture_rgba(1.0, 0.2, 0.2, 1.0)
	else:
		if is_drag_original:
			_fixture_rgba(1.0, 1.0, 1.0, 0.7)
		elif is_drag_ghost:
			_fixture_rgba(1.0, 1.0, 1.0, 0.7)
		else:
			_fixture_rgba(1.0, 1.0, 1.0, 1.0)

func _mount_input_event(viewport: Viewport, event: InputEvent, _shape_idx: int) -> void:
	if event is InputEventMouseButton:
		var mouse_event: InputEventMouseButton = event
		if mouse_event.button_index == MOUSE_BUTTON_LEFT and mouse_event.pressed:
			_mount_mouse_pressed()
			viewport.set_input_as_handled()

func _mount_mouse_pressed() -> void:
	click_offset = mount.get_local_mouse_position()
	drag_start.emit(self)

func _fixture_input_event(viewport: Viewport, event: InputEvent, _shape_idx: int) -> void:
	if event is InputEventMouseButton:
		var mouse_event: InputEventMouseButton = event
		if mouse_event.button_index == MOUSE_BUTTON_LEFT and mouse_event.pressed:
			_fixture_mouse_pressed()
			viewport.set_input_as_handled()

func _fixture_mouse_pressed() -> void:
	click_offset = fixture.get_local_mouse_position()
	is_rotating = true

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		var mouse_event: InputEventMouseButton = event
		if mouse_event.button_index == MOUSE_BUTTON_LEFT and !mouse_event.pressed:
			_mouse_released()

func _mouse_released() -> void:
	is_rotating = false
	is_drag_original = false
	is_drag_ghost = false

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
	var cloned: Mirror = mirror_scene.instantiate()
	cloned.global_transform = global_transform
	cloned.set_initial_fixture_rotation(fixture.rotation)
	cloned.set_drag_and_drop(self.drag_and_drop)
	return cloned
