extends Node2D

@export var laser_scene: PackedScene

var held_object:Block = null
var laser:Laser = null

func _ready() -> void:
	for node:Node2D in get_tree().get_nodes_in_group("pickable"):
		var block:Block = node
		block.clicked.connect(_on_pickable_clicked)

	laser = laser_scene.instantiate()
	laser.add_exception($Emitter as CollisionObject2D)
	add_child(laser)

func _process(_delta:float) -> void:
	var emitter:PathFollow2D = $Emitter/Path2D/PathFollow2D
	laser.position = emitter.global_position
	laser.rotation = emitter.global_rotation

func _on_pickable_clicked(object:Block) -> void:
	if !held_object:
		object.pickup()
		held_object = object

func _unhandled_input(event:InputEvent) -> void:
	if event is InputEventMouseButton:
		var mouse_event:InputEventMouseButton = event
		if mouse_event.button_index == MOUSE_BUTTON_LEFT \
				and held_object and !mouse_event.pressed:
			held_object.drop(Input.get_last_mouse_velocity())
			held_object = null
