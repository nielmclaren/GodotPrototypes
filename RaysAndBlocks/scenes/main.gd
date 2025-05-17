extends Node2D

@export var level_change_ui: LevelChangeUI
@export var level_complete_popup: LevelCompletePopup
@export var game_complete_popup: Window

var curr_level_index: int
var curr_level: Level


func _ready() -> void:
	level_change_ui.level_selected.connect(_level_selected)

	level_complete_popup.next_clicked.connect(_level_popup_next_clicked)

	_load_level(0)


func _process(_delta: float) -> void:
	if Input.is_action_just_released("escape"):
		var tree: SceneTree = get_tree()
		tree.root.propagate_notification(NOTIFICATION_WM_CLOSE_REQUEST)
		tree.quit()


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

	var level_scene: PackedScene = (
		load("res://levels/level_%02d.tscn" % LevelFileManager.get_level_num(level_index))
		as PackedScene
	)
	var level: Level = level_scene.instantiate()
	add_child(level)

	level.completed.connect(_level_completed)

	curr_level = level
	curr_level_index = level_index

	_level_changed()


func _level_changed() -> void:
	var level_num: int = LevelFileManager.get_level_num(curr_level_index)
	level_change_ui.level_changed(level_num)
	level_complete_popup.level_changed(level_num)


func _level_completed() -> void:
	if curr_level_index + 1 >= LevelFileManager.size():
		game_complete_popup.show()
		GlobalState.is_game_input_enabled = false
	else:
		level_complete_popup.show()
		GlobalState.is_game_input_enabled = false


func _level_popup_next_clicked() -> void:
	level_complete_popup.hide()
	_load_next_level()
	GlobalState.is_game_input_enabled = true
