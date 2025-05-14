class_name Level
extends Node2D

signal completed

var laser_collider: LaserCollider
var drag_and_drop: DragAndDrop
var sensors: Array[Sensor] = []


func _ready() -> void:
	laser_collider = LaserCollider.new()
	laser_collider.init(self)

	drag_and_drop = DragAndDrop.new()
	drag_and_drop.init(self)

	_init_sensors()


func _init_sensors() -> void:
	for node: Node2D in get_children():
		if node is Sensor:
			var sensor: Sensor = node
			sensor.activated.connect(_sensor_activated)
			sensors.push_back(sensor)


func _sensor_activated() -> void:
	if sensors.filter(_is_sensor_active).size() == sensors.size():
		completed.emit()


func _is_sensor_active(sensor: Sensor) -> bool:
	return sensor.is_active


func _physics_process(delta: float) -> void:
	drag_and_drop.physics_process(delta)


func _unhandled_input(event: InputEvent) -> void:
	drag_and_drop.unhandled_input(event)
