# meta-name: Status
# meta-description: Cria um novo status que pode ser aplicado a um alvo
class_name MyStatus
extends Status

var member_var := 0

func initialize_status(_target: Node) -> void:
	print("oi poi teste %s" %_target)

func apply_status(_target: Node) -> void:
	print("alvo: %s" % _target)
	print("faz algo %s: " %member_var)
	status_applied.emit(self)
