class_name VolumeRow
extends HBoxContainer

# Uma linha de volume: "Musica [slider] 80%" ou "Efeitos [slider] 80%".
# Fala com o autoload Settings, entao varias linhas ficam sincronizadas.

@export_enum("music", "sfx") var channel := "music"

@onready var name_label: Label = %Name
@onready var slider: HSlider = %Slider
@onready var percent_label: Label = %Percent
@onready var test_sound: AudioStreamPlayer = %TestSound
@onready var test_music: AudioStreamPlayer = %TestMusic

var dragging := false
var _preview: AudioStreamPlayer
var _preview_id := 0

func _ready() -> void:
	name_label.text = "Musica" if channel == "music" else "Efeitos"
	# cada linha usa so o som de teste do seu canal
	if channel == "music":
		_preview = test_music
		test_sound.queue_free()
	else:
		_preview = test_sound
		test_music.queue_free()
	_show_value(Settings.get_volume(channel))
	slider.value_changed.connect(_on_value_changed)
	slider.drag_started.connect(func(): dragging = true)
	slider.drag_ended.connect(_on_drag_ended)
	Settings.volume_changed.connect(_on_settings_volume_changed)

func _on_settings_volume_changed(changed_channel: String, volume: float) -> void:
	if changed_channel == channel:
		_show_value(volume)

func _show_value(volume: float) -> void:
	# set_value_no_signal evita o laco slider -> Settings -> slider
	slider.set_value_no_signal(roundf(volume * 100.0))
	percent_label.text = "%d%%" % roundi(volume * 100.0)

func _on_value_changed(value: float) -> void:
	Settings.set_volume(channel, value / 100.0)
	# ao arrastar, so salva quando soltar; por teclado/roda do mouse, salva na hora
	if not dragging:
		Settings.save()

func _on_drag_ended(value_changed: bool) -> void:
	dragging = false
	if value_changed:
		Settings.save()
		_play_preview()

# toca um trecho curto para o jogador ouvir o novo volume
func _play_preview() -> void:
	_preview_id += 1
	var id := _preview_id
	_preview.play()
	if channel == "music":
		await get_tree().create_timer(1.2).timeout
		if id == _preview_id:
			_preview.stop()
