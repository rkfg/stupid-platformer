extends Area2D

export var locked: bool = true

func unlock(has):
	locked = !has
	if has:
		$Tween.interpolate_property($TileMap_block, "modulate", Color.white, Color(1, 1, 1, 0), 2, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
		$Tween.start()
