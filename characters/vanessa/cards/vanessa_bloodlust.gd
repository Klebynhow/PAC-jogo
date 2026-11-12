extends Card

const MUSCLE_STATUS = preload("res://statuses/muscle.tres")
var hp_cost := 3
var strength := 2

func get_default_tooltip() -> String:
	return tooltip_text % [hp_cost, strength]

func get_updated_tooltip(_player_modifiers: ModifierHandler, _enemy_modifiers: ModifierHandler) -> String:
	return tooltip_text % [hp_cost, strength]

func apply_effects(_targets: Array[Node], _modifiers: ModifierHandler) -> void:
	var damage_effect := DamageEffect.new()
	damage_effect.amount = hp_cost
	damage_effect.receiver_modifier_type = Modifier.Type.NO_MODIFIER
	damage_effect.sound = sound
	damage_effect.execute(_targets)

	var status_effect := StatusEffect.new()
	var muscle := MUSCLE_STATUS.duplicate()
	muscle.stacks = strength
	status_effect.status = muscle
	status_effect.execute(_targets)
