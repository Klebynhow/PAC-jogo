extends Card

# Dobra o Veneno do alvo. Sem Veneno, nao faz nada.

func get_default_tooltip() -> String:
	return tooltip_text

func get_updated_tooltip(_player_modifiers: ModifierHandler, _enemy_modifiers: ModifierHandler) -> String:
	return tooltip_text

func apply_effects(_targets: Array[Node], _modifiers: ModifierHandler) -> void:
	for target in _targets:
		if target is Enemy:
			var poison = target.status_handler.get_status("poison")
			if poison:
				poison.stacks *= 2
	SFXPlayer.play(sound)
