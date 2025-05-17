class_name LevelChangeUI
extends PanelContainer

@export var title_label: Label
@export var level_button_container: Container

signal level_selected


func level_changed(level_num: int) -> void:
	var metadata: LevelMetadata = LevelMetadata.get_num(level_num)
	title_label.text = metadata.title


func _ready() -> void:
	_instantiate_level_buttons()


func _instantiate_level_buttons() -> void:
	var button_group: ButtonGroup = ButtonGroup.new()

	for level_index: int in range(0, LevelFileManager.size()):
		_instantiate_level_button(level_index, button_group)


func _instantiate_level_button(level_index: int, button_group: ButtonGroup) -> void:
	var button: Button = Button.new()
	button.set_button_group(button_group)
	button.toggle_mode = true
	button.set_pressed_no_signal(level_index == 0)
	button.text = "%02d" % LevelFileManager.get_level_num(level_index)
	button.pressed.connect(_button_clicked.bind(level_index))
	level_button_container.add_child(button)


func _button_clicked(level_index: int) -> void:
	level_selected.emit(level_index)
