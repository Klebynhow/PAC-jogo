extends Card

const WEAK_STATUS = preload("res://statuses/weak.tres")
var weak_duration := 2
var block_amount := 4

func get_default_tooltip() -> String:
	return tooltip_text % [weak_duration, block_amount]

func get_updated_tooltip(_player_modifiers: ModifierHandler, _enemy_modifiers: ModifierHandler) -> String:
	return tooltip_text % [weak_duration, block_amount]

func apply_effects(_targets: Array[Node], _modifiers: ModifierHandler) -> void:
	if _targets.is_empty() or not _targets[0]:
		return
	var players := _targets[0].get_tree().get_nodes_in_group("player")
	for target in _targets:
		var weak := WEAK_STATUS.duplicate()
		weak.duration = weak_duration
		var status_effect := StatusEffect.new()
		status_effect.status = weak
		var single_target: Array[Node] = [target]
		status_effect.execute(single_target)
	var block_effect := BlockEffect.new()
	block_effect.amount = block_amount
	block_effect.sound = sound
	block_effect.execute(players)
