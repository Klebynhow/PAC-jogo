class_name DrainedStatus
extends Status

# Cansaco: no comeco do turno, perde 1 de mana (depois de a mana ser restaurada).
# Dura por turnos.

const MANA_LOSS := 1

func get_tooltip() -> String:
	return tooltip % duration

func apply_status(_target: Node) -> void:
	var stats = _target.get("stats")
	if stats and stats.get("mana") != null:
		stats.mana = maxi(stats.mana - MANA_LOSS, 0)
	super.apply_status(_target) # emite status_applied e o StatusHandler reduz a duracao
