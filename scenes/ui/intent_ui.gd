class_name  IntentUI
extends HBoxContainer

@onready var icon: TextureRect = $Icon
@onready var label: Label = $Label

func update_intent(intent: Intent) -> void:
	if not intent:
		hide()
		return
	icon.texture = intent.icon
	icon.visible = icon.texture != null
	var text := str(intent.current_text)
	if Settings.show_math and not intent.math_text.is_empty():
		text = intent.math_text
	label.text = text
	label.visible = text.length() > 0
	show()
