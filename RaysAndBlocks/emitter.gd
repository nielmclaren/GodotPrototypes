extends StaticBody2D

class_name Emitter

func _ready() -> void:
	var follow:PathFollow2D = $Path2D/PathFollow2D
	follow.set_progress_ratio(0.0)
