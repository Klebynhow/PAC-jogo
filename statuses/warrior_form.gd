class_name WarriorFormStatus
extends Status

const TOUGHEN_STATUS = preload("res://statuses/toughen.tres")
var stacks_per_turn := 2

func apply_status(_target: Node) -> void:
	print("alvo: %s, aplicado warrior form" % _target)
	var status_effect := StatusEffect.new()
	var toughen := TOUGHEN_STATUS.duplicate()
	toughen.stacks = stacks_per_turn
	status_effect.status = toughen
	status_effect.execute([_target])
	status_applied.emit(self)
