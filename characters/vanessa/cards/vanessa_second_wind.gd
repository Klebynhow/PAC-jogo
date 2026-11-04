extends Card

var mana_gain := 2

func get_default_tooltip() -> String:
	return tooltip_text % mana_gain

func get_updated_tooltip(_player_modifiers: ModifierHandler, _enemy_modifiers: ModifierHandler) -> String:
	return tooltip_text % mana_gain

func apply_effects(_targets: Array[Node], _modifiers: ModifierHandler) -> void:
	for target in _targets:
		if target is Player:
			target.stats.mana += mana_gain
	SFXPlayer.play(sound)
