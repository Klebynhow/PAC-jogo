class_name PoisonStatus
extends Status

# Veneno: no comeco do turno de quem esta envenenado, recebe dano igual ao
# numero de acumulos e perde 1 acumulo. O dano passa pelo escudo como qualquer
# outro dano, mas ignora modificadores (como o Exposto).

func get_tooltip() -> String:
	return tooltip % stacks

func apply_status(_target: Node) -> void:
	var damage_effect := DamageEffect.new()
	damage_effect.amount = stacks
	damage_effect.receiver_modifier_type = Modifier.Type.NO_MODIFIER
	var targets: Array[Node] = [_target]
	damage_effect.execute(targets)
	stacks -= 1
	status_applied.emit(self)
