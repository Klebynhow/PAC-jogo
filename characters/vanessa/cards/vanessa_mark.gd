extends Card

const EXPOSED_STATUS = preload("res://statuses/exposed.tres")
var exposed_duration := 2

func get_default_tooltip() -> String:
	return tooltip_text % exposed_duration

func get_updated_tooltip(_player_modifiers: ModifierHandler, _enemy_modifiers: ModifierHandler) -> String:
	return tooltip_text % exposed_duration

func apply_effects(_targets: Array[Node], _modifiers: ModifierHandler) -> void:
	var status_effect := StatusEffect.new()
	var exposed := EXPOSED_STATUS.duplicate()
	exposed.duration = exposed_duration
	status_effect.status = exposed
	status_effect.execute(_targets)
	SFXPlayer.play(sound)
