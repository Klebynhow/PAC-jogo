class_name WeakStatus
extends Status

# Fraco: quem esta Fraco causa 25% menos dano. Dura por turnos (como o Exposto).

const MODIFIER := -0.25

func get_tooltip() -> String:
	return tooltip % duration

func initialize_status(_target: Node) -> void:
	assert(_target.get("modifier_handler"), "Sem modificadores em %s" % _target)
	var dmg_dealt_modifier: Modifier = _target.modifier_handler.get_modifier(Modifier.Type.DMG_DEALT)
	assert(dmg_dealt_modifier, "Sem modifier de dmg dealt em %s" % _target)
	var weak_value := dmg_dealt_modifier.get_value("weak")
	if not weak_value:
		weak_value = ModifierValue.create_new_modifier("weak", ModifierValue.Type.PERCENT_BASED)
		weak_value.percent_value = MODIFIER
		dmg_dealt_modifier.add_new_value(weak_value)
	status_changed.connect(_on_status_changed.bind(dmg_dealt_modifier))

func _on_status_changed(dmg_dealt_modifier: Modifier) -> void:
	if duration <= 0 and is_instance_valid(dmg_dealt_modifier):
		dmg_dealt_modifier.remove_value("weak")
