class_name CombatTutorial
extends CanvasLayer

# Tutorial guiado do PRIMEIRO combate da tentativa.
#
# Ensina, jogando de verdade (o jogo espera o jogador fazer cada acao):
#   1. INTENCAO  - o que o inimigo vai fazer e quanto dano isso significa (2x4 = 8)
#   2. ARRASTAR  - carta sem alvo (Defesa) e a conta do escudo contra a intencao
#   3. MIRAR     - carta com alvo (Ataque), a previsao ao vivo e a conta do dano:
#                  dano base -> modificadores (Forca/Fraco/Exposto) -> escudo -> vida
#   4. FIM       - previsao de quanto de vida o jogador perde, conferida com o resultado real
#
# Como a conta e a MESMA do jogo (ModifierHandler + Stats.take_damage), o que o tutorial mostra
# sempre bate com o que acontece de fato.
#
# O Battle cria este no (so no primeiro combate) e chama setup(). Ele se remove sozinho ao terminar.
# Textos SEM acentos de proposito: a fonte pixel_rpg.ttf nao tem esses glifos.

signal finished

enum Step {WAITING, INTENT, DRAG, DRAG_RESULT, AIM, AIM_RESULT, END_TURN, END_RESULT}

const THEME := preload("res://main_theme.tres")
const EXPOSED_STATUS := preload("res://statuses/exposed.tres")

# o inimigo do tutorial comeca Exposto e com escudo, para a conta mostrar os 3 elementos
const ENEMY_EXPOSED_TURNS := 2
const ENEMY_STARTING_BLOCK := 3
# espera depois de jogar a carta, para o efeito aparecer antes de explicar o resultado
const RESULT_DELAY := 0.7
# a dica do tooltip da carta desce um pouco para nao ficar embaixo da caixa do tutorial
const TOOLTIP_SHIFT := 36.0

const MODIFIER_NAMES := {"exposed": "Exposto", "weak": "Fraco", "muscle": "Forca"}
const Y := "[color=ffdf00]"
const R := "[color=ff6060]"
const B := "[color=60b0ff]"
const END := "[/color]"

var step := Step.WAITING

var battle: Battle
var player: Player
var enemy: Enemy
var char_stats: CharacterStats

# acoes ja feitas pelo jogador (podem acontecer fora de ordem; o tutorial se adapta)
var _drag_pending := false
var _drag_done := false
var _drag_body := ""
var _aim_pending := false
var _aim_done := false
var _aim_body := ""

# cartas sendo mirada agora (para a previsao ao vivo)
var _aiming: CardUI

# fim de turno: o que o jogador tinha antes do inimigo agir
var _waiting_enemy := false
var _hp_before := 0
var _block_before := 0
var _incoming_before := 0
var _predicted_loss := 0

var _end_button_locked := false
var _finishing := false
var _time := 0.0
var _shown_body := ""
var _tooltip: Control
var _tooltip_original_offsets := Vector2.ZERO

var _root: Control
var _dim: ColorRect
var _highlight: Panel
var _dialog: PanelContainer
var _title: Label
var _body: RichTextLabel
var _next_button: Button
var _skip_button: Button

func setup(new_battle: Battle) -> void:
	battle = new_battle
	player = battle.player
	char_stats = battle.char_stats
	# os inimigos "de enfeite" da cena de batalha so saem no fim do frame: ignora quem ja esta de saida
	for child in battle.enemy_handler.get_children():
		if not child.is_queued_for_deletion():
			enemy = child as Enemy
			break
	if not enemy:
		_finish(false)
		return
	_build_ui()
	_prepare_enemy()
	_shift_tooltip(true)
	Events.player_hand_drawn.connect(_on_player_hand_drawn)
	Events.card_played.connect(_on_card_played)
	Events.card_aim_started.connect(_on_card_aim_started)
	Events.card_aim_ended.connect(_on_card_aim_ended)
	Events.player_turn_ended.connect(_on_player_turn_ended)
	Events.enemy_action_completed.connect(_on_enemy_action_completed)
	Events.enemy_died.connect(_on_enemy_died)
	Events.player_died.connect(_on_player_died)
	_goto(Step.WAITING)

# ---------------------------------------------------------------- montagem da interface

