class_name Modifier
extends Node

enum Type {DMG_DEALT, DMG_TAKEN, CARD_COST, SHOP_COST, NO_MODIFIER}
@export var type: Type

func get_value(source: String) -> ModifierValue:
	for value: ModifierValue in get_children():
		if value.source == source:
			return value
	return null
	
func add_new_value(value: ModifierValue) -> void:
	var modifier_value := get_value(value.source)
	if not modifier_value:
		add_child(value)
	else:
		modifier_value.flat_value = value.flat_value
		modifier_value.percent_value = value.percent_value
	
func remove_value(source: String) -> void:
	for value: ModifierValue in get_children():
		if value.source == source:
			value.queue_free()
		
func clear_values() -> void:
	for value: ModifierValue in get_children():
		value.queue_free()
	
func get_modified_value(base: int) -> int:
	var flat_result: int = base
	var percent_result: float = 1.0
	for value: ModifierValue in get_children():
		if value.type == ModifierValue.Type.FLAT:
			flat_result += value.flat_value
	for value: ModifierValue in get_children():
		if value.type == ModifierValue.Type.PERCENT_BASED:
			percent_result += value.percent_value
	return floori(flat_result * percent_result)

# Mesma conta de get_modified_value, mas explicada (modo "Mostrar contas").
# Primeiro os valores fixos (flat), depois a soma dos percentuais vira um multiplicador.
func get_breakdown(base: int) -> Dictionary:
	var flat_parts: Array = []
	var percent_parts: Array = []
	var flat_result: int = base
	var percent_result: float = 1.0
	for value: ModifierValue in get_children():
		if value.type == ModifierValue.Type.FLAT:
			flat_result += value.flat_value
			if value.flat_value != 0:
				flat_parts.append({"source": value.source, "value": value.flat_value})
	for value: ModifierValue in get_children():
		if value.type == ModifierValue.Type.PERCENT_BASED:
			percent_result += value.percent_value
			if not is_zero_approx(value.percent_value):
				percent_parts.append({"source": value.source, "value": value.percent_value})
	var raw: float = flat_result * percent_result
	return {
		"base": base,
		"flat": flat_parts,
		"flat_total": flat_result,
		"percent": percent_parts,
		"multiplier": percent_result,
		"raw": raw,
		"result": floori(raw),
	}
	
