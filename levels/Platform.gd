tool
extends Node2D

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

export var target: NodePath
export var speed := 100
export var wait := 1
export var moves := true setget set_moves

var follow := Vector2.ZERO

onready var platform := $Platform as KinematicBody2D
onready var tween := $Tween as Tween
onready var target_node := get_node(target) as Position2D

# Called when the node enters the scene tree for the first time.
func _ready():
	if Engine.editor_hint:
		return
	set_moves(moves)


func _physics_process(delta):
	if !platform:
		return
	platform.position = platform.position.linear_interpolate(follow, 0.075)

func _get_configuration_warning():
	if !get_node(target):
		return "No target specified"
	return ""

func set_moves(m):
	moves = m
	if !tween:
		return
	if moves:
		if target_node:
			tween.stop_all()
			var target_pos := target_node.position
			var duration := target_pos.length() / speed
			tween.interpolate_property(self, "follow", Vector2.ZERO, target_pos, duration, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT, wait)
			tween.interpolate_property(self, "follow", target_pos, Vector2.ZERO, duration, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT, wait * 2 + duration)
			tween.start()
	else:
		tween.stop_all()

func start():
	set_moves(true)

func stop():
	set_moves(false)
