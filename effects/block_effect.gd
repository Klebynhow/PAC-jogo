class_name BlockEffect
extends Effect

var amount := 0

func execute(targets: Array[Node]) -> void:
	for target in targets:
		if not target:
			continue
		if target is Enemy or target is Player:
			var before: int = target.stats.block
			target.stats.block += amount
			if Settings.show_math:
				Events.combat_math_logged.emit(CombatMath.block_lines(target, before, amount, target.stats.block))
			SFXPlayer.play(sound)
