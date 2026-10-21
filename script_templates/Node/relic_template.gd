# meta-name: Artefatos
# meta-description: Cria uma reliquia que pode ser obtida pelo jogador
extends Relic

var member_var := 0

func initialize_relic(_owner: RelicUI) -> void:
	print("acontece uma vez quando ganhamos o artefato")

func activate_relic(_owner: RelicUI) -> void:
	print("acontece em determinados momentos baseado na propriedade de Relic.Type")

func deactivate_relic(_owner: RelicUI) -> void:
	print("é chamado quando uma RelicUI esta saíndo/sendo deletada da SceneTree")
	print("Artefatos baseados em evento devem sair do EventBus aq")

func get_tooltip() -> String:
	return tooltip
