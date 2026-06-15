extends Card

@export var optional_sound: AudioStream

func apply_effects(_targets: Array[Node]) -> void:
	var damage_effect := DamageEffect.new()
	damage_effect.amount = 10
	damage_effect.sound = sound
	damage_effect.execute(_targets)
	print("n fiz o efeito ainda")
