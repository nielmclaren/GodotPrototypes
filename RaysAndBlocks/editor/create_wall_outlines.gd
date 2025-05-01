@tool
extends EditorScript

var outline_scene:PackedScene

func _run() -> void:
	print("Running")
	outline_scene = load("res://wall_01_outline.tscn") as PackedScene

	var scene: Node2D = get_scene()
	var outline_parent: Node2D = scene.get_node("WallOutlines")
	if !outline_parent:
		print("No OutlineWalls")
		return

	var wall_parent: Node2D = scene.get_node("Walls")
	if !wall_parent:
		print("No Walls")
		return

	print("Traversing")
	var count: int = 0
	for node: Node2D in wall_parent.get_children():
		print("Visit")
		var outline: Node2D = outline_scene.instantiate()
		outline.transform = node.transform
		outline_parent.add_child(outline)
		outline.name = "WallOutline%02d" % (count + 1)
		outline.owner = scene
		count += 1

	print("Success")
