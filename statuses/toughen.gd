class_name ToughenStatus
extends Status


func initialize_status(_target: Node) -> void:
	status_changed.connect(_on_status_changed)
	_on_status_changed()

func _on_status_changed() -> void:
	print("Status: +%s dano" %stacks)
