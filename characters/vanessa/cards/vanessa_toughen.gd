extends Card

@export var optional_sound: AudioStream
const MUSCLE_STATUS = preload("res://statuses/muscle.tres")

func apply_effects(_targets: Array[Node], _modifiers: ModifierHandler) -> void:
	var status_effect := StatusEffect.new()
	var toughen := MUSCLE_STATUS.duplicate()
	status_effect.status = toughen
	status_effect.execute(_targets)
