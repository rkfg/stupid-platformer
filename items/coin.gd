extends Item

func _ready() -> void:
	var anim = $Item/AnimationPlayer
	anim.advance(anim.current_animation_length * randf())
