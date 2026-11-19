extends Node

# fades em andamento: player -> {tween, volume original}
var _fades := {}

func play(audio: AudioStream, single=false) -> void:
	if not audio:
		return	
	_cancel_fades()
	if single:
		stop()
	for player in get_children():
		player = player as AudioStreamPlayer
		if not player.playing:
			player.stream = audio
			player.play()
			break

func stop() -> void:
	_cancel_fades()
	for player in get_children():
		player = player as AudioStreamPlayer
		player.stop()

# baixa o volume aos poucos e para (usado para a musica da batalha ao sair dela)
func fade_out(duration := 0.5) -> void:
	for player in get_children():
		player = player as AudioStreamPlayer
		if not player.playing or _fades.has(player):
			continue
		var original_db: float = player.volume_db
		var tween := create_tween().set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
		tween.tween_property(player, "volume_db", -40.0, duration)
		tween.tween_callback(_finish_fade.bind(player, original_db))
		_fades[player] = {"tween": tween, "volume": original_db}

func _finish_fade(player: AudioStreamPlayer, original_db: float) -> void:
	player.stop()
	player.volume_db = original_db
	_fades.erase(player)

# um play()/stop() novo durante o fade cancela o fade e devolve o volume
func _cancel_fades() -> void:
	for player in _fades:
		var info: Dictionary = _fades[player]
		info["tween"].kill()
		player.volume_db = info["volume"]
	_fades.clear()
