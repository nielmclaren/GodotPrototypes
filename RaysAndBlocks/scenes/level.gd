class_name Level
extends Node2D

signal completed

var laserable_lookup: LaserableLookup
var sensors: Array[Sensor] = []


func _ready() -> void:
	laserable_lookup = LaserableLookup.new()
	laserable_lookup.init(self)

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
