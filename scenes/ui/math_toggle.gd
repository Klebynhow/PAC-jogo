class_name MathToggle
extends Button

# Botao liga/desliga do modo "Mostrar contas" (Settings.show_math).
# Fica junto dos volumes: no menu de pausa (Esc) e na engrenagem do menu principal.
# Texto SEM acentos de proposito: a fonte pixel_rpg.ttf nao tem esses glifos.

func _ready() -> void:
	set_pressed_no_signal(Settings.show_math)
	_update_text()
	toggled.connect(_on_toggled)
	Settings.show_math_changed.connect(_on_setting_changed)

func _on_toggled(pressed_now: bool) -> void:
	Settings.set_show_math(pressed_now)

# outra tela mudou a opcao (ex.: o mesmo botao em outro menu): acompanha
func _on_setting_changed(value: bool) -> void:
	set_pressed_no_signal(value)
	_update_text()

func _update_text() -> void:
	text = "Mostrar contas: SIM" if button_pressed else "Mostrar contas: NAO"