func _build_ui() -> void:
	layer = 5
	_root = Control.new()
	_root.theme = THEME
	_root.set_anchors_preset(Control.PRESET_FULL_RECT)
	_root.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_root)

	# escurece a tela (e bloqueia o mouse) enquanto o passo e so uma explicacao
	_dim = ColorRect.new()
	_dim.set_anchors_preset(Control.PRESET_FULL_RECT)
	_dim.color = Color(0, 0, 0, 0.4)
	_dim.mouse_filter = Control.MOUSE_FILTER_STOP
	_root.add_child(_dim)

	# contorno amarelo piscando em volta do que o passo esta explicando
	_highlight = Panel.new()
	var outline := StyleBoxFlat.new()
	outline.bg_color = Color(0, 0, 0, 0)
	outline.border_color = Color("ffdf00")
	outline.set_border_width_all(1)
	_highlight.add_theme_stylebox_override("panel", outline)
	_highlight.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_highlight.hide()
	_root.add_child(_highlight)

	_dialog = PanelContainer.new()
	_dialog.position = Vector2(3, 2)
	_dialog.custom_minimum_size = Vector2(250, 0)
	_dialog.mouse_filter = Control.MOUSE_FILTER_STOP
	_root.add_child(_dialog)

	var margin := MarginContainer.new()
	for side in ["left", "top", "right", "bottom"]:
		margin.add_theme_constant_override("margin_" + side, 3)
	_dialog.add_child(margin)

	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 4)
	margin.add_child(row)

	var text_column := VBoxContainer.new()
	text_column.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	text_column.add_theme_constant_override("separation", 1)
	row.add_child(text_column)

	_title = Label.new()
	_title.add_theme_color_override("font_color", Color("ffdf00"))
	text_column.add_child(_title)

	_body = RichTextLabel.new()
	_body.bbcode_enabled = true
	_body.fit_content = true
	_body.scroll_active = false
	_body.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_body.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_body.custom_minimum_size = Vector2(150, 0)
	_body.add_theme_constant_override("line_separation", 1)
	text_column.add_child(_body)

	var button_column := VBoxContainer.new()
	button_column.alignment = BoxContainer.ALIGNMENT_END
	button_column.add_theme_constant_override("separation", 2)
	row.add_child(button_column)

	_next_button = Button.new()
	_next_button.text = "Continuar"
	_next_button.focus_mode = Control.FOCUS_NONE
	_next_button.pressed.connect(_on_next_pressed)
	button_column.add_child(_next_button)

	_skip_button = Button.new()
	_skip_button.text = "Pular"
	_skip_button.focus_mode = Control.FOCUS_NONE
	_skip_button.pressed.connect(_finish.bind(true))
	button_column.add_child(_skip_button)

func _prepare_enemy() -> void:
	enemy.stats.block = ENEMY_STARTING_BLOCK
	var exposed := EXPOSED_STATUS.duplicate() as Status
	exposed.duration = ENEMY_EXPOSED_TURNS
	var effect := StatusEffect.new()
	effect.status = exposed
	var targets: Array[Node] = [enemy]
	effect.execute(targets)

func _shift_tooltip(shifted: bool) -> void:
	if not _tooltip:
		_tooltip = battle.battle_ui.get_node_or_null("Tooltip") as Control
		if not _tooltip:
			return
		_tooltip_original_offsets = Vector2(_tooltip.offset_top, _tooltip.offset_bottom)
	var delta := TOOLTIP_SHIFT if shifted else 0.0
	_tooltip.offset_top = _tooltip_original_offsets.x + delta
	_tooltip.offset_bottom = _tooltip_original_offsets.y + delta

# ---------------------------------------------------------------- maquina de passos

func _goto(new_step: Step) -> void:
	step = new_step
	_shown_body = ""
	match step:
		Step.WAITING:
			_dialog.hide()
			_dim.hide()
		Step.INTENT:
			_show_dialog("1/4  INTENCAO", _text_intent(), true)
		Step.DRAG:
			_show_dialog("2/4  ARRASTAR", _text_drag(), false)
		Step.DRAG_RESULT:
			_show_dialog("2/4  A CONTA DO ESCUDO", _drag_body, true)
		Step.AIM:
			_ensure_mana()
			_show_dialog("3/4  MIRAR", _text_aim(), false)
		Step.AIM_RESULT:
			_show_dialog("3/4  A CONTA DO ATAQUE", _aim_body, true)
		Step.END_TURN:
			_unlock_end_button()
			_show_dialog("4/4  FIM DO TURNO", _text_end_turn(), false)
		Step.END_RESULT:
			_show_dialog("RESULTADO", _text_result(), true, "Jogar")

