extends Card

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
	if block_value > 0:
		damage_effect.set_from_base(block_value, _modifiers)
	damage_effect.sound = sound
	damage_effect.execute(_targets)
