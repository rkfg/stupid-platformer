extends Node

export var start_level: int = 0

onready var fade := $UI/Fade as Fade
onready var player := $Player as Player
onready var cam := $Player/cam as Camera2D
onready var hud := $UI/HUD
onready var victory := $UI/Victory

enum State { MAIN_MENU, GAME, SETTINGS, CREDITS }

var state_stack = []
var state = State.MAIN_MENU

func _ready():
	randomize()
	player.connect("next_level", self, "_load_next_level")
	player.connect("respawn", self, "_init_player")
	player.connect("key_picked", hud, "_update_key")
	player.connect("coin_picked", hud, "_update_coins")
	$UI/Victory/Buttons/Exit.connect("pressed", get_tree(), "quit")
	$UI/Victory/Buttons/Restart.connect("pressed", self, "restart")
	$UI/StartMenu.connect("on_start", self, "_start_game")
	$UI/StartMenu.connect("on_back", self, "_toggle_menu")
	$UI/StartMenu.connect("on_settings", self, "_open_close_settings", [true])
	$UI/Settings.connect("on_close_settings", self, "_open_close_settings", [false])
	$UI/Settings.connect("on_opacity_changed", $UI/AndroidUI, "change_opacity")
	$UI/Settings.init()
	$UI/AndroidUI.hide()
	if !OS.has_touchscreen_ui_hint():
		$UI/AndroidUI.queue_free()

	if !OS.is_debug_build():
		OS.window_fullscreen = true
		

func _start_game():
	OS.window_fullscreen = true
	_load_next_level()
	

func _init_player():
	player.init($level/PlayerStart as Position2D)

func _load_next_level():
	start_level += 1
	print("Loading level %d..." % start_level)
	var res := "res://levels/level%d.tscn" % start_level
	fade.fade(true)
	yield(fade, "complete")
	_change_state(State.GAME)
	if !ResourceLoader.exists(res):
		print("Level %d not found!" % start_level)
		_change_state(State.CREDITS)
		victory.visible = true
		victory.request_ready()
		$Music.stream = victory.music
		$Music.play()
		victory.start()
	else:
		if ($UI/AndroidUI):
			$UI/AndroidUI.show()
		victory.visible = false
		$UI/StartMenu.visible = false
		victory.stop()
		var new_level := load(res).instance() as TileMap
		var old_level := $level
		old_level.name = "old_level"
		old_level.queue_free()
		new_level.name = "level"
		new_level.pause_mode = Node.PAUSE_MODE_STOP
		add_child(new_level)
		if new_level.music:
			$Music.stream = new_level.music
			$Music.play()

		hud.set_coins_number(_count_coins(new_level))
		if new_level.has_node("Exit"):
			var exit := new_level.get_node("Exit")
			exit.connect("body_entered", player, "_on_Exit_body_entered")
			exit.connect("body_exited", player, "_on_Exit_body_exited")
			player.connect("key_picked", exit, "unlock")

		if new_level.has_node("LevelEnd"):
			var end := new_level.get_node("LevelEnd") as Position2D
			cam.limit_right = end.position.x
			cam.limit_top = end.position.y
		
		_init_checkpoints(new_level)
		
		player.map = new_level

	fade.fade(false)
	if has_node(@"level/PlayerStart"):
		_init_player()


func restart():
	start_level = 0
	_load_next_level()

func _count_coins(level: Node) -> int:
	var sum := 0
	for c in level.get_children():
		if c.is_in_group("coins"):
			sum += 1
		sum += _count_coins(c)
			
	return sum


func _update_checkpoint(cp: Node2D):
	if has_node(@"level/PlayerStart"):
		$level/PlayerStart.position = cp.position


func _init_checkpoints(level: Node):
	for c in level.get_children():
		if c.is_in_group("checkpoints"):
			if c.difficulty < $UI/Settings.settings["Difficulty"]:
				c.visible = false
			else:
				c.connect("update_checkpoint", self, "_update_checkpoint")
		_init_checkpoints(c)


func _open_close_settings(open):
	fade.fade(true, 0.2, false)
	yield(fade, "complete")
	$UI/Settings.visible = open
	$UI/StartMenu.visible = !open
	if open:
		_push_state_and_change(State.SETTINGS)
	else:
		_pop_state()
	fade.fade(false, 0.2, false)


func _input(event: InputEvent) -> void:
	if state == State.GAME and event.is_action_released("ui_cancel"):
		_toggle_menu()


func _toggle_menu():
	get_tree().paused = !get_tree().paused
	fade.fade(true, 0.2, false)
	yield(fade, "complete")
	$UI/StartMenu.visible = get_tree().paused
	if ($UI/AndroidUI):
		$UI/AndroidUI.visible = !get_tree().paused
	fade.fade(false, 0.2, false)
		


func _push_state_and_change(new_state):
	state_stack.push_back(state)
	_change_state(new_state)
	
	
func _pop_state():
	_change_state(state_stack.pop_back())


func _change_state(new_state):
	state = new_state
	match state:
		State.GAME:
			$UI/StartMenu.set_ingame(true)
		State.MAIN_MENU:
			$UI/StartMenu.set_ingame(false)
