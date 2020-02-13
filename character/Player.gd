extends KinematicBody2D

class_name Player

const explosion = preload("res://character/Explosion.tscn")
enum State {IDLE, JUMP, LADDER, RUN}

var velocity := Vector2.ZERO
export var gravity := Vector2(0, 600)
export var speed := 150
export var jump_speed := 300
export var air_friction_jump := 50
export var air_friction_run := 10

var real_air_friction := air_friction_run
var keylock := true
var can_leave := false
var state = State.JUMP
var has_key := false
var coins := 0
var map: TileMap
const GROUND_SNAP = 10
const LADDER_CELL = 18
var snap := Vector2.DOWN * GROUND_SNAP

onready var sprite := $Sprite as Sprite
onready var animation := $AnimationPlayer as AnimationPlayer
onready var tw := $Tween as Tween
onready var phys := $PhysicalBox as CollisionShape2D

signal next_level
signal respawn
signal key_picked
signal coin_picked


func _physics_process(delta: float):
	if keylock:
		return

	var direction := Vector2(int(Input.is_action_pressed("ui_right")) - int(Input.is_action_pressed("ui_left")), int(Input.is_action_pressed("ui_down")) - int(Input.is_action_pressed("ui_up"))) * int(!keylock)

	if state != State.LADDER:
		velocity += gravity * delta

	velocity.x += direction.x * speed / real_air_friction
	velocity.x = clamp(velocity.x, -speed, speed)
	velocity.y = clamp(velocity.y, -jump_speed, jump_speed)
	if state != State.JUMP:
		if direction.length() == 0:
			animation.play("idle")
			state = State.IDLE
		elif direction.x != 0:
			animation.play("run")
			sprite.flip_h = velocity.x < 0
			state = State.RUN
	
	if keylock:
		velocity = Vector2.ZERO
	var new_velocity := move_and_slide_with_snap(velocity, snap, Vector2(0, -1), get_floor_velocity().x == 0)
	check_collisions()

	if new_velocity.x == 0:
		velocity.x = 0

	if !is_on_floor():
		velocity.y = new_velocity.y
		if state != State.LADDER:
			state = State.JUMP

	elif state != State.LADDER:
		state = State.RUN if velocity.x != 0 else State.IDLE
	
	var cell_coord : Vector2
	var ol : bool

	if is_instance_valid(map):
		cell_coord = map.world_to_map(position - map.position + Vector2(0, phys.shape.extents.y))
		ol = map.get_cellv(cell_coord) == LADDER_CELL

	if state == State.LADDER and !ol:
		state = State.IDLE

	if state != State.LADDER and ol:
		state = State.LADDER

	if state == State.LADDER:
		if direction.y == 0:
			velocity.y = 0
		else:
			$AnimationPlayer.play("midair")
			velocity.y += speed * direction.y
		velocity.y = clamp(velocity.y, -speed, speed)
		snap = Vector2.ZERO
		real_air_friction = air_friction_run

	if state == State.JUMP:
		real_air_friction = air_friction_jump
		if velocity.y < -jump_speed * 0.5:
			animation.play("jump")
		if velocity.y > -jump_speed * 0.5:
			animation.play("midair")
	else: # on the floor/ladder
		if direction.x == 0:
			velocity.x = 0
		real_air_friction = air_friction_run
		if state != State.LADDER:
			velocity.y = 0
			snap = Vector2.DOWN * GROUND_SNAP
			if (!keylock and Input.is_action_pressed("ui_up")):
				if can_leave:
					exiting()
				else: # jump
					velocity.y = -jump_speed
					snap = Vector2.ZERO
					state = State.JUMP
	
	if state == State.LADDER and !is_on_floor() and direction.x == 0 and direction.y != 0:
		var ladder_coord = map.map_to_world(cell_coord) + map.cell_size / 2
		if abs(ladder_coord.x - position.x) > 1:
			velocity.x = (ladder_coord.x - position.x) / delta
		else:
			velocity.x = 0
		
	if position.y > 500:
		explode()


func _on_Exit_body_entered(body: KinematicBody2D):
	if body and body == self:
		can_leave = has_key

func _on_Exit_body_exited(body: KinematicBody2D):
	if body == self:
		can_leave = false

func exiting():
	tw.interpolate_property(self, "modulate", Color.white, Color(1, 1, 1, 0), 1, Tween.TRANS_LINEAR, Tween.EASE_IN)
	tw.start()
	keylock = true
	yield(tw, "tween_all_completed")
	emit_signal("next_level")
	coins = 0
	has_key = false
	emit_signal("key_picked", has_key)
	
func init(pos: Position2D):
	modulate = Color.white
	visible = true
	keylock = false
	can_leave = false
	if pos:
		position = pos.to_global(get_parent().position)
	velocity = Vector2.ZERO

func check_collisions():
	for i in range(get_slide_count()):
		var col := get_slide_collision(i)
		if col.collider is KinematicBody2D:
			hit(col.collider as KinematicBody2D)


func hit(who: KinematicBody2D):
	if keylock:
		return
	if who.is_in_group("enemy"):
		explode()


func explode():
	keylock = true
	var e := explosion.instance() as AnimatedSprite
	get_parent().add_child(e)
	$AudioStreamPlayer2D.play()
	e.position = position
	e.play("explosion")
	tw.interpolate_property(self, "modulate", Color.white, Color(1, 1, 1, 0), 0.5, Tween.TRANS_LINEAR, Tween.EASE_IN)
	tw.start()
	yield(get_tree().create_timer(1), "timeout")
	e.queue_free()
	emit_signal("respawn")

func pick(what: Node2D):
	if what.is_in_group("keys"):
		print("Key found!")
		has_key = true
		emit_signal("key_picked", has_key)
	if what.is_in_group("coins"):
		coins += 1
		emit_signal("coin_picked", coins)
		print("Coin found! Total coin number: %d" % coins)
