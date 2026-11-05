extends EnemyAction

# Aplica Exposto no jogador. Se "once_per_battle" estiver ligado, funciona
# como acao CONDICIONAL que so acontece uma vez (o primeiro turno).

const EXPOSED_STATUS = preload("res://statuses/exposed.tres")

@export var duration := 2
@export var once_per_battle := false

var used := false

func is_performable() -> bool:
	if not once_per_battle or used:
		return false
	used = true
	return true

func perform_action() -> void:
	if not enemy or not target:
		return
	var status_effect := StatusEffect.new()
	var exposed := EXPOSED_STATUS.duplicate()
	exposed.duration = duration
	status_effect.status = exposed
	var target_array: Array[Node] = [target]
	status_effect.execute(target_array)
	SFXPlayer.play(sound)

	get_tree().create_timer(0.6, false).timeout.connect(
		func(): Events.enemy_action_completed.emit(enemy)
	)
