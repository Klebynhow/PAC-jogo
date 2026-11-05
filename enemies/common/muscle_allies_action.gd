extends EnemyAction

# Da Forca para todos os inimigos vivos (incluindo quem usa).
# Forca nao some quando o escudo reseta, ao contrario de dar escudo aos aliados.

const MUSCLE_STATUS = preload("res://statuses/muscle.tres")

@export var stacks := 1

func perform_action() -> void:
	if not enemy or not target:
		return
	for ally in get_tree().get_nodes_in_group("enemies"):
		var status_effect := StatusEffect.new()
		var muscle := MUSCLE_STATUS.duplicate()
		muscle.stacks = stacks
		status_effect.status = muscle
		var ally_array: Array[Node] = [ally]
		status_effect.execute(ally_array)
	SFXPlayer.play(sound)

	get_tree().create_timer(0.6, false).timeout.connect(
		func(): Events.enemy_action_completed.emit(enemy)
	)

func update_intent_text() -> void:
	if intent:
		intent.current_text = ""
