extends EnemyAction

const MUSCLE_STATUS = preload("res://statuses/muscle.tres")

@export var block := 14
@export var stacks := 2
@export var hp_threshold := 26

var used := false

func is_performable() -> bool:
	if not enemy or used:
		return false
	var is_low := enemy.stats.health <= hp_threshold
	used = is_low
	return is_low

func perform_action() -> void:
	if not enemy or not target:
		return
	var block_effect := BlockEffect.new()
	block_effect.amount = block
	block_effect.sound = sound
	block_effect.execute([enemy])

	var status_effect := StatusEffect.new()
	var muscle := MUSCLE_STATUS.duplicate()
	muscle.stacks = stacks
	status_effect.status = muscle
	status_effect.execute([enemy])

	get_tree().create_timer(0.6, false).timeout.connect(
		func(): Events.enemy_action_completed.emit(enemy)
	)

func update_intent_text() -> void:
	if intent:
		intent.current_text = str(block)
