class_name WarriorFormStatus
extends Status

# A cada inicio de turno: ganha Forca, mas o dano recebido em cada golpe tambem
# aumenta (e os dois acumulam). Quanto mais forte o ataque, mais fragil a defesa.
# O dano que ignora modificadores (veneno, Sede de Sangue) nao e afetado.

const MUSCLE_STATUS = preload("res://statuses/muscle.tres")
const PENALTY_ID := "warrior_form"

var stacks_per_turn := 2         # Forca ganha por turno
var damage_taken_per_turn := 1   # dano extra recebido em CADA golpe, por turno

func get_tooltip() -> String:
	return tooltip % [stacks_per_turn, damage_taken_per_turn]

func apply_status(_target: Node) -> void:
	var muscle := MUSCLE_STATUS.duplicate()
	muscle.stacks = stacks_per_turn
	var status_effect := StatusEffect.new()
	status_effect.status = muscle
	var targets: Array[Node] = [_target]
	status_effect.execute(targets)
	_increase_damage_taken(_target)
	status_applied.emit(self)

func _increase_damage_taken(_target: Node) -> void:
	if not _target.get("modifier_handler"):
		return
	var dmg_taken_modifier: Modifier = _target.modifier_handler.get_modifier(Modifier.Type.DMG_TAKEN)
	if not dmg_taken_modifier:
		return
	var penalty := dmg_taken_modifier.get_value(PENALTY_ID)
	if not penalty:
		penalty = ModifierValue.create_new_modifier(PENALTY_ID, ModifierValue.Type.FLAT)
		dmg_taken_modifier.add_new_value(penalty)
	penalty.flat_value += damage_taken_per_turn
