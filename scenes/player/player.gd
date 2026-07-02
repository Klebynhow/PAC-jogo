class_name  Player
extends Node2D

const WHITE_SPRITE_MATERIAL := preload("res://art/white_sprite_material.tres")

@export var stats: CharacterStats : set = set_character_stats
@onready var vanessa_sprite_animado: Sprite2D = %VanessaSpriteAnimado
@onready var vanessa_attack_animation: Sprite2D = %VanessaAttackAnimation

@onready var sprite_2d: Sprite2D = $Sprite2D
@onready var stats_ui: StatsUI = $StatsUI as StatsUI
@onready var player_animation: AnimationPlayer = $PlayerAnimation

func _ready() -> void:
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

func take_damage(damage: int) -> void:
	if stats.health <= 0:
		return
	sprite_2d.material = WHITE_SPRITE_MATERIAL
	var tween := create_tween()
	tween.tween_callback(Shaker.shake.bind(self, 16, 0.15))
	tween.tween_callback(stats.take_damage.bind(damage))
	tween.tween_interval(0.17)
	tween.finished.connect(func(): 
		sprite_2d.material = null
		if stats.health <= 0: 
			Events.player_died.emit()
			queue_free()
		)
	

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