func _show_dialog(title: String, body: String, modal: bool, next_text := "Continuar") -> void:
	_title.text = title
	_set_body(body)
	_next_button.text = next_text
	_next_button.visible = modal
	_dim.visible = modal
	_dialog.show()

func _set_body(text: String) -> void:
	if text == _shown_body:
		return
	_shown_body = text
	_body.text = text
	_refit_dialog()

# a caixa so cresce sozinha: depois que o texto novo foi medido, manda ela encolher ao tamanho certo
func _refit_dialog() -> void:
	await get_tree().process_frame
	if _finishing or not is_instance_valid(_dialog):
		return
	_dialog.reset_size()

func _on_next_pressed() -> void:
	match step:
		Step.INTENT:
			_enter_drag_step()
		Step.DRAG_RESULT:
			_enter_aim_step()
		Step.AIM_RESULT:
			_goto(Step.END_TURN)
		Step.END_RESULT:
			_finish(false)

func _enter_drag_step() -> void:
	_goto(Step.DRAG_RESULT if _drag_done else Step.DRAG)

func _enter_aim_step() -> void:
	_goto(Step.AIM_RESULT if _aim_done else Step.AIM)

# chamado quando uma acao do jogador foi concluida: o passo atual pode ter acabado
func _advance() -> void:
	match step:
		Step.DRAG:
			if _drag_done:
				_goto(Step.DRAG_RESULT)
		Step.AIM:
			if _aim_done:
				_goto(Step.AIM_RESULT)
	_ensure_mana()

# se o jogador gastou a mana com outras cartas, devolve 1 para nao travar o tutorial
func _ensure_mana() -> void:
	if step < Step.DRAG or step > Step.AIM:
		return
	if (not _drag_done or not _aim_done) and char_stats.mana < 1:
		char_stats.mana = 1

func _finish(skipped: bool) -> void:
	if _finishing:
		return
	_finishing = true
	if skipped:
		Settings.set_combat_tutorial_skipped(true)
	if is_instance_valid(battle) and battle.is_inside_tree():
		_shift_tooltip(false)
		_unlock_end_button()
	finished.emit()
	queue_free()

# ---------------------------------------------------------------- eventos do jogo

func _on_player_hand_drawn() -> void:
	if step == Step.WAITING:
		_goto(Step.INTENT)
	# o botao Fim so abre no passo 4 (a mao nova de cada turno reabre o botao; fecha de novo)
	if step < Step.END_TURN:
		_lock_end_button()

func _on_card_played(card: Card) -> void:
	if step == Step.WAITING or step >= Step.END_TURN:
		return
	if card.is_single_targeted():
		await _register_attack(card)
	else:
		await _register_block(card)
	if is_instance_valid(self) and not _finishing:
		_advance()

func _register_block(card: Card) -> void:
	if _drag_done or _drag_pending or card.get("base_block") == null:
		return
	_drag_pending = true
	await get_tree().create_timer(RESULT_DELAY, false).timeout
	if _finishing or not is_instance_valid(player):
		return
	_drag_body = _text_drag_result(int(card.get("base_block")))
	_drag_done = true
	_drag_pending = false

func _register_attack(card: Card) -> void:
	if _aim_done or _aim_pending or card.get("base_damage") == null:
		return
	_aim_pending = true
	# a carta avisa ANTES de aplicar o efeito: guarda a previsao e o estado de agora
	var calc := _attack_calc(card)
	var health_before := enemy.stats.health
	await get_tree().create_timer(RESULT_DELAY, false).timeout
	if _finishing or not is_instance_valid(enemy):
		return
	_aim_body = _text_aim_result(calc, health_before, enemy.stats.health)
	_aim_done = true
	_aim_pending = false

func _on_card_aim_started(card_ui: CardUI) -> void:
	if step == Step.AIM and card_ui.card.is_single_targeted():
		_aiming = card_ui

