extends RigidBody2D

func _ready() -> void:
	var follow:PathFollow2D = $Path2D/PathFollow2D
	follow.set_progress_ratio(0.0)
	var laser:RayCast2D = $Laser
	laser.position = follow.position
	laser.rotation = follow.rotation
