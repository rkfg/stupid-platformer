extends Control

class_name Victory

var music := preload("res://music/outro.ogg")

func _ready() -> void:
	if OS.get_name() == "HTML5":
		$Buttons/Exit.visible = false
	$Label.rect_position.y = $Label.rect_size.y

func start():
	$Label/Tween.interpolate_property($Label, "rect_position", Vector2(0, rect_size.y), Vector2(0, -$Label.rect_size.y), 20, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	$Label/Tween.start()
	

func stop():
	$Label/Tween.stop_all()
