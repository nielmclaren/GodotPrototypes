extends Node

const LEVELS_DIR: String = "res://levels"

var _level_indices: Array[int] = []

func get_level_indices() -> Array[int]:
	return _level_indices

func get_num_levels() -> int:
	return _level_indices.size()

func _init() -> void:
	var level_num_pattern: RegEx = RegEx.new()
	level_num_pattern.compile(r"level_(\d\d)\.tscn")

	var level_files: PackedStringArray = DirAccess.get_files_at(LEVELS_DIR)
	for file: String in level_files:
		var match: RegExMatch = level_num_pattern.search(file)
		if match:
			var level_index: int = int(match.get_string(1))
			_level_indices.push_back(level_index)
