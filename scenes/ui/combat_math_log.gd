class_name CombatMathLog
extends CanvasLayer

# Painel do modo "Mostrar contas" (Settings.show_math): durante o combate, mostra a conta
# de cada dano e de cada ganho de escudo, na ordem em que o jogo calcula:
#   dano base -> Forca/Fraco -> Exposto -> escudo -> vida
#
# O Battle cria este no. Ele so escuta o evento Events.combat_math_logged (quem calcula e
# quem monta o texto e o CombatMath) e some sozinho depois de alguns segundos.
# Textos SEM acentos de proposito: a fonte pixel_rpg.ttf nao tem esses glifos.

const THEME := preload("res://main_theme.tres")

# ajuste aqui se o painel ficar em cima de algo (a tela do jogo e 256x144)
const PANEL_POSITION := Vector2(2, 18)
const PANEL_WIDTH := 96.0
const MAX_LINES := 12          # quantas linhas cabem; entradas mais antigas saem primeiro
const ENTRY_SECONDS := 8.0     # quanto tempo cada conta fica na tela
const FADE_SECONDS := 1.0      # o painel apaga no ultimo segundo da conta mais recente

# cada entrada: {"lines": PackedStringArray, "age": float}
var _entries: Array[Dictionary] = []
var _root: Control
var _panel: PanelContainer
var _label: RichTextLabel

func _ready() -> void:
	layer = 1
	_build_ui()
	Events.combat_math_logged.connect(_on_math_logged)
	Settings.show_math_changed.connect(_on_show_math_changed)
	_refresh()

func _build_ui() -> void:
	_root = Control.new()
	_root.theme = THEME
	_root.set_anchors_preset(Control.PRESET_FULL_RECT)
	_root.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_root)

	_panel = PanelContainer.new()
	_panel.position = PANEL_POSITION
	_panel.custom_minimum_size = Vector2(PANEL_WIDTH, 0)
	_panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var style := StyleBoxFlat.new()
	style.bg_color = Color(0, 0, 0, 0.72)
	style.border_color = Color(0.43, 0.24, 0.09)
	style.set_border_width_all(1)
	style.set_content_margin_all(3)
	_panel.add_theme_stylebox_override("panel", style)
	_root.add_child(_panel)

	_label = RichTextLabel.new()
	_label.bbcode_enabled = true
	_label.fit_content = true
	_label.scroll_active = false
	_label.selection_enabled = false
	_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_label.add_theme_constant_override("line_separation", 1)
	_panel.add_child(_label)

func _on_math_logged(lines: PackedStringArray) -> void:
	if not Settings.show_math or lines.is_empty():
		return
	_entries.append({"lines": lines, "age": 0.0})
	# cabe pouco na tela: descarta as contas mais antigas (mas sempre mantem a mais nova)
	while _entries.size() > 1 and _total_lines() > MAX_LINES:
		_entries.pop_front()
	_refresh()

func _on_show_math_changed(value: bool) -> void:
	if not value:
		_entries.clear()
	_refresh()

func _total_lines() -> int:
	var total := 0
	for entry in _entries:
		total += entry.lines.size() + 1
	return total

func _process(delta: float) -> void:
	if _entries.is_empty():
		return
	var expired := false
	for entry in _entries:
		entry.age += delta
	while not _entries.is_empty() and _entries[0].age >= ENTRY_SECONDS:
		_entries.pop_front()
		expired = true
	if expired:
		_refresh()
	if not _entries.is_empty():
		var newest_age: float = _entries[_entries.size() - 1].age
		_panel.modulate.a = clampf((ENTRY_SECONDS - newest_age) / FADE_SECONDS, 0.0, 1.0)

func _refresh() -> void:
	_panel.visible = Settings.show_math and not _entries.is_empty()
	if _entries.is_empty():
		return
	_panel.modulate.a = 1.0
	var blocks := PackedStringArray()
	for entry in _entries:
		blocks.append("\n".join(entry.lines))
	_label.text = "\n\n".join(blocks)
	_refit_panel()

# o painel so cresce sozinho: depois que o texto novo foi medido, manda ele encolher ao tamanho certo
func _refit_panel() -> void:
	await get_tree().process_frame
	if is_instance_valid(_panel):
		_panel.reset_size()
