class_name DamageEffect
extends Effect

var amount := 0
var receiver_modifier_type := Modifier.Type.DMG_TAKEN

# --- so para o modo "Mostrar contas" (nada aqui muda o dano) ---
# nome da origem quando nao ha atacante (Veneno, Sangue, Tinta...)
var label := ""
# dano antes dos modificadores de quem ataca (-1 = nao informado)
var base_amount := -1
var _attacker := ""
var _dealer_breakdown := {}

# Define o dano a partir do valor base, aplicando os modificadores de quem ataca (Forca, Fraco).
# Faz exatamente o mesmo que "amount = dealer.get_modified_value(base, DMG_DEALT)",
# mas guarda a conta para o modo "Mostrar contas".
func set_from_base(base: int, dealer: ModifierHandler) -> void:
	amount = dealer.get_modified_value(base, Modifier.Type.DMG_DEALT)
	base_amount = base
	if Settings.show_math:
		_dealer_breakdown = dealer.get_breakdown(base, Modifier.Type.DMG_DEALT)
		_attacker = CombatMath.owner_label(dealer.get_parent())

func execute(targets: Array[Node]) -> void:
	for target in targets:
		if not target:
			continue
		if target is Enemy or target is Player:
			target.take_damage(amount, receiver_modifier_type, _build_context())
			SFXPlayer.play(sound)

func _build_context() -> Dictionary:
	if not Settings.show_math:
		return {}
	return {"label": label, "base": base_amount, "attacker": _attacker, "dealer": _dealer_breakdown}
