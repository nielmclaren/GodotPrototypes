extends Node2D

class_name LevelCompletePopup

signal next_clicked

func _ready() -> void:
	var next: Button = $NextButton
	next.pressed.connect(_next_button_pressed)


func _next_button_pressed() -> void:
	next_clicked.emit()
