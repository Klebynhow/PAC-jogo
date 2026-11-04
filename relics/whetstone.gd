extends Relic

const MUSCLE_STATUS = preload("res://statuses/muscle.tres")
@export var strength := 1

func activate_relic(owner: RelicUI) -> void:
	var player := owner.get_tree().get_first_node_in_group("player") as Player
	if not player:
		return
	var status_effect := StatusEffect.new()
	var muscle := MUSCLE_STATUS.duplicate()
	muscle.stacks = strength
	status_effect.status = muscle
	status_effect.execute([player])
	owner.flash()
