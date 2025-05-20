class_name LevelCompletePopup
extends Window

@export var message_label: Label
@export var next_button: Button

signal next_clicked


func level_changed(level_num: int) -> void:
	var metadata: LevelMetadata = LevelManager.get_level_metadata_by_num(level_num)
	message_label.text = metadata.complete_message


func _ready() -> void:
	next_button.pressed.connect(_next_button_pressed)


func _next_button_pressed() -> void:
	next_clicked.emit()
