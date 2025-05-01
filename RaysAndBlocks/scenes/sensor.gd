extends StaticBody2D

class_name Sensor

var is_active:bool = false

func _ready() -> void:
	is_active = false

func _process(_delta:float) -> void:
	if is_active:
		($SpriteActive as Sprite2D).show()
		($SpriteInactive as Sprite2D).hide()
		is_active = false
	else:
		($SpriteActive as Sprite2D).hide()
		($SpriteInactive as Sprite2D).show()

# TODO: There's no guarantee that Laser._physics_process() will be called
#       exactly once for each call to `Sensor._process()`.
func register_laser_collision(_laser:Laser) -> void:
	is_active = true
