extends Card

# Causa dano igual ao escudo atual do jogador.

func get_default_tooltip() -> String:
	return tooltip_text

func get_updated_tooltip(_player_modifiers: ModifierHandler, _enemy_modifiers: ModifierHandler) -> String:
	return tooltip_text

func apply_effects(_targets: Array[Node], _modifiers: ModifierHandler) -> void:
	if _targets.is_empty() or not _targets[0]:
		return
	var player := _targets[0].get_tree().get_first_node_in_group("player") as Player
	if not player:
		return
	var block_value := player.stats.block
	var damage_effect := DamageEffect.new()
	damage_effect.amount = _modifiers.get_modified_value(block_value, Modifier.Type.DMG_DEALT) if block_value > 0 else 0
	damage_effect.sound = sound
	damage_effect.execute(_targets)
