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


static func get_all() -> Array[LevelMetadata]:
	return [
		LevelMetadata.new(1, 0, "The Basics").complete("Your light bending journey has begun!"),
		LevelMetadata.new(1, 1, "Area Restricted: Do Not Enter"),
		LevelMetadata.new(1, 2, "Choke Point").complete(
			"You made it through the choke point. Fortunately, lasers not exactly thicc."
		),
		LevelMetadata.new(1, 3, "The Skull").complete("That was a tricky one!"),
		LevelMetadata.new(1, 4, "The Other Side of the Mirror"),
		LevelMetadata.new(1, 5, "Spiral"),
		LevelMetadata.new(1, 6, "Wall of Steam"),
		LevelMetadata.new(1, 7, "Hairpins"),
		LevelMetadata.new(1, 8, "Side-Stepping"),
		LevelMetadata.new(1, 9, "Double Vision").complete(
			"You are now a master of the rectangular prism!"
		)
	]


static func get_num(level_num_arg: int) -> LevelMetadata:
	var metadatas: Array[LevelMetadata] = get_all()
	var f: Callable = func(m: LevelMetadata) -> bool: return m.level_num == level_num_arg
	var index: int = metadatas.find_custom(f)
	if index >= 0:
		return metadatas[index]
	return null
