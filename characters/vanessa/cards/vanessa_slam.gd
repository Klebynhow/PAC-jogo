extends Card

@export var optional_sound: AudioStream

const EXPOSED_STATUS = preload("res://statuses/exposed.tres")
var base_damage := 6
var exposed_duration := 2

func apply_effects(_targets: Array[Node], _modifiers: ModifierHandler) -> void:
	var damage_effect := DamageEffect.new()
	damage_effect.amount = _modifiers.get_modified_value(base_damage, Modifier.Type.DMG_DEALT)
	damage_effect.sound = sound
	damage_effect.execute(_targets)
	
	var status_effect := StatusEffect.new()
	var exposed := EXPOSED_STATUS.duplicate()
	exposed.duration = exposed_duration
	status_effect.status = exposed
	status_effect.execute(_targets)
