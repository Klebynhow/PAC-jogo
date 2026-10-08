class_name ExposedStatus
extends Status

const MODIFIER := 0.5

func initialize_status(_target: Node) -> void:
	assert(_target.get("modifier_handler"), "Sem modificadores em %s" %_target)
	var dmg_taken_modifier: Modifier = _target.modifier_handler.get_modifier(Modifier.Type.DMG_TAKEN)
	assert(dmg_taken_modifier, "Sem modifier de dmg taken em %s" %_target)
	var exposed_modifier_value := dmg_taken_modifier.get_value("exposed")
	if not exposed_modifier_value:
		exposed_modifier_value = ModifierValue.create_new_modifier("exposed", ModifierValue.Type.PERCENT_BASED)
		exposed_modifier_value.percent_value = MODIFIER
		dmg_taken_modifier.add_new_value(exposed_modifier_value)
	if not status_changed.is_connected(_on_status_changed):
		status_changed.connect(_on_status_changed.bind(dmg_taken_modifier))
	
func _on_status_changed(dmg_taken_modifier: Modifier) -> void:
	if duration <= 0 and dmg_taken_modifier: dmg_taken_modifier.remove_value("exposed")
	
