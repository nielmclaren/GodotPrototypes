class_name LevelCompletePopup
extends Window

@export var next_button: Button

signal next_clicked


func _ready() -> void:
	next_button.pressed.connect(_next_button_pressed)


func _next_button_pressed() -> void:
	next_clicked.emit()
