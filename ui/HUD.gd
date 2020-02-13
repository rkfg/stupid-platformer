extends Control


# Declare member variables here. Examples:
# var a: int = 2
# var b: String = "text"

var total_coins: int = 0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


func _update_key(has: bool):
	$MarginContainer/KeyBox/KeyImg.visible = has

func _update_coins(num: int):
	$MarginContainer/CoinsBox/CoinsNum.text = "%d/%d" % [num, total_coins]

func set_coins_number(num: int):
	total_coins = num
	_update_coins(0)
