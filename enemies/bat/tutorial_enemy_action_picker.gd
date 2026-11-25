class_name TutorialEnemyActionPicker
extends EnemyActionPicker

# IA do inimigo do tutorial do primeiro combate.
# No PRIMEIRO turno ele sempre faz o ataque anunciado (2x4), para o tutorial poder explicar
# a intencao com um numero conhecido. Depois disso volta ao sorteio normal por peso.

@export var opening_action_name := "AttackAction"

var _opening_done := false

func _ready() -> void:
	super._ready()
	Events.enemy_action_completed.connect(_on_enemy_action_completed)

func get_action() -> EnemyAction:
	if not _opening_done:
		var opening := get_node_or_null(opening_action_name) as EnemyAction
		if opening:
			return opening
	return super.get_action()

func _on_enemy_action_completed(completed_enemy: Enemy) -> void:
	if completed_enemy == enemy:
		_opening_done = true
