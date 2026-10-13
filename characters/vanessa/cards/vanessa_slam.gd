extends Card

@export var optional_sound: AudioStream

const EXPOSED_STATUS = preload("res://statuses/exposed.tres")
var base_damage := 6
var exposed_duration := 2

func get_default_tooltip() -> String:
	return tooltip_text % base_damage

func get_updated_tooltip(_player_modifiers: ModifierHandler, _enemy_modifiers: ModifierHandler) -> String:
	var modified_dmg := _player_modifiers.get_modified_value(base_damage, Modifier.Type.DMG_DEALT)
	if _enemy_modifiers:
		modified_dmg = _enemy_modifiers.get_modified_value(modified_dmg, Modifier.Type.DMG_TAKEN)
	return tooltip_text % modified_dmg

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
