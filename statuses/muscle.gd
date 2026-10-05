class_name MuscleStatus
extends Status


func initialize_status(_target: Node) -> void:
	status_changed.connect(_on_status_changed.bind(_target))
	_on_status_changed(_target)

func _on_status_changed(_target: Node) -> void:
	#lembrar de tirar essas carniça de assert depois
	assert(_target.get("modifier_handler"),  "Sem modifiers em %s" %_target)
	var dmg_dealt_modifier: Modifier = _target.modifier_handler.get_modifier(Modifier.Type.DMG_DEALT)
	assert(dmg_dealt_modifier, "Sem modifiers de DMG DEALT em %s" %_target)
	
	var muscle_modifier_value := dmg_dealt_modifier.get_value("muscle")
	if not muscle_modifier_value:
		muscle_modifier_value = ModifierValue.create_new_modifier("muscle", ModifierValue.Type.FLAT)
	muscle_modifier_value.flat_value = stacks 
	dmg_dealt_modifier.add_new_value(muscle_modifier_value)
