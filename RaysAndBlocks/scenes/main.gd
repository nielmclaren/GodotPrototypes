extends Node2D

@export var level_change_ui: LevelChangeUI
@export var level_complete_popup: LevelCompletePopup
@export var game_complete_popup: GameCompletePopup

var curr_level_index: int
var curr_level: Level

func _ready() -> void:
	level_change_ui.level_selected.connect(_level_selected)

	level_complete_popup.next_clicked.connect(_level_popup_next_clicked)

	_load_level(Constants.START_LEVEL_INDEX)

func _level_selected(level_index: int) -> void:
	curr_level_index = level_index
	_load_level(level_index)

func _load_next_level() -> void:
	_load_level(curr_level_index + 1)

func _load_level(level_index: int) -> void:
	if curr_level:
		curr_level.completed.disconnect(_level_completed)
		curr_level.free()
		curr_level = null

	var level_scene: PackedScene = load("res://levels/level_%02d.tscn" % level_index) as PackedScene
	var level: Level = level_scene.instantiate()
	add_child(level)

	level.completed.connect(_level_completed)

	curr_level = level
	curr_level_index = level_index

func _level_completed() -> void:
	if curr_level_index + 1 >= LevelFileManager.get_num_levels():
		game_complete_popup.show()
	else:
		level_complete_popup.show()

func _level_popup_next_clicked() -> void:
	level_complete_popup.hide()
	_load_next_level()
