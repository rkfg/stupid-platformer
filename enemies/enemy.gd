extends KinematicBody2D

class_name Enemy

export var speed := 100
export var jump_speed := 200
export var walking_direction := Vector2(1, 0)
export var gravity := Vector2(0, 600)
export var can_jump := false
export var wait_time := 1
var wait := 0.0
var velocity := Vector2.ZERO

onready var anim := $AnimationPlayer as AnimationPlayer
onready var sprite := $Sprite as Sprite

func _physics_process(delta: float):
	move(delta)

func move(delta: float) -> void:
	if wait > 0:
		wait -= delta
		
	velocity = move_and_slide(velocity, Vector2.UP)

	velocity += gravity * delta
	if can_jump and randf() < 0.01 and is_on_floor():
		velocity += Vector2.UP * jump_speed

	if wait <= 0:
		velocity.x = (walking_direction * speed).x

	sprite.flip_h = walking_direction.x > 0
	if abs(velocity.x) > 0:
		anim.play("run")
	else:
		anim.play("idle")

	for i in range(get_slide_count()):
		var col := get_slide_collision(i)
		if col.collider.has_method("hit"):
			col.collider.hit(self)
			
		if col.normal.dot(walking_direction) < 0:
			walking_direction = -walking_direction
			wait = wait_time
