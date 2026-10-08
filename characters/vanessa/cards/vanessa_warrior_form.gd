extends Card

@export var optional_sound: AudioStream
const WARRIOR_FORM = preload("res://statuses/warrior_form.tres")

func apply_effects(_targets: Array[Node], _modifiers: ModifierHandler) -> void:
	var status_effect := StatusEffect.new()
	var warrior_form = WARRIOR_FORM.duplicate()
	status_effect.status = warrior_form
	status_effect.execute(_targets)
