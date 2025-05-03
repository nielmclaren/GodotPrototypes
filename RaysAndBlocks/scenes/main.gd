extends Node2D

var curr_level: Node2D

func _ready() -> void:
	var level_change_ui: LevelChangeUI = $HUD/LevelChangeUI
	level_change_ui.level_selected.connect(_level_selected)

	_load_level(Constants.START_LEVEL_NUM)

func _level_selected(level_num: int) -> void:
	_load_level(level_num)

func _load_level(level_num: int) -> void:
	if curr_level:
		curr_level.queue_free()
		curr_level = null

	var level_scene: PackedScene = load("res://levels/level_%02d.tscn" % level_num) as PackedScene
	var level: Node2D = level_scene.instantiate()
	add_child(level)

	curr_level = level
