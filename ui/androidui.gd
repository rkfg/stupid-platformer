extends Control

onready var left := $MarginContainer/HBoxContainer/Left as TextureRect
onready var right := $MarginContainer/HBoxContainer/Right as TextureRect
onready var up := $MarginContainer/HBoxContainer/VBoxContainer/Up as TextureRect
onready var down := $MarginContainer/HBoxContainer/VBoxContainer/Down as TextureRect

func _input(event: InputEvent) -> void:
	if !(event is InputEventScreenTouch):
		return
	
	var ev = InputEventAction.new()
	var e := event as InputEventScreenTouch
	
	if left.get_global_rect().has_point(e.position):
		simulate_action("ui_left", "ui_right", e.pressed)

	if right.get_global_rect().has_point(e.position):
		simulate_action("ui_right", "ui_left", e.pressed)

	if up.get_global_rect().has_point(e.position):
		simulate_action("ui_up", "ui_down", e.pressed)

	if down.get_global_rect().has_point(e.position):
		simulate_action("ui_down", "ui_up", e.pressed)


func simulate_action(name: String, opposite: String, condition: bool):
	var ev = InputEventAction.new()
	if condition:
		ev.action = name
		ev.pressed = true
		Input.parse_input_event(ev)
	elif Input.is_action_pressed(name):
		ev.action = name
		ev.pressed = false
		Input.parse_input_event(ev)

	ev.action = opposite
	ev.pressed = false
	Input.parse_input_event(ev)

func change_opacity(opacity: int):
	modulate = Color(1, 1, 1, opacity / 100.0)
