extends Card

var base_damage := 6
var base_block := 6

func get_default_tooltip() -> String:
	return tooltip_text % [base_damage, base_block]

func get_updated_tooltip(_player_modifiers: ModifierHandler, _enemy_modifiers: ModifierHandler) -> String:
	var modified_dmg := _player_modifiers.get_modified_value(base_damage, Modifier.Type.DMG_DEALT)
	if _enemy_modifiers:
		modified_dmg = _enemy_modifiers.get_modified_value(modified_dmg, Modifier.Type.DMG_TAKEN)
	return tooltip_text % [modified_dmg, base_block]

func apply_effects(_targets: Array[Node], _modifiers: ModifierHandler) -> void:
	if _targets.is_empty() or not _targets[0]:
		return
	var players := _targets[0].get_tree().get_nodes_in_group("player")

	var damage_effect := DamageEffect.new()
	damage_effect.amount = _modifiers.get_modified_value(base_damage, Modifier.Type.DMG_DEALT)
	damage_effect.sound = sound
	damage_effect.execute(_targets)

	var block_effect := BlockEffect.new()
	block_effect.amount = base_block
	block_effect.execute(players)
