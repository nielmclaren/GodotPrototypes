extends Object

class_name BoolDebouncer

var value: bool = false
var updated: int = Time.get_ticks_msec()
const DELAY: int = 500

func get_value() -> bool:
	return value

func set_value(v:bool) -> void:
	var now:int = Time.get_ticks_msec()
	if value == v:
		updated = now
	elif now - updated > DELAY:
		value = v
