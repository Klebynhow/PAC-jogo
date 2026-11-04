extends Relic

@export var block_amount := 2

var relic_ui: RelicUI

func initialize_relic(owner: RelicUI) -> void:
	relic_ui = owner
	if not Events.player_hit.is_connected(_on_player_hit):
		Events.player_hit.connect(_on_player_hit)

func deactivate_relic(_owner: RelicUI) -> void:
	if Events.player_hit.is_connected(_on_player_hit):
		Events.player_hit.disconnect(_on_player_hit)

func _on_player_hit() -> void:
	if not is_instance_valid(relic_ui):
		return
	var players := relic_ui.get_tree().get_nodes_in_group("player")
	var block_effect := BlockEffect.new()
	block_effect.amount = block_amount
	block_effect.execute(players)
	relic_ui.flash()
