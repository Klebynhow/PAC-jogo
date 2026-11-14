extends Control

const CHAR_SELECTOR_SCENE := preload("res://scenes/ui/character_selector.tscn")
const RUN_SCENE = preload("res://scenes/Run/run.tscn")

@onready var continue_button: Button = %Continue
@onready var tutorial: Tutorial = %Tutorial
@onready var settings_button: TextureButton = %SettingsButton
@onready var settings_panel: PanelContainer = %SettingsPanel
@export var run_startup: RunStartup

func _ready() -> void:
	get_tree().paused = false
	continue_button.disabled = SaveGame.load_data() == null

func _on_continue_pressed() -> void:
	run_startup.type = RunStartup.Type.CONTINUED_RUN
	get_tree().change_scene_to_packed(RUN_SCENE)

func _on_new_run_pressed() -> void:
	get_tree().change_scene_to_packed(CHAR_SELECTOR_SCENE)

func _on_settings_button_pressed() -> void:
	settings_panel.visible = not settings_panel.visible

func _input(event: InputEvent) -> void:
	if not settings_panel.visible:
		return
	# Esc fecha o painel; clicar fora dele (e fora da engrenagem) tambem fecha
	if event.is_action_pressed("ui_cancel"):
		settings_panel.hide()
		get_viewport().set_input_as_handled()
	elif event is InputEventMouseButton and event.pressed:
		var mouse := get_global_mouse_position()
		if not settings_panel.get_global_rect().has_point(mouse) and not settings_button.get_global_rect().has_point(mouse):
			settings_panel.hide()

func _on_how_to_play_pressed() -> void:
	settings_panel.hide()
	tutorial.open()

func _on_exit_pressed() -> void:
	get_tree().quit()
