extends Card

var heal_amount := 8

func get_default_tooltip() -> String:
	return tooltip_text % heal_amount

func get_updated_tooltip(_player_modifiers: ModifierHandler, _enemy_modifiers: ModifierHandler) -> String:
	return tooltip_text % heal_amount

func apply_effects(_targets: Array[Node], _modifiers: ModifierHandler) -> void:
	for target in _targets:
		if target is Player:
			target.stats.heal(heal_amount)
	SFXPlayer.play(sound)
