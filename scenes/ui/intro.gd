class_name Intro
extends Control

const MAIN_MENU_PATH := "res://scenes/ui/main_menu.tscn"
const FADE_TIME := 0.3
const HINT_TIME := 4.0
const INTRO_VOLUME_DB := -12.0

@onready var video: VideoStreamPlayer = %VideoStreamPlayer
@onready var skip_hint: Label = %SkipHint
@onready var fade: ColorRect = %Fade

var leaving := false

func _ready() -> void:
	get_tree().paused = false
	if video.stream == null:
		_go_to_menu.call_deferred()
		return
	var music_volume := Settings.get_volume("music")
	video.volume_db = (INTRO_VOLUME_DB + linear_to_db(music_volume)) if music_volume > 0.0 else -80.0
	video.finished.connect(_go_to_menu)
	var hint_tween := create_tween()
	hint_tween.tween_interval(HINT_TIME)
	hint_tween.tween_property(skip_hint, "modulate:a", 0.0, 0.5)

func _input(event: InputEvent) -> void:
	if leaving:
		return
	var skip := false
	if event is InputEventKey:
		skip = event.pressed and not event.echo
	elif event is InputEventMouseButton or event is InputEventJoypadButton:
		skip = event.pressed
	if skip:
		get_viewport().set_input_as_handled()
		_go_to_menu()

func _go_to_menu() -> void:
	if leaving:
		return
	leaving = true
	var tween := create_tween().set_parallel(true)
	tween.tween_property(fade, "color:a", 1.0, FADE_TIME)
	tween.tween_property(video, "volume_db", -80.0, FADE_TIME)
	tween.chain().tween_callback(
		func(): get_tree().change_scene_to_file(MAIN_MENU_PATH)
	)
