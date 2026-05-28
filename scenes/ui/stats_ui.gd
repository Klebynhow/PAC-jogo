class_name StatsUI
extends HBoxContainer

@onready var block: HBoxContainer = $Block
@onready var block_label: Label = %BlockLabel
@onready var health: HBoxContainer = $Health
@onready var healt_label: Label = %HealthLabel

func update_stats(stats: Stats) -> void:
	block_label.text = str(stats.block)
	healt_label.text = str(stats.health)
	
	block.visible = stats.block > 0
	health.visible = stats.health > 0
