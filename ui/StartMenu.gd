extends Control

signal on_start
signal on_settings
signal on_back

func _ready() -> void:
	$MarginContainer/VBoxContainer/Quit.connect("pressed", get_tree(), "quit")


func _on_Settings_pressed() -> void:
	emit_signal("on_settings")


func set_ingame(ingame):
	$MarginContainer/VBoxContainer/Start.visible = !ingame
	$MarginContainer/VBoxContainer/Back.visible = ingame


func _on_Back_pressed() -> void:
	emit_signal("on_back")


func _on_Start_pressed() -> void:
	emit_signal("on_start")
