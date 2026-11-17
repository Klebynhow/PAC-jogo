class_name MenuAnimation
extends Node

# Anima o menu principal sem precisar de arte nova:
#  - shader no primeiro plano (fita ciano, chamas, aura do livro, brilho no cabelo)
#  - logo flutuando devagar, com um brilho ciano que passa de tempos em tempos
#  - luzes suaves pulsando atras da Vanessa e do livro
#  - faiscas ciano e brasas subindo
# Este no deve ficar logo depois dos logos e antes dos botoes (veja main_menu.tscn).

const FOREGROUND_SHADER := preload("res://shaders/menu_foreground.gdshader")
const LOGO_SHADER := preload("res://shaders/logo_shine.gdshader")

const LOGO_BOB_AMOUNT := 1.5      # pixels para cima/baixo
const LOGO_BOB_TIME := 2.2        # segundos de cada subida/descida

var menu: Control

func _ready() -> void:
	menu = get_parent() as Control
	if not menu:
		return
	_setup_foreground_shader()
	_setup_logo_shine()
	_setup_glows()
	_setup_particles()
	# espera o layout do menu ficar pronto antes de ler as posicoes dos logos
	await get_tree().process_frame
	_start_logo_bob()

func _setup_foreground_shader() -> void:
	var foreground := menu.get_node_or_null("Foreground") as CanvasItem
	if foreground:
		var material := ShaderMaterial.new()
		material.shader = FOREGROUND_SHADER
		foreground.material = material

func _setup_logo_shine() -> void:
	var logo := menu.get_node_or_null("ForegroundGameTitle") as CanvasItem
	if logo:
		var material := ShaderMaterial.new()
		material.shader = LOGO_SHADER
		logo.material = material

func _start_logo_bob() -> void:
	for logo_name in ["BackgroundGameTitle", "ForegroundGameTitle"]:
		var logo := menu.get_node_or_null(logo_name) as Control
		if not logo:
			continue
		var base_y := logo.position.y
		var tween := create_tween().set_loops()
		tween.tween_property(logo, "position:y", base_y - LOGO_BOB_AMOUNT, LOGO_BOB_TIME) \
				.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
		tween.tween_property(logo, "position:y", base_y + LOGO_BOB_AMOUNT, LOGO_BOB_TIME) \
				.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)

# luzes redondas e suaves atras da arte (entre o fundo e o primeiro plano)
func _setup_glows() -> void:
	var foreground := menu.get_node_or_null("Foreground")
	if not foreground:
		return
	var glows := [
		_make_glow(Vector2(190, 95), 150.0, Color(0.1, 0.85, 0.95), 0.45),  # aura da Vanessa
		_make_glow(Vector2(131, 70), 70.0, Color(0.6, 0.15, 0.95), 0.5),    # livro
	]
	var delay := 0.0
	for glow in glows:
		menu.add_child(glow)
		menu.move_child(glow, foreground.get_index())
		var tween := create_tween().set_loops()
		tween.tween_interval(delay)
		tween.tween_property(glow, "modulate:a", 1.0, 1.6).from(0.45) \
				.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
		tween.tween_property(glow, "modulate:a", 0.45, 1.6) \
				.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
		delay += 0.9

func _make_glow(center: Vector2, diameter: float, color: Color, strength: float) -> TextureRect:
	var gradient := Gradient.new()
	gradient.offsets = PackedFloat32Array([0.0, 1.0])
	gradient.colors = PackedColorArray([Color(color, strength), Color(color, 0.0)])
	var texture := GradientTexture2D.new()
	texture.gradient = gradient
	texture.fill = GradientTexture2D.FILL_RADIAL
	texture.fill_from = Vector2(0.5, 0.5)
	texture.fill_to = Vector2(1.0, 0.5)
	texture.width = 64
	texture.height = 64
	var rect := TextureRect.new()
	rect.texture = texture
	rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	rect.stretch_mode = TextureRect.STRETCH_SCALE
	rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	rect.size = Vector2(diameter, diameter)
	rect.position = center - rect.size / 2.0
	rect.material = _additive_material()
	return rect

func _setup_particles() -> void:
	# faiscas ciano subindo perto da Vanessa
	add_child(_make_particles(Vector2(200, 100), Vector2(55, 45), 28, 3.2,
			Color(0.35, 0.95, 1.0), Vector2(6.0, 16.0), Vector2(0, -1), 25.0))
	# brasas avermelhadas espalhadas pela tela
	add_child(_make_particles(Vector2(128, 120), Vector2(128, 24), 14, 7.0,
			Color(1.0, 0.4, 0.25), Vector2(3.0, 8.0), Vector2(0.3, -1), 35.0))

func _make_particles(center: Vector2, extents: Vector2, amount: int, lifetime: float,
		color: Color, speed: Vector2, direction: Vector2, spread: float) -> CPUParticles2D:
	var particles := CPUParticles2D.new()
	particles.position = center
	particles.amount = amount
	particles.lifetime = lifetime
	particles.preprocess = lifetime  # ja comeca "cheio"
	particles.emission_shape = CPUParticles2D.EMISSION_SHAPE_RECTANGLE
	particles.emission_rect_extents = extents
	particles.direction = direction
	particles.spread = spread
	particles.gravity = Vector2.ZERO
	particles.initial_velocity_min = speed.x
	particles.initial_velocity_max = speed.y
	particles.scale_amount_min = 1.0
	particles.scale_amount_max = 1.0
	particles.color = color
	var ramp := Gradient.new()
	ramp.offsets = PackedFloat32Array([0.0, 0.25, 0.75, 1.0])
	ramp.colors = PackedColorArray([Color(1, 1, 1, 0), Color(1, 1, 1, 0.9), Color(1, 1, 1, 0.9), Color(1, 1, 1, 0)])
	particles.color_ramp = ramp
	particles.material = _additive_material()
	return particles

func _additive_material() -> CanvasItemMaterial:
	var material := CanvasItemMaterial.new()
	material.blend_mode = CanvasItemMaterial.BLEND_MODE_ADD
	return material