func _on_card_aim_ended(_card_ui: CardUI) -> void:
	_aiming = null

func _on_player_turn_ended() -> void:
	if step != Step.END_TURN:
		return
	var incoming := _incoming_calc()
	_hp_before = player.stats.health
	_block_before = player.stats.block
	_incoming_before = incoming.total
	_predicted_loss = incoming.hp_loss
	_waiting_enemy = true
	# esconde a caixa para o jogador ver o turno do inimigo acontecer
	_dialog.hide()
	_dim.hide()
	_highlight.hide()

func _on_enemy_action_completed(acting_enemy: Enemy) -> void:
	if not _waiting_enemy or acting_enemy != enemy:
		return
	_waiting_enemy = false
	await get_tree().create_timer(RESULT_DELAY / 2.0, false).timeout
	if _finishing or not is_instance_valid(player):
		return
	_goto(Step.END_RESULT)

func _on_enemy_died(_dead_enemy: Enemy) -> void:
	_finish(false)

func _on_player_died() -> void:
	_finish(false)

# ---------------------------------------------------------------- botao Fim

func _lock_end_button() -> void:
	var button := battle.battle_ui.end_turn_button
	if not button.disabled:
		button.disabled = true
		_end_button_locked = true

func _unlock_end_button() -> void:
	if _end_button_locked:
		battle.battle_ui.end_turn_button.disabled = false
		_end_button_locked = false

# ---------------------------------------------------------------- a conta (mesma ordem do jogo)

# Ataque do jogador: dano base -> modificadores de quem ataca (Forca/Fraco)
# -> modificadores de quem recebe (Exposto) -> escudo do inimigo -> vida.
func _attack_calc(card: Card) -> Dictionary:
	var base_value: Variant = card.get("base_damage")
	if base_value == null or not is_instance_valid(enemy):
		return {}
	var base := int(base_value)
	var dealt := player.modifier_handler.get_modified_value(base, Modifier.Type.DMG_DEALT)
	var taken := enemy.modifier_handler.get_modified_value(dealt, Modifier.Type.DMG_TAKEN)
	var block := enemy.stats.block
	var absorbed := mini(block, taken)
	return {
		"base": base,
		"dealt": dealt,
		"dealt_mods": _modifier_label(player.modifier_handler, Modifier.Type.DMG_DEALT),
		"taken": taken,
		"taken_mods": _modifier_label(enemy.modifier_handler, Modifier.Type.DMG_TAKEN),
		"block": block,
		"absorbed": absorbed,
		"hp_loss": taken - absorbed,
	}

# Intencao do inimigo contra o jogador. O numero da intencao JA inclui os modificadores.
func _intent_info() -> Dictionary:
	var info := {"attack": false, "hits": 0, "per_hit": 0, "total": 0, "text": ""}
	if not is_instance_valid(enemy) or not enemy.current_action or not enemy.current_action.intent:
		return info
	var action := enemy.current_action
	info.text = str(action.intent.current_text)
	if action.get("damage") == null:
		return info
	var parts: PackedStringArray = info.text.split("x")
	if parts.size() == 2:
		info.hits = int(parts[0])
		info.per_hit = int(parts[1])
	else:
		info.hits = 1
		info.per_hit = int(info.text)
	info.attack = true
	info.total = info.hits * info.per_hit
	return info

func _incoming_calc() -> Dictionary:
	var info := _intent_info()
	var block := player.stats.block
	var absorbed := mini(block, info.total)
	return {"info": info, "total": info.total, "block": block, "absorbed": absorbed, "hp_loss": info.total - absorbed}

# "Exposto +50%", "Forca +2", "Fraco -25%"... (so os que mudam alguma coisa)
func _modifier_label(handler: ModifierHandler, type: Modifier.Type) -> String:
	var modifier := handler.get_modifier(type)
	if not modifier:
		return ""
	var parts: PackedStringArray = []
	for value: ModifierValue in modifier.get_children():
		var label: String = MODIFIER_NAMES.get(value.source, value.source)
		if value.type == ModifierValue.Type.FLAT:
			if value.flat_value != 0:
				parts.append("%s %+d" % [label, value.flat_value])
		elif not is_zero_approx(value.percent_value):
			parts.append("%s %+d%%" % [label, roundi(value.percent_value * 100.0)])
	return ", ".join(parts)

