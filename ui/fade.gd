extends ColorRect

class_name Fade

signal complete(fadeout)
export var music: NodePath

func fade(out: bool, time = 1, fade_music = true):
	if out:
		visible = true
		$Tween.interpolate_property(self, "color", Color(0, 0, 0, 0), Color.black, time, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
		if fade_music and music:
			$Tween.interpolate_property(get_node(music), "volume_db", 0, -60, time, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
		$Tween.start()
		yield($Tween, "tween_all_completed")
		emit_signal("complete", true)
	else:
		$Tween.interpolate_property(self, "color", Color.black, Color(0, 0, 0, 0), time, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
		if fade_music and music:
			$Tween.interpolate_property(get_node(music), "volume_db", -60, 0, time, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
		$Tween.start()
		yield($Tween, "tween_all_completed")
		visible = false
		emit_signal("complete", false)
