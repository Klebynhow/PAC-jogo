class_name BattleBackgroundAnimation
extends Node2D

# Anima o cenario de batalha ("background" do battle.tscn) sem arte nova:
#  - shader: nuvens andando, vento no gramado, sombras de nuvem, runas pulsando
#  - polen dourado flutuando pelo campo e faiscas ciano subindo do orbe da torre
# Este no deve ficar logo depois do "background" (e antes do jogador e dos inimigos).

const BACKGROUND_SHADER := preload("res://shaders/battle_background.gdshader")

func _ready() -> void:
	var background := get_node_or_null("../background") as Sprite2D
	if background:
		var material := ShaderMaterial.new()
		material.shader = BACKGROUND_SHADER
		# o shader desenha a cor final, entao leva junto o modulate (escurecimento) original
		var tint := background.modulate
		material.set_shader_parameter("tint", Vector3(tint.r, tint.g, tint.b))
		background.modulate = Color.WHITE
		background.material = material
	# polen dourado no campo
	add_child(_make_particles(Vector2(128, 102), Vector2(128, 40), 14, 7.0,
			Color(1.0, 0.95, 0.65), Vector2(2.0, 5.0), Vector2(1, -0.3), 50.0))
	# faiscas do orbe da torre
	add_child(_make_particles(Vector2(128, 12), Vector2(16, 5), 10, 2.4,
			Color(0.55, 0.95, 1.0), Vector2(5.0, 10.0), Vector2(0, -1), 50.0))

func _make_particles(center: Vector2, extents: Vector2, amount: int, lifetime: float,
		color: Color, speed: Vector2, direction: Vector2, spread: float) -> CPUParticles2D:
	var particles := CPUParticles2D.new()
	particles.position = center
	particles.amount = amount
	particles.lifetime = lifetime
	particles.preprocess = lifetime
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
	var material := CanvasItemMaterial.new()
	material.blend_mode = CanvasItemMaterial.BLEND_MODE_ADD
	particles.material = material
	return particles
