class_name Stats
extends Resource

signal stats_changed

@export var max_health := 1
@export var art: Texture

var health: int : set = set_health
var block: int : set = set_block

func set_health(value: int) -> void:
	health = clampi(value, 0, max_health)
	stats_changed.emit()
	
func set_block(value : int) -> void:
	block = clampi(value, 0, 9999)
	stats_changed.emit()

# Devolve o que aconteceu (usado pelo modo "Mostrar contas"); quem nao precisa pode ignorar.
func take_damage(damage : int) -> Dictionary:
	var result := {
		"damage": damage,
		"block_before": block,
		"health_before": health,
		"absorbed": 0,
		"through": 0,
		"block_after": block,
		"health_after": health,
	}
	if damage <= 0:
		return result
	var initial_damage = damage
	damage = clampi(damage - block, 0, damage)
	block = clampi(block - initial_damage, 0, block)
	health -= damage
	result.absorbed = initial_damage - damage
	result.through = damage
	result.block_after = block
	result.health_after = health
	return result

func heal(amount : int) -> void:
	health += amount

func create_instance() -> Resource: 
	var instance: Stats = self.duplicate()
	instance.health = max_health
	instance.block = 0
	return instance
