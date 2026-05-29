extends Node2D

@export var char_stats: CharacterStats

@onready var battle_ui: BattleUI = $battleUI as BattleUI
@onready var player_handler: PlayerHandler = $PlayerHandler as PlayerHandler

#mudar essa aq pra run quando tive niveis
func _ready() -> void:
	var new_stats: CharacterStats = char_stats.create_instance()
	battle_ui.char_stats = new_stats
	
	start_battle(new_stats)

func start_battle(stats: CharacterStats) -> void:
	player_handler.start_battle(stats)
