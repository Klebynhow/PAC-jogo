# meta-name: Effect
# meta-description: Cria um efeito que pode ser aplicado ao alvo
class_name MyEffect
extends Effect

var member_var := 0

func execute(_targets: Array[Node]) -> void:
	print("Teste: Efeito mira neles: %s" % _targets)
	print("Faz %s de algo" % member_var)
