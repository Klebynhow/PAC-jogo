extends Card

# Causa mais dano se o alvo estiver Exposto.

var base_damage := 4
var exposed_damage := 9

func get_default_tooltip() -> String:
	return tooltip_text % [base_damage, exposed_damage]

func get_updated_tooltip(_player_modifiers: ModifierHandler, _enemy_modifiers: ModifierHandler) -> String:
	var normal := _player_modifiers.get_modified_value(base_damage, Modifier.Type.DMG_DEALT)
	var bonus := _player_modifiers.get_modified_value(exposed_damage, Modifier.Type.DMG_DEALT)
	return tooltip_text % [normal, bonus]

func apply_effects(_targets: Array[Node], _modifiers: ModifierHandler) -> void:
	if _targets.is_empty() or not _targets[0]:
		return
	var damage := exposed_damage if _is_exposed(_targets[0]) else base_damage
	var damage_effect := DamageEffect.new()
	damage_effect.set_from_base(damage, _modifiers)
	damage_effect.sound = sound
	damage_effect.execute(_targets)

func _is_exposed(target: Node) -> bool:
	var handler = target.get("modifier_handler")
	if not handler:
		return false
	var taken: Modifier = handler.get_modifier(Modifier.Type.DMG_TAKEN)
	return taken != null and taken.get_value("exposed") != null
