extends EnemyAction

const MUSCLE_STATS = preload("res://statuses/muscle.tres")
@export var stacks_per_action := 2

var hp_treshold := 65
var usages := 0

func is_performable() -> bool:
	var hp_under_treshold := enemy.stats.health <= hp_treshold
	if usages == 0 or (usages == 1 and hp_under_treshold):
		usages += 1
		return true
	return false

func perform_action() -> void:
	if not enemy or not target:	return
	var status_effect := StatusEffect.new()
	var muscle := MUSCLE_STATS.duplicate()
	muscle.stacks = stacks_per_action
	status_effect.status = muscle
	status_effect.execute([enemy])
	
	SFXPlayer.play(sound)
	
	Events.enemy_action_completed.emit(enemy)
