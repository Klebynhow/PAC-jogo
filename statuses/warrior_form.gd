class_name WarriorFormStatus
extends Status

const MUSCLE_STATUS = preload("res://statuses/muscle.tres")
var stacks_per_turn := 2

func apply_status(_target: Node) -> void:
	print("alvo: %s, aplicado warrior form" % _target)
	var status_effect := StatusEffect.new()
	var muscle := MUSCLE_STATUS.duplicate()
	muscle.stacks = stacks_per_turn
	status_effect.status = muscle
	status_effect.execute([_target])
	status_applied.emit(self)
