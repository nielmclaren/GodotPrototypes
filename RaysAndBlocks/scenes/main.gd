extends Node2D

var drag_and_drop: DragAndDrop

func _ready() -> void:
	drag_and_drop = DragAndDrop.new()
	drag_and_drop.init(self)

func _physics_process(delta: float) -> void:
	drag_and_drop.physics_process(delta)

func _unhandled_input(event: InputEvent) -> void:
	drag_and_drop.unhandled_input(event)
