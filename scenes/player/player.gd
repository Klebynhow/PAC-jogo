class_name  Player
extends Node2D

const WHITE_SPRITE_MATERIAL := preload("res://art/white_sprite_material.tres")

@export var stats: CharacterStats : set = set_character_stats
@onready var vanessa_sprite_animado: Sprite2D = %VanessaSpriteAnimado
@onready var vanessa_attack_animation: Sprite2D = %VanessaAttackAnimation
@onready var player_animation: AnimationPlayer = $PlayerAnimation
@onready var status_handler: StatusHandler = $StatusHandler
@onready var sprite_2d: Sprite2D = $Sprite2D
@onready var stats_ui: StatsUI = $StatsUI as StatsUI
@onready var modifier_handler: ModifierHandler = $ModifierHandler

func _ready() -> void:
	status_handler.status_owner = self
	Events.card_played.connect(_on_card_played)
	player_animation.animation_finished.connect(_on_animation_finished)
	vanessa_sprite_animado.show()
	vanessa_attack_animation.hide()
	if player_animation.has_animation("idle"):
		player_animation.play("idle")

func set_character_stats(value: CharacterStats) -> void:
	stats = value
	
	if not stats.stats_changed.is_connected(update_stats):
		stats.stats_changed.connect(update_stats)
	update_player()
	
func update_player() -> void:
	if not stats is CharacterStats:
		return
	if not is_inside_tree():
		await ready
	sprite_2d.texture = stats.art
	#$PlayerAnimation.play("idle")
	if not player_animation.is_playing():
		player_animation.play("idle")
	update_stats()
	
func update_stats() -> void:
	stats_ui.update_stats(stats)

func take_damage(damage: int, modifier_type: Modifier.Type, context: Dictionary = {}) -> void:
	if stats.health <= 0:
		return
	sprite_2d.material = WHITE_SPRITE_MATERIAL
	var modifier_damage := modifier_handler.get_modified_value(damage, modifier_type)
	# modo "Mostrar contas": guarda a conta dos modificadores de quem recebe (nao muda o dano)
	var receiver_breakdown := {}
	if Settings.show_math and not context.is_empty():
		receiver_breakdown = modifier_handler.get_breakdown(damage, modifier_type)
	var tween := create_tween()
	tween.tween_callback(Shaker.shake.bind(self, 16, 0.15))
	tween.tween_callback(_apply_damage.bind(modifier_damage, receiver_breakdown, context))
	tween.tween_interval(0.17)
	tween.finished.connect(func(): 
		sprite_2d.material = null
		if stats.health <= 0: 
			Events.player_died.emit()
			queue_free()
		)
	
# aplica o dano de verdade (escudo e vida); com "Mostrar contas" tambem registra a conta
func _apply_damage(amount: int, receiver_breakdown: Dictionary, context: Dictionary) -> void:
	var result := stats.take_damage(amount)
	if Settings.show_math and not context.is_empty():
		Events.combat_math_logged.emit(CombatMath.damage_lines(context, receiver_breakdown, result, self))

func _on_card_played(card) -> void:
	player_animation.stop()
	vanessa_attack_animation.show()
	vanessa_sprite_animado.hide()
	player_animation.play("vanessa_attack")

func _on_animation_finished(anim_name: String) -> void:
	if anim_name != "idle":
		vanessa_attack_animation.hide()
		vanessa_sprite_animado.show()
		player_animation.play("idle")
