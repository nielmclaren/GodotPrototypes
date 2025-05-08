extends Interactible

class_name PrismTriangle

var prism_scene: PackedScene

func _ready() -> void:
	super._ready()

	prism_scene = load(scene_file_path) as PackedScene

	drag_handle_radius = 32

func clone() -> Variant:
	var cloned: PrismTriangle = prism_scene.instantiate()
	cloned.global_transform = global_transform
	cloned.initial_fixture_rotation = fixture.rotation
	cloned.drag_and_drop = self.drag_and_drop
	return cloned
