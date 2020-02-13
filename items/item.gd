extends Node2D

class_name Item

func _on_Item_body_entered(body: Node) -> void:
	if visible and body.has_method("pick"):
		visible = false
		body.pick(self)
		$AudioStreamPlayer2D.play()
