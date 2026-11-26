extends Card

const POISON_STATUS = preload("res://statuses/poison.tres")
var base_damage := 3
var poison_stacks := 3

func get_default_tooltip() -> String:
	return tooltip_text % [base_damage, poison_stacks]

func get_updated_tooltip(_player_modifiers: ModifierHandler, _enemy_modifiers: ModifierHandler) -> String:
	var modified_dmg := _player_modifiers.get_modified_value(base_damage, Modifier.Type.DMG_DEALT)
	if _enemy_modifiers:
		modified_dmg = _enemy_modifiers.get_modified_value(modified_dmg, Modifier.Type.DMG_TAKEN)
	return tooltip_text % [modified_dmg, poison_stacks]

func apply_effects(_targets: Array[Node], _modifiers: ModifierHandler) -> void:
	var damage_effect := DamageEffect.new()
	damage_effect.set_from_base(base_damage, _modifiers)
	damage_effect.sound = sound
	damage_effect.execute(_targets)
	for target in _targets:
		_apply_poison(target, poison_stacks)
func _apply_poison(target: Node, amount: int) -> void:
	# cada alvo recebe a sua propria copia do status
	var poison := POISON_STATUS.duplicate()
	poison.stacks = amount
	var status_effect := StatusEffect.new()
	status_effect.status = poison
	var targets: Array[Node] = [target]
	status_effect.execute(targets)
