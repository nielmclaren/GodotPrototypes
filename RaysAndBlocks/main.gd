extends Node2D

var outline_scene:PackedScene

var drag_and_drop: DragAndDrop

func _ready() -> void:
	drag_and_drop = DragAndDrop.new()
	drag_and_drop.init(self)

	outline_scene = load("res://wall_01_outline.tscn") as PackedScene

	var outline_parent: Node2D = $WallOutlines
	var wall_parent: Node2D = $Walls
	for node: Node2D in wall_parent.get_children():
		var outline: Node2D = outline_scene.instantiate()
		outline.transform = node.transform
		outline_parent.add_child(outline)

func _physics_process(delta: float) -> void:
	drag_and_drop.physics_process(delta)

func _unhandled_input(event: InputEvent) -> void:
	drag_and_drop.unhandled_input(event)