# ---------------------------------------------------------------- textos

func _red(value: Variant) -> String:
	return R + str(value) + END

func _blue(value: Variant) -> String:
	return B + str(value) + END

func _yellow(value: Variant) -> String:
	return Y + str(value) + END

func _text_intent() -> String:
	var info := _intent_info()
	var lines: PackedStringArray = []
	lines.append("Acima do inimigo aparece a " + _yellow("intencao") + ": o que ele fara no turno dele.")
	if info.attack:
		if info.hits > 1:
			lines.append("%s = %d golpes de %s = %s de dano no total." % [_yellow(info.text), info.hits, _red(info.per_hit), _red(info.total)])
		else:
			lines.append("%s = 1 golpe de %s de dano." % [_yellow(info.text), _red(info.total)])
		lines.append("Se voce nao se defender, perde " + _red(info.total) + " de vida.")
		lines.append("O numero ja inclui os modificadores (Forca, Fraco, Exposto).")
	else:
		lines.append("O icone mostra o tipo da acao e o numero mostra o valor.")
	return "\n".join(lines)

func _text_drag() -> String:
	var lines: PackedStringArray = []
	lines.append("Cartas " + _yellow("sem alvo") + " (como a Defesa): clique na carta, " + _yellow("arraste") + " para cima da mao e solte.")
	lines.append("Cada carta gasta mana: o custo fica no canto dela.")
	lines.append("Jogue agora a carta destacada.")
	return "\n".join(lines)

func _text_drag_result(block_gain: int) -> String:
	var incoming := _incoming_calc()
	var lines: PackedStringArray = []
	lines.append("Voce ganhou " + _blue(block_gain) + " de escudo (seu escudo agora: " + _blue(player.stats.block) + ").")
	if incoming.total > 0:
		lines.append("Intencao do inimigo: " + _red(incoming.total) + " de dano.")
		if incoming.hp_loss <= 0:
			lines.append("O escudo absorve tudo: voce nao perderia vida.")
		else:
			lines.append("Escudo absorve %d, sobram %s de dano na sua vida." % [incoming.absorbed, _red(incoming.hp_loss)])
	lines.append("O escudo some quando o seu proximo turno comeca.")
	return "\n".join(lines)

func _text_aim() -> String:
	if is_instance_valid(_aiming) and is_instance_valid(enemy) and _aiming.targets.has(enemy):
		var calc := _attack_calc(_aiming.card)
		if not calc.is_empty():
			var preview: PackedStringArray = [_yellow("PREVISAO DO ATAQUE") + " (antes de clicar):"]
			preview.append_array(_attack_lines(calc))
			preview.append("Clique no inimigo para atacar.")
			return "\n".join(preview)
	var lines: PackedStringArray = []
	lines.append("Cartas de " + _yellow("ataque") + " precisam de alvo: arraste a carta para cima da mao e ela vira uma " + _yellow("seta") + ".")
	lines.append("Aponte a seta para o inimigo: a previsao do dano aparece aqui antes de voce clicar.")
	lines.append("Clique no inimigo para atacar.")
	return "\n".join(lines)

func _text_aim_result(calc: Dictionary, health_before: int, health_after: int) -> String:
	if calc.is_empty():
		return "Ataque realizado! Vida do inimigo: %d -> %d." % [health_before, health_after]
	var lines := _attack_lines(calc)
	lines.append("Resultado real: vida do inimigo %d -> %s." % [health_before, _red(health_after)])
	return "\n".join(lines)

# passos da conta do ataque, numerados (so aparecem os que mudam o valor)
func _attack_lines(calc: Dictionary) -> PackedStringArray:
	var lines: PackedStringArray = []
	var n := 1
	lines.append("%d) Dano base da carta: %s" % [n, _red(calc.base)])
	n += 1
	if calc.dealt != calc.base:
		lines.append("%d) Seus modificadores (%s): %d -> %s" % [n, calc.dealt_mods, calc.base, _red(calc.dealt)])
		n += 1
	if calc.taken != calc.dealt:
		lines.append("%d) Modificadores do inimigo (%s): %d -> %s" % [n, calc.taken_mods, calc.dealt, _red(calc.taken)])
		n += 1
	if calc.block > 0:
		lines.append("%d) Escudo do inimigo (%s) absorve %d: sobram %s" % [n, _blue(calc.block), calc.absorbed, _red(calc.hp_loss)])
		n += 1
	lines.append("Vida do inimigo: -%s" % _red(calc.hp_loss))
	return lines

