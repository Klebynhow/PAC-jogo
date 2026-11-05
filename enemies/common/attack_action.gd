extends EnemyAction

# Ataque generico: dano, numero de golpes e (opcional) carta de debuff
# que vai para a pilha de compra do jogador depois do golpe.

@export var damage := 5
@export var hits := 1
@export var debuff_card: Card
@export var debuff_card_count := 1

func perform_action() -> void:
	if not enemy or not target:
		return
	var player := target as Player
	if not player:
		return

	var tween := create_tween().set_trans(Tween.TRANS_QUINT)
	var start := enemy.global_position
	var end := target.global_position + Vector2.RIGHT * 32
	var damage_effect := DamageEffect.new()
	var target_array: Array[Node] = [target]
	damage_effect.amount = enemy.modifier_handler.get_modified_value(damage, Modifier.Type.DMG_DEALT)
	damage_effect.sound = sound

	tween.tween_property(enemy, "global_position", end, 0.4)
	for i in hits:
		tween.tween_callback(damage_effect.execute.bind(target_array))
		if i < hits - 1:
			tween.tween_interval(0.35)
	if debuff_card:
		for i in debuff_card_count:
			tween.tween_callback(player.stats.draw_pile.add_card.bind(debuff_card.duplicate()))
	tween.tween_interval(0.25)
	tween.tween_property(enemy, "global_position", start, 0.4)

	tween.finished.connect(func(): Events.enemy_action_completed.emit(enemy))

func update_intent_text() -> void:
	var player := target as Player
	if not player or not intent:
		return
	var dealt := enemy.modifier_handler.get_modified_value(damage, Modifier.Type.DMG_DEALT)
	var final_dmg := player.modifier_handler.get_modified_value(dealt, Modifier.Type.DMG_TAKEN)
	if hits > 1:
		intent.current_text = "%sx%s" % [hits, final_dmg]
	else:
		intent.current_text = str(final_dmg)
