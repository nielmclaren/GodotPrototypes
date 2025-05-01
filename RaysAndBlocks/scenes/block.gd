extends Interactible

class_name Block

var block_scene: PackedScene

func _ready() -> void:
	block_scene = load(scene_file_path) as PackedScene

func clone() -> Block:
	var block: Block = block_scene.instantiate()
	block.rotation = rotation
	return block
