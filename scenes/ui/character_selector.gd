# se algum dia eu quiser por mais personagem, é aq q eu venho 
extends Control

const RUN_SCENE = preload("res://scenes/Run/run.tscn")
const VANESSA_STATS := preload("res://characters/vanessa/vanessa.tres")

@onready var title: Label = %Titulo
@onready var description: Label = %Descricao
@onready var character_portrait: TextureRect = %CharacterPortrait

@export var run_startup: RunStartup

#var vanessa := load("res://characters/vanessa/vanessa.tres")
#var character = vanessa.create_instance()

var current_character: CharacterStats : set = set_current_character

func _ready() -> void:
	set_current_character(VANESSA_STATS)

func set_current_character(new_character: CharacterStats) -> void:
	current_character = new_character
	title.text = current_character.character_name
	description.text = current_character.description
	character_portrait.texture = current_character.portrait



func _on_start_button_pressed() -> void:
	print("oi poi run nova")
	run_startup.type = RunStartup.Type.NEW_RUN
	run_startup.picked_character = current_character
	get_tree().change_scene_to_packed(RUN_SCENE)


func _on_vanessa_button_pressed() -> void:
	current_character = VANESSA_STATS
