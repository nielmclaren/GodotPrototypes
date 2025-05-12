extends PanelContainer

class_name LevelChangeUI

signal level_selected

func _ready() -> void:
	_instantiate_level_buttons()

func _instantiate_level_buttons() -> void:
	var button_group: ButtonGroup = ButtonGroup.new()

	var level_indices: Array[int] = LevelFileManager.get_level_indices()
	for level_index: int in level_indices:
		_instantiate_level_button(level_index, button_group)

func _instantiate_level_button(level_index: int, button_group: ButtonGroup) -> void:
	var button: Button = Button.new()
	button.set_button_group(button_group)
	button.toggle_mode = true
	button.set_pressed_no_signal(level_index == Constants.START_LEVEL_INDEX)
	button.text = "%02d" % level_index
	button.pressed.connect(_button_clicked.bind(level_index))
	$HFlowContainer.add_child(button)

func _get_button_level(button: Button) -> int:
	return int(button.name)

func _button_clicked(level_index: int) -> void:
	level_selected.emit(level_index)
