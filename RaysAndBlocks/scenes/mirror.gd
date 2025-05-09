extends Interactible

class_name Mirror

var mirror_scene: PackedScene

func _ready() -> void:
	super._ready()

	mirror_scene = load(scene_file_path) as PackedScene

func clone() -> Variant:
	var cloned: Mirror = mirror_scene.instantiate()
	cloned.global_transform = global_transform
	cloned.initial_fixture_rotation = fixture.rotation
	cloned.drag_and_drop = self.drag_and_drop
	return cloned
