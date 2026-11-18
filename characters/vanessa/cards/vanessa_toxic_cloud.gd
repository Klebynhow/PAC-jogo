extends Card

const POISON_STATUS = preload("res://statuses/poison.tres")
var poison_stacks := 4

func get_default_tooltip() -> String:
	return tooltip_text % poison_stacks

func get_updated_tooltip(_player_modifiers: ModifierHandler, _enemy_modifiers: ModifierHandler) -> String:
	return tooltip_text % poison_stacks

func apply_effects(_targets: Array[Node], _modifiers: ModifierHandler) -> void:
	for target in _targets:
		_apply_poison(target, poison_stacks)
	SFXPlayer.play(sound)
func _apply_poison(target: Node, amount: int) -> void:
	# cada alvo recebe a sua propria copia do status
	var poison := POISON_STATUS.duplicate()
	poison.stacks = amount
	var status_effect := StatusEffect.new()
	status_effect.status = poison
	var targets: Array[Node] = [target]
	status_effect.execute(targets)
