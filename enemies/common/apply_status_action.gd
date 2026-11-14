extends EnemyAction

# Aplica ate 2 status no jogador (ex.: Exposto, Fraco, Veneno, Cansaco).
# O "amount" vira duracao (status por turnos) ou acumulos (status de intensidade).
#
# Vira acao CONDICIONAL se "once_per_battle" estiver ligado (acontece uma vez,
# normalmente no 1o turno) ou se "hp_threshold" for maior que 0 (acontece uma vez,
# quando a vida do inimigo chega nesse valor). Sem nenhum dos dois, use como
# acao por sorteio (CHANCE_BASED).

@export var status_a: Status
@export var amount_a := 2
@export var status_b: Status
@export var amount_b := 2
@export var once_per_battle := false
@export var hp_threshold := 0

var used := false

func is_performable() -> bool:
	if used:
		return false
	if not once_per_battle and hp_threshold <= 0:
		return false
	if hp_threshold > 0 and (not enemy or enemy.stats.health > hp_threshold):
		return false
	used = true
	return true

func perform_action() -> void:
	if not enemy or not target:
		return
	_apply(status_a, amount_a)
	_apply(status_b, amount_b)
	SFXPlayer.play(sound)
	get_tree().create_timer(0.6, false).timeout.connect(
		func(): Events.enemy_action_completed.emit(enemy)
	)

func _apply(status: Status, amount: int) -> void:
	if not status:
		return
	var copy := status.duplicate() as Status
	match copy.stack_type:
		Status.StackType.DURATION:
			copy.duration = amount
		Status.StackType.INTENSITY:
			copy.stacks = amount
	var status_effect := StatusEffect.new()
	status_effect.status = copy
	var targets: Array[Node] = [target]
	status_effect.execute(targets)

func update_intent_text() -> void:
	if not intent:
		return
	# com um status so, mostra o valor; com dois, deixa so o icone
	intent.current_text = str(amount_a) if (status_a and not status_b) else ""
