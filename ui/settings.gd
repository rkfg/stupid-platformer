extends Control

const default_settings = { "MasterVol": 100, "MusicVol": 80, "FXVol": 100, "Difficulty": 1, "Opacity": 10 }
var settings = {}
const db_const = 40 / log(10)

signal on_close_settings
signal on_opacity_changed(opacity)

onready var difficulty_items := $MarginContainer/VBoxContainer/Difficulty/ItemList as ItemList

func init() -> void:
	difficulty_items.add_item("Easy (all checkpoints)")
	difficulty_items.add_item("Medium (some checkpoints)")
	difficulty_items.add_item("Hard (no checkpoints)")
	if !OS.has_touchscreen_ui_hint():
		$MarginContainer/VBoxContainer/ControlsOpacity.hide()
	_on_Revert_pressed()


func _load_settings():
	var f := File.new()
	f.open_compressed("user://settings.dat", File.READ)
	settings = default_settings.duplicate()
	var loaded_settings = f.get_var()
	if !loaded_settings:
		loaded_settings = {}
	for k in loaded_settings:
		settings[k] = loaded_settings[k]
	f.close()


func _save_settings():
	var f := File.new()
	f.open_compressed("user://settings.dat", File.WRITE)
	f.store_var(settings)
	f.close()


func _on_Apply_pressed() -> void:
	_get_settings()
	_put_settings()
	_save_settings()


func _on_Revert_pressed() -> void:
	_load_settings()
	_put_settings()
	

func _get_settings():
	settings["MasterVol"] = $MarginContainer/VBoxContainer/Master/Value.value
	settings["MusicVol"] = $MarginContainer/VBoxContainer/Music/Value.value
	settings["FXVol"] = $MarginContainer/VBoxContainer/FX/Value.value
	settings["Difficulty"] = difficulty_items.get_selected_items()[0]
	settings["Opacity"] = $MarginContainer/VBoxContainer/ControlsOpacity/Value.value


func _to_db(perc: int) -> float:
	return log(perc / 100.0) * db_const


func _put_settings():
	var master_idx := AudioServer.get_bus_index("Master")
	AudioServer.set_bus_volume_db(master_idx, _to_db(settings["MasterVol"]))
	var music_idx := AudioServer.get_bus_index("Music")
	AudioServer.set_bus_volume_db(music_idx, _to_db(settings["MusicVol"]))
	var fx_idx := AudioServer.get_bus_index("FX")
	AudioServer.set_bus_volume_db(fx_idx, _to_db(settings["FXVol"]))
	$MarginContainer/VBoxContainer/Master/Value.value = settings["MasterVol"]
	$MarginContainer/VBoxContainer/Music/Value.value = settings["MusicVol"]
	$MarginContainer/VBoxContainer/FX/Value.value = settings["FXVol"]
	$MarginContainer/VBoxContainer/ControlsOpacity/Value.value = settings["Opacity"]
	emit_signal("on_opacity_changed", settings["Opacity"])
	difficulty_items.unselect_all()
	difficulty_items.select(settings["Difficulty"])


func _on_Back_pressed() -> void:
	emit_signal("on_close_settings")


func _format_volume(slider: HSlider):
	return "%d%%" % slider.value


func _on_value_changed(value: float) -> void:
	$MarginContainer/VBoxContainer/Master/Volume.text = _format_volume($MarginContainer/VBoxContainer/Master/Value)
	$MarginContainer/VBoxContainer/Music/Volume.text = _format_volume($MarginContainer/VBoxContainer/Music/Value)
	$MarginContainer/VBoxContainer/FX/Volume.text = _format_volume($MarginContainer/VBoxContainer/FX/Value)
	$MarginContainer/VBoxContainer/ControlsOpacity/Volume.text = _format_volume($MarginContainer/VBoxContainer/ControlsOpacity/Value)
