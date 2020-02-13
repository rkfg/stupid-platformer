extends Node2D

export var one_shot := true

var pressed := false

signal on_button_press
signal on_button_release

func _on_Area2D_body_entered(body: Node) -> void:
	if !body is Player:
		return
	if !pressed:
		pressed = true
		$Area2D/CollisionShape2D/Sprite.frame = 1
		emit_signal("on_button_press")
		$AudioStreamPlayer2D.play()


func _on_Area2D_body_exited(body: Node) -> void:
	if !body is Player:
		return
	if pressed and !one_shot:
		pressed = false
		$Area2D/CollisionShape2D/Sprite.frame = 0
		emit_signal("on_button_release")
