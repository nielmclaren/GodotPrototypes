extends Node2D

@export var laser_scene: PackedScene

var laser:Laser = null

func _ready() -> void:
	laser = laser_scene.instantiate()
	laser.add_exception($Emitter as CollisionObject2D)
	add_child(laser)

func _process(_delta:float) -> void:
	var emitter:PathFollow2D = $Emitter/Path2D/PathFollow2D
	laser.position = emitter.global_position
	laser.rotation = emitter.global_rotation


func _unhandled_input(event:InputEvent) -> void:
	if event is InputEventMouseButton:
		var mouse_event:InputEventMouseButton = event
		if mouse_event.button_index == MOUSE_BUTTON_LEFT \
				and !mouse_event.pressed:
			DragManager.release()
