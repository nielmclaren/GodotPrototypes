extends Interactible

class_name Mirror

var mirror_scene: PackedScene

func _ready() -> void:
	super._ready()

	mirror_scene = load(scene_file_path) as PackedScene

	drag_handle_radius = 32

	($Fixture/DefaultSprite as Sprite2D).show()
	($Fixture/HoverSprite as Sprite2D).hide()

func _mouse_entered() -> void:
	super._mouse_entered()

func _mouse_exited() -> void:
	super._mouse_exited()

func clone() -> Variant:
	var cloned: Mirror = mirror_scene.instantiate()
	cloned.global_transform = global_transform
	cloned.initial_fixture_rotation = fixture.rotation
	cloned.drag_and_drop = self.drag_and_drop
	return cloned
