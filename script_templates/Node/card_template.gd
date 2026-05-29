# meta-name: Logica de Card
# meta-description: O que acontece quando Card eh jogado
extends Card

@export var optional_sound: AudioStream

func apply_effects(_targets: Array[Node]) -> void:
	print("oi poi teste")
	print("Alvos: %s" % _targets)
