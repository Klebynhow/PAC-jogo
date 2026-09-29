class_name ExposedStatus
extends Status

const MODIFIER := 0.5

func apply_status(_target: Node) -> void:
	print("%s deve tomar %s%% mais dano" % [_target, MODIFIER * 100]) # teste
	var damage_effect := DamageEffect.new()
	damage_effect.amount = 12
	damage_effect.execute([_target])
	status_applied.emit(self)
