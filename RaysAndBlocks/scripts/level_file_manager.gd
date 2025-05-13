extends Node

const LEVELS_DIR: String = "res://levels"

var _level_nums: Array[int] = []

func get_level_num(index: int) -> int:
	return Constants.ENABLED_LEVELS[index]

func get_level_nums() -> Array[int]:
	return _level_nums

func size() -> int:
	return _level_nums.size()

func _init() -> void:
	var level_num_pattern: RegEx = RegEx.new()
	level_num_pattern.compile(r"level_(\d\d)\.tscn")

	var level_files: PackedStringArray = DirAccess.get_files_at(LEVELS_DIR)
	for file: String in level_files:
		var match: RegExMatch = level_num_pattern.search(file)
		if match:
			var level_num: int = int(match.get_string(1))
			if Constants.ENABLED_LEVELS.has(level_num):
				_level_nums.push_back(level_num)
