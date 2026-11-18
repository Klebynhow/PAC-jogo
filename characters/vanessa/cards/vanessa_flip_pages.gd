extends Card

var cards_to_draw := 2

func get_default_tooltip() -> String:
	return tooltip_text % cards_to_draw

func get_updated_tooltip(_player_modifiers: ModifierHandler, _enemy_modifiers: ModifierHandler) -> String:
	return tooltip_text % cards_to_draw

func apply_effects(_targets: Array[Node], _modifiers: ModifierHandler) -> void:
	SFXPlayer.play(sound)
	Events.draw_cards_requested.emit(cards_to_draw)
