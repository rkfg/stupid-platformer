extends Node2D

class_name Checkpoint
signal update_checkpoint
export var difficulty := 0

func _on_Area2D_body_entered(body: Node) -> void:
	if body is Player and visible and $Sprite.frame > 0:
		$Sprite.frame = 0
		$AudioStreamPlayer2D.play()
		emit_signal("update_checkpoint", self)
		$Tween.interpolate_property($Effect, "frame", 0, 48, 1, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
		$Tween.interpolate_property($Effect, "position", Vector2(0, 0), Vector2(0, -50), 1, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
		$Tween.start()
