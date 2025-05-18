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
		###
		### Mirrors
		###
		LevelMetadata.new(0, 0, "The Basics").complete("Your light bending journey has begun!"),
		LevelMetadata.new(0, 1, "Area Restricted: Do Not Enter").complete(
			"You got it. Sometimes lasers can go places objects can't."
		),
		LevelMetadata.new(0, 2, "Choke Point").complete(
			"Straight through the bottleneck and onto the next level."
		),
		LevelMetadata.new(0, 3, "The Skull").complete("That was a tricky one!"),
		LevelMetadata.new(0, 4, "The Other Side of the Mirror").complete(
			"Now you're seeing both sides of the mirror."
		),
		###
		### Rectangular Prisms
		###
		LevelMetadata.new(1, 5, "Spiral").complete(
			"You just performed 'internal reflection.' You're well on your way to enlightenment."
		),
		LevelMetadata.new(1, 6, "Wall of Steam").complete(
			"Sometimes objects can go places that lasers can't."
		),
		LevelMetadata.new(1, 7, "Hairpins").complete("Three sharp turns but your wits are the sharpest of all."),
		LevelMetadata.new(1, 8, "Side-Stepping").complete("A little do-si-do. The only dancing a rectangular prism do."),
		LevelMetadata.new(1, 9, "Double Vision").complete(
			"You are now a master of the rectangular prism!"
		),
		LevelMetadata.new(0, 10, "Playground")
	]


static func get_enabled() -> Array[LevelMetadata]:
	var is_enabled: Callable = func(level_metadata: LevelMetadata) -> bool:
		return level_metadata.enabled
	return get_all().filter(is_enabled)


static func get_num(level_num_arg: int) -> LevelMetadata:
	var metadatas: Array[LevelMetadata] = get_all()
	var f: Callable = func(m: LevelMetadata) -> bool: return m.level_num == level_num_arg
	var index: int = metadatas.find_custom(f)
	if index >= 0:
		return metadatas[index]
	return null
