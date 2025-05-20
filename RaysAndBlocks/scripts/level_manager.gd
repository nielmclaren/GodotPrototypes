extends Node

const LEVELS_DIR: String = "res://levels"

# Only contains levels which are enabled and which have a level scene file.
var _level_metadatas: Array[LevelMetadata] = []


func get_level_metadata_by_index(index: int) -> LevelMetadata:
	return _level_metadatas[index]


func get_level_metadata_by_num(level_num_arg: int) -> LevelMetadata:
	var f: Callable = func(m: LevelMetadata) -> bool: return m.level_num == level_num_arg
	var index: int = _level_metadatas.find_custom(f)
	if index >= 0:
		return _level_metadatas[index]
	return null


func get_level_path_by_index(index: int) -> String:
	return LEVELS_DIR + ("/level_%02d.tscn" % _level_metadatas[index].level_num)


func size() -> int:
	return _level_metadatas.size()


func _init() -> void:
	_level_metadatas = []
	var all_level_metadatas: Array[LevelMetadata] = _get_all()
	for level_metadata: LevelMetadata in all_level_metadatas:
		if (
			level_metadata.enabled
			and FileAccess.file_exists(LEVELS_DIR + ("/level_%02d.tscn" % level_metadata.level_num))
		):
			_level_metadatas.append(level_metadata)


func _get_all() -> Array[LevelMetadata]:
	return [
		###
		### Mirrors
		###
		LevelMetadata.new(1, 0, "The Basics").complete("Your light bending journey has begun!"),
		LevelMetadata.new(1, 1, "Area Restricted: Do Not Enter").complete(
			"You got it. Sometimes lasers can go places objects can't."
		),
		LevelMetadata.new(1, 2, "Choke Point").complete(
			"Straight through the bottleneck and onto the next level."
		),
		LevelMetadata.new(1, 3, "The Skull").complete("That was a tricky one!"),
		LevelMetadata.new(1, 4, "The Other Side of the Mirror").complete(
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
		LevelMetadata.new(1, 7, "Hairpins").complete(
			"Three sharp turns but your wits are the sharpest of all."
		),
		LevelMetadata.new(1, 8, "Side-Stepping").complete(
			"A little do-si-do. The only dancing a rectangular prism do."
		),
		LevelMetadata.new(1, 9, "Double Vision").complete(
			"You are now a master of the rectangular prism!"
		),
		LevelMetadata.new(0, 10, "Playground")
	]
