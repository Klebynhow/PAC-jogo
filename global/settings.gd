extends Node

# Configuracoes do jogador: volume de musica e volume de efeitos.
# Autoload "Settings": aplica os volumes salvos assim que o jogo abre
# (inclusive na intro) e guarda a preferencia em user://settings.cfg.
#
# Cada canal mexe no seu bus (Music / SFX). 100% = o volume que voce ja
# deixou configurado no bus; o slider so diminui a partir dali.

signal volume_changed(channel: String, value: float)

const SETTINGS_PATH := "user://settings.cfg"
const BUSES := {"music": "Music", "sfx": "SFX"}

var _volumes := {"music": 1.0, "sfx": 1.0}  # 0.0 (mudo) a 1.0
var _base_db := {}                            # volume original de cada bus

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	for channel in BUSES:
		var bus := AudioServer.get_bus_index(BUSES[channel])
		_base_db[channel] = AudioServer.get_bus_volume_db(bus) if bus >= 0 else 0.0
	_load()
	for channel in BUSES:
		_apply(channel)

func get_volume(channel: String) -> float:
	return _volumes.get(channel, 1.0)

func set_volume(channel: String, value: float) -> void:
	if not BUSES.has(channel):
		return
	_volumes[channel] = clampf(value, 0.0, 1.0)
	_apply(channel)
	volume_changed.emit(channel, _volumes[channel])

func save() -> void:
	var config := ConfigFile.new()
	for channel in BUSES:
		config.set_value("audio", channel + "_volume", _volumes[channel])
	config.save(SETTINGS_PATH)

func _load() -> void:
	var config := ConfigFile.new()
	if config.load(SETTINGS_PATH) != OK:
		return
	# versao antiga do jogo salvava um unico "master_volume": usa como valor inicial
	var legacy := float(config.get_value("audio", "master_volume", 1.0))
	for channel in BUSES:
		_volumes[channel] = clampf(float(config.get_value("audio", channel + "_volume", legacy)), 0.0, 1.0)

func _apply(channel: String) -> void:
	var bus := AudioServer.get_bus_index(BUSES[channel])
	if bus < 0:
		return
	var volume: float = _volumes[channel]
	AudioServer.set_bus_mute(bus, volume <= 0.0)
	if volume > 0.0:
		AudioServer.set_bus_volume_db(bus, _base_db[channel] + linear_to_db(volume))
