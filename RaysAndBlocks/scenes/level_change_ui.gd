extends PanelContainer

class_name LevelChangeUI

signal level_selected

func _ready() -> void:
	_instantiate_level_buttons()

func _instantiate_level_buttons() -> void:
	var button_group: ButtonGroup = ButtonGroup.new()

	var level_num_pattern: RegEx = RegEx.new()
	level_num_pattern.compile(r"level_(\d\d)\.tscn")

	var level_files: PackedStringArray = DirAccess.get_files_at("res://levels")
	for file: String in level_files:
		var match: RegExMatch = level_num_pattern.search(file)
		if match:
			var level_num: int = int(match.get_string(1))
			_instantiate_level_button(level_num, button_group)

func _instantiate_level_button(level_num: int, button_group: ButtonGroup) -> void:
	var button: Button = Button.new()
	button.set_button_group(button_group)
	button.toggle_mode = true
	button.set_pressed_no_signal(level_num == Constants.START_LEVEL_NUM)
	button.text = "%02d" % level_num
	button.pressed.connect(_button_clicked.bind(level_num))
	$HFlowContainer.add_child(button)

func _get_button_level(button: Button) -> int:
	return int(button.name)

func _button_clicked(level_num: int) -> void:
	level_selected.emit(level_num)
