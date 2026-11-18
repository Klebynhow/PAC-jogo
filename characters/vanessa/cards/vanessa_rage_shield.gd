extends Card

# Ganha escudo igual a 3 vezes a Forca atual (minimo 4). Combina com a Forma de Guerreiro.

var per_strength := 3
var min_block := 4

func get_default_tooltip() -> String:
	return tooltip_text % min_block

func get_updated_tooltip(_player_modifiers: ModifierHandler, _enemy_modifiers: ModifierHandler) -> String:
	return tooltip_text % _block_amount(_player_modifiers)

func apply_effects(_targets: Array[Node], _modifiers: ModifierHandler) -> void:
	var block_effect := BlockEffect.new()
	block_effect.amount = _block_amount(_modifiers)
	block_effect.sound = sound
	block_effect.execute(_targets)

func _block_amount(modifiers: ModifierHandler) -> int:
	var strength := 0
	var dealt: Modifier = modifiers.get_modifier(Modifier.Type.DMG_DEALT)
	if dealt:
		var muscle := dealt.get_value("muscle")
		if muscle:
			strength = int(muscle.flat_value)
	return maxi(min_block, per_strength * strength)
