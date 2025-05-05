extends Node2D

enum Pose {RECOVERY, PRIMED, PUSH, GLIDE}

var screen_size: Vector2

var player: AnimationPlayer

var speed: float = 600
var damping_coefficient_low: float = 0.02
var damping_coefficient_high: float = 0.08
var velocity: Vector2 = Vector2.ZERO

var pose: Pose = Pose.GLIDE

var start_position: Vector2
var start_rotation: float

func _ready() -> void:
	screen_size = get_viewport_rect().size
	player = $AnimationPlayer
	player.animation_finished.connect(_animation_finished)

	start_position = position
	start_rotation = rotation

func _animation_finished() -> void:
	match player.current_animation:
		"push":
			pose = Pose.GLIDE
		"recover":
			pose = Pose.PRIMED

func _unhandled_input(event):
	if event is InputEventKey:
		if event.pressed:
			if event.is_action_pressed("reset"):
				_reset()
			if event.is_action_pressed("jump"):
				_start_recover()
		if !event.pressed:
			if event.is_action("jump"):
				_start_push()

func _reset() -> void:
	player.current_animation = "push"
	player.seek(player.current_animation_length, true)
	position = start_position
	rotation = start_rotation
	velocity = Vector2.ZERO
	pose = Pose.GLIDE

func _start_recover() -> void:
	player.play("recover")
	pose = Pose.RECOVERY
	velocity -= Vector2(0, 50).rotated(-rotation)

func _start_push() -> void:
	var animation_position: float = player.current_animation_position
	var animation_length: float = player.current_animation_length
	var progress: float = 1.0
	if player.current_animation == "recover":
		progress = animation_position / animation_length

	if progress >= 1.0:
		player.play("push")
	else:
		player.play_backwards("recover")

	# Don't push as hard if no wind up.
	var charge: float = progress * progress * progress
	velocity = Vector2(speed * charge, 0).rotated(rotation)
	pose = Pose.PUSH

func _process(delta: float) -> void:
	var damping: float = 0
	var rotation_delta: float = 0
	match pose:
		Pose.RECOVERY:
			damping = damping_coefficient_high
			rotation_delta = 0.8
		Pose.PRIMED:
			damping = damping_coefficient_high
			rotation_delta = 0.8
		Pose.PUSH:
			damping = damping_coefficient_low
			rotation_delta = 0.2
		Pose.GLIDE:
			damping = damping_coefficient_low
			rotation_delta = 0.2

	var direction: Vector2 = _get_controller_direction()
	if direction.length() > 0:
		rotation = rotate_toward(rotation, direction.angle(), rotation_delta * 0.2)

	velocity -= velocity * damping
	position += velocity * delta
	position = position.clamp(Vector2.ZERO, screen_size)

func _get_controller_direction() -> Vector2:
	var direction: Vector2 = Vector2.ZERO
	if Input.is_action_pressed("move_left"):
		direction.x -= 1
	if Input.is_action_pressed("move_right"):
		direction.x += 1
	if Input.is_action_pressed("move_up"):
		direction.y -= 1
	if Input.is_action_pressed("move_down"):
		direction.y += 1

	if direction.length() > 0:
		return direction.normalized()
	return direction
