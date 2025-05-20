class_name LevelMetadata
extends Resource

var enabled: bool

# The number used in the filename.
var level_num: int

var title: String

# Displayed when the player finishes a level.
var complete_message: String = ""


func _init(enabled_flag: int, level_num_arg: int, title_arg: String) -> void:
	enabled = enabled_flag != 0
	level_num = level_num_arg
	title = title_arg


func complete(arg: String) -> LevelMetadata:
	complete_message = arg
	return self