func _text_end_turn() -> String:
	var incoming := _incoming_calc()
	var lines: PackedStringArray = []
	lines.append(_yellow("Previsao") + " para o turno do inimigo:")
	lines.append("Ele causa " + _red(incoming.total) + " (" + incoming.info.text + ") e seu escudo (" + _blue(incoming.block) + ") absorve " + str(incoming.absorbed) + ".")
	lines.append("Voce deve perder %s de vida (%d -> %d)." % [_red(incoming.hp_loss), player.stats.health, player.stats.health - incoming.hp_loss])
	lines.append("Clique em " + _yellow("Fim") + " e confira se a conta bate.")
	return "\n".join(lines)

func _text_result() -> String:
	var real_loss := _hp_before - player.stats.health
	var lines: PackedStringArray = []
	lines.append("Previsto: -%s de vida. Real: -%s de vida (%d -> %d)." % [_red(_predicted_loss), _red(real_loss), _hp_before, player.stats.health])
	lines.append("Dos %s de dano, o escudo absorveu %s." % [_red(_incoming_before), _blue(mini(_block_before, _incoming_before))])
	lines.append("Lembre: intencao - escudo = dano na vida. Leia a intencao antes de jogar!")
	lines.append("Agora derrote o inimigo. Boa sorte!")
	return "\n".join(lines)

# ---------------------------------------------------------------- destaque e texto ao vivo

func _process(delta: float) -> void:
	_time += delta
	if _finishing:
		return
	# previsoes que mudam enquanto o jogador mira ou joga cartas
	match step:
		Step.AIM:
			_set_body(_text_aim())
		Step.END_TURN:
			if not _waiting_enemy:
				_set_body(_text_end_turn())
	_update_highlight()

func _update_highlight() -> void:
	var rect := _target_rect()
	if rect.size == Vector2.ZERO or not _dialog.visible:
		_highlight.hide()
		return
	_highlight.position = rect.position - Vector2.ONE
	_highlight.size = rect.size + Vector2(2, 2)
	_highlight.modulate.a = 0.65 + 0.35 * sin(_time * 7.0)
	_highlight.show()

func _target_rect() -> Rect2:
	if not is_instance_valid(enemy):
		return Rect2()
	match step:
		Step.INTENT:
			return _control_rect(enemy.intent_ui)
		Step.DRAG:
			return _control_rect(_find_card_ui(false))
		Step.DRAG_RESULT, Step.END_RESULT:
			return _control_rect(player.stats_ui)
		Step.AIM:
			if is_instance_valid(_aiming):
				return _enemy_rect()
			return _control_rect(_find_card_ui(true))
		Step.AIM_RESULT:
			return _control_rect(enemy.stats_ui)
		Step.END_TURN:
			return _control_rect(battle.battle_ui.end_turn_button)
	return Rect2()

func _control_rect(control: Control) -> Rect2:
	if not control or not is_instance_valid(control) or not control.is_visible_in_tree():
		return Rect2()
	return control.get_global_rect()

func _enemy_rect() -> Rect2:
	var sprite := enemy.sprite_2d
	return sprite.get_global_transform() * sprite.get_rect()

# carta da mao a destacar: a que o jogador esta segurando (fica fora da mao) ou a primeira do tipo
func _find_card_ui(wants_attack: bool) -> CardUI:
	var candidates: Array[Node] = []
	candidates.append_array(battle.battle_ui.get_children())
	candidates.append_array(battle.battle_ui.hand.get_children())
	var fallback: CardUI
	for node in candidates:
		var card_ui := node as CardUI
		if not card_ui or not card_ui.card:
			continue
		var wanted_id := "normal_attack" if wants_attack else "normal_block"
		if card_ui.card.id == wanted_id:
			return card_ui
		if not fallback and card_ui.card.is_single_targeted() == wants_attack and card_ui.card.type != Card.Type.POWER:
			fallback = card_ui
	return fallback
