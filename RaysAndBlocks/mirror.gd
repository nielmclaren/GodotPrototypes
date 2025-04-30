@tool
extends Interactible

class_name Mirror

var mirror_scene: PackedScene

func _ready() -> void:
	super._ready()

	mirror_scene = load(scene_file_path) as PackedScene

	drag_handle_radius = 0.4 * _get_radius(($CollisionShape2D as CollisionShape2D).shape)

func clone() -> Mirror:
	var mirror: Mirror = mirror_scene.instantiate()
	mirror.rotation = rotation
	return mirror
