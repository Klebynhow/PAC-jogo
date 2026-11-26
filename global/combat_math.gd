class_name CombatMath
extends RefCounted

# Textos do modo "Mostrar contas" (opcao Settings.show_math).
#
# Nada aqui muda o resultado do jogo: so EXPLICA a conta que o jogo ja faz
# (ModifierHandler.get_breakdown + Stats.take_damage), na mesma ordem:
#   dano base -> modificadores de quem ataca (Forca, Fraco)
#             -> modificadores de quem recebe (Exposto)
#             -> escudo -> vida
#
# Textos SEM acentos de proposito: a fonte pixel_rpg.ttf nao tem esses glifos.

const SOURCE_LABELS := {
	"muscle": "Forca",
	"weak": "Fraco",
	"exposed": "Exposto",
	"warrior_form": "Forma Guerreiro",
	"coupons": "Cupom",
}

const Y := "[color=ffdf00]"
const R := "[color=ff6060]"
const B := "[color=60b0ff]"
const END := "[/color]"

# ---------------------------------------------------------------- nomes

static func source_label(source: String) -> String:
	return String(SOURCE_LABELS.get(source, source.capitalize()))

# "Voce", "Inimigo" ou "Inimigo 2" (quando ha varios; o numero vem do EnemyHandler)
static func owner_label(node: Node) -> String:
	if node is Player:
		return "Voce"
	if node is Enemy:
		if int(node.get_meta("slot_total", 1)) > 1:
			return "Inimigo %d" % int(node.get_meta("slot", 1))
		return "Inimigo"
	return ""

static func _num(value: float) -> String:
	return str(snappedf(value, 0.01))

static func _sign(value: int) -> String:
	return "+" if value > 0 else "-"

# ---------------------------------------------------------------- log de combate

# "6 +2 Forca = 8" (valores fixos) e "8 x0.75 Fraco = 6" (percentuais).
# Vazio quando o modificador nao mudou nada.
static func modifier_lines(b: Dictionary) -> PackedStringArray:
	var lines := PackedStringArray()
	if b.is_empty():
		return lines
	var running: int = b.base
	if not b.flat.is_empty():
		var flat_text := str(running)
		for part: Dictionary in b.flat:
			flat_text += " %s%d %s" % [_sign(part.value), absi(part.value), source_label(part.source)]
		running = b.flat_total
		lines.append("%s = %s" % [flat_text, R + str(running) + END])
	if not b.percent.is_empty():
		var names := PackedStringArray()
		for part: Dictionary in b.percent:
			names.append(source_label(part.source))
		var percent_text := "%d x%s %s = " % [running, _num(b.multiplier), "/".join(names)]
		# o jogo arredonda para baixo: mostra o numero quebrado quando isso acontece
		if not is_equal_approx(float(b.raw), float(b.result)):
			percent_text += "%s -> " % _num(b.raw)
		lines.append(percent_text + R + str(b.result) + END)
	return lines

# A conta de UM golpe. context vem do DamageEffect, receiver_breakdown do alvo,
# result do Stats.take_damage.
static func damage_lines(context: Dictionary, receiver_breakdown: Dictionary, result: Dictionary, receiver: Node) -> PackedStringArray:
	var lines := PackedStringArray()

	var attacker: String = context.get("attacker", "")
	if attacker.is_empty():
		attacker = context.get("label", "")
	if attacker.is_empty():
		attacker = "Dano"
	lines.append("%s%s > %s%s" % [Y, attacker, owner_label(receiver), END])

	# modificadores: a primeira linha ja mostra o dano base; sem modificadores, so o dano
	var mod_lines := PackedStringArray()
	mod_lines.append_array(modifier_lines(context.get("dealer", {})))
	mod_lines.append_array(modifier_lines(receiver_breakdown))
	if mod_lines.is_empty():
		lines.append("Dano %s" % (R + str(result.damage) + END))
	else:
		lines.append_array(mod_lines)

	# escudo: o que o escudo absorve antes de chegar na vida
	if result.damage > 0 and result.block_before > 0:
		lines.append("%d - %s escudo = %s" % [result.damage, B + str(result.block_before) + END, R + str(result.through) + END])
		if result.block_after > 0:
			lines.append("Escudo sobra %s" % (B + str(result.block_after) + END))

	# vida
	if result.through > 0:
		lines.append("Vida %d - %s = %s" % [result.health_before, R + str(result.through) + END, R + str(result.health_after) + END])
	else:
		lines.append("Vida %d (nao perde)" % result.health_before)
	return lines

static func block_lines(target: Node, before: int, amount: int, after: int) -> PackedStringArray:
	var lines := PackedStringArray()
	lines.append("%s: escudo %d + %s = %s" % [owner_label(target), before, B + str(amount) + END, B + str(after) + END])
	return lines

# ---------------------------------------------------------------- intencao

# Texto da intencao com a conta: "6+2=8", "8 x1.5=12", "2x4=8", "2x(3+1=4)=8".
# Vazio quando nao ha nada para explicar (ataque simples de 1 golpe, sem modificadores)
# ou quando a opcao esta desligada. O current_text da intencao NAO muda
# (o tutorial do primeiro combate le esse texto).
static func intent_text(attacker: ModifierHandler, defender: ModifierHandler, base: int, hits: int = 1) -> String:
	if not Settings.show_math:
		return ""
	var dealt := attacker.get_breakdown(base, Modifier.Type.DMG_DEALT)
	var taken := defender.get_breakdown(dealt.result, Modifier.Type.DMG_TAKEN)
	var chain := _intent_chain(base, [dealt, taken])
	var per_hit: int = taken.result
	if hits > 1:
		if chain.is_empty():
			return "%dx%d=%d" % [hits, per_hit, hits * per_hit]
		return "%dx(%s)=%d" % [hits, chain, hits * per_hit]
	return chain

# cada etapa mostra o resultado parcial (o jogo arredonda a cada etapa), ex.: "6+2=8 x1.5=12"
static func _intent_chain(base: int, stages: Array) -> String:
	var text := str(base)
	for b: Dictionary in stages:
		if not b.flat.is_empty():
			var separator := " " if text.contains("=") else ""
			for part: Dictionary in b.flat:
				text += separator + _sign(part.value) + str(absi(part.value))
				separator = ""
			text += "=" + str(b.flat_total)
		if not b.percent.is_empty():
			text += " x" + _num(b.multiplier) + "=" + str(b.result)
	if text == str(base):
		return ""
	return text
