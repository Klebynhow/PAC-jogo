class_name Tutorial
extends Control

signal closed

const COIN := "[img=7]res://art/coinIcon.png[/img]"
const HEART := "[img=7]res://art/heart_icon.png[/img]"
const SHIELD := "[img=7]res://art/shield_icon.png[/img]"
const DECK := "[img=7]res://art/deckIcon.png[/img]"
const DRAW := "[img=7]res://art/drawIcon.png[/img]"
const DISCARD := "[img=7]res://art/discardIcon.png[/img]"
const EXPOSED := "[img=7]res://art/exposed_icon.png[/img]"
const STRENGTH := "[img=7]res://art/toughen_icon.png[/img]"
const RIPPED := "[img=7]res://art/ripped_page_icon.png[/img]"
const COMBAT := "[img=7]res://art/combat-icon.png[/img]"
const SHOP := "[img=7]res://art/shop-icon.png[/img]"
const CAMPFIRE := "[img=7]res://art/ph_healthIcon.png[/img]"
const CHEST := "[img=7]res://art/chest-icon.png[/img]"
const BOSS := "[img=7]res://art/boss-encounter-icon.png[/img]"
const Y := "[color=\"ffdf00\"]"
const END := "[/color]"

const PAGES := [
	{
		"title": "OBJETIVO",
		"lines": [
			"Guie " + Y + "Vanessa" + END + " por " + Y + "15 andares" + END + " ate o chefe final.",
			"",
			"Cada sala do mapa pode ser combate, loja, fogueira ou tesouro.",
			"",
			COIN + " Vencer combates rende ouro, cartas e artefatos para fortalecer seu baralho.",
			"",
			HEART + " Se sua vida chegar a zero, a tentativa acaba. Derrote o chefe do ultimo andar para vencer o jogo.",
		],
	},
	{
		"title": "CONTROLES",
		"lines": [
			Y + "Botao esquerdo:" + END + " clicar, jogar cartas e escolher salas.",
			Y + "Botao direito:" + END + " cancelar a carta que esta segurando.",
			Y + "Roda do mouse:" + END + " rolar o mapa.",
			Y + "Esc:" + END + " pausar o jogo (neste guia, fecha o guia).",
			Y + "Setas esquerda/direita:" + END + " trocar de pagina deste guia.",
		],
	},
	{
		"title": "JOGANDO CARTAS",
		"lines": [
			Y + "Cartas sem alvo" + END + " (Defesa, poderes):",
			"- arraste a carta para cima da mao e solte.",
			"",
			Y + "Cartas com alvo" + END + " (ataques):",
			"- arraste a carta para cima da mao. Ela vira uma seta de mira.",
			"- aponte a seta para o inimigo e clique.",
			"",
			Y + "Cancelar:" + END + " botao direito, ou leve o mouse para a parte de baixo da tela.",
		],
	},
	{
		"title": "TELA DE COMBATE",
		"lines": [
			COIN + " Ouro: canto superior esquerdo.",
			HEART + " Vida: perto da Vanessa. " + SHIELD + " Escudo: absorve dano.",
			"Mana (3/3): canto inferior esquerdo. Cartas gastam mana.",
			"Cartas: embaixo. O numero da carta e o custo de mana.",
			"Botao " + Y + "Fim" + END + ": encerra seu turno.",
			DECK + " Baralho: canto superior direito.",
			DRAW + " Pilha de compra e " + DISCARD + " descarte: cantos de baixo.",
		],
	},
	{
		"title": "O TURNO",
		"lines": [
			"1. Voce compra 5 cartas e a mana volta ao maximo.",
			"2. Jogue cartas enquanto tiver mana.",
			"3. Clique em Fim: a mao vai para o descarte.",
			"4. Os inimigos executam o que anunciaram.",
			"5. Um novo turno comeca.",
			"",
			SHIELD + " O escudo some quando seu turno comeca: jogue defesas antes do Fim.",
			"Cartas com " + Y + "Exaurir" + END + " saem do baralho ate o fim do combate.",
		],
	},
	{
		"title": "INTENCOES DOS INIMIGOS",
		"lines": [
			"Acima de cada inimigo aparece o que ele fara no proximo turno.",
			"O icone mostra o tipo (ataque, defesa, buff, debuff) e o numero mostra o valor.",
			"",
			Y + "2x4" + END + " = 2 golpes de 4 de dano (8 no total).",
			"O numero ja inclui status como Exposto e Forca.",
			"",
			"Some o dano dos inimigos para saber quanto vai receber e decida se vale atacar ou defender.",
		],
	},
	{
		"title": "STATUS E CARTAS RUINS",
		"lines": [
			"Os status ficam abaixo da vida. Clique no icone para ler a descricao.",
			"",
			EXPOSED + " " + Y + "Exposto" + END + ": sofre 50% mais dano.",
			STRENGTH + " " + Y + "Forca" + END + ": ataques causam mais dano.",
			"",
			RIPPED + " " + Y + "Cartas de debuff" + END + " (ex.: Pagina Rasgada) sao colocadas no seu baralho por alguns inimigos.",
			"Elas atrapalham sua mao e somem quando o combate acaba.",
		],
	},
	{
		"title": "O MAPA",
		"lines": [
			"Escolha uma sala ligada a sua posicao. Role o mapa com a roda do mouse.",
			COMBAT + " Combate: ganhe ouro e escolha 1 entre 3 cartas (ou pule).",
			SHOP + " Loja: compre cartas e artefatos.",
			CAMPFIRE + " Fogueira: recupere 30% da vida.",
			CHEST + " Tesouro: receba um artefato aleatorio.",
			BOSS + " Chefe: ultimo andar. Derrote-o para vencer.",
		],
	},
	{
		"title": "ARTEFATOS E DICAS",
		"lines": [
			Y + "Artefatos" + END + " sao itens passivos no topo da tela. Clique em um para ler o efeito.",
			"",
			Y + "Dicas" + END,
			"- Leia as intencoes antes de jogar.",
			"- Nem toda carta nova ajuda: voce pode pular a recompensa.",
			"- Descanse na fogueira quando a vida estiver baixa.",
			"- O jogo salva ao entrar em cada sala: use Continuar no menu.",
		],
	},
]

@onready var title_label: Label = %Title
@onready var body: RichTextLabel = %Body
@onready var page_label: Label = %PageLabel
@onready var prev_button: Button = %PrevButton
@onready var next_button: Button = %NextButton
@onready var close_button: Button = %CloseButton

var current_page := 0

func _ready() -> void:
	prev_button.pressed.connect(func(): _go_to(current_page - 1))
	next_button.pressed.connect(func(): _go_to(current_page + 1))
	close_button.pressed.connect(close)
	_go_to(0)

func open() -> void:
	_go_to(0)
	show()

func close() -> void:
	hide()
	closed.emit()

func _input(event: InputEvent) -> void:
	if not visible:
		return
	if event.is_action_pressed("ui_cancel"):
		close()
	elif event.is_action_pressed("ui_left"):
		_go_to(current_page - 1)
	elif event.is_action_pressed("ui_right"):
		_go_to(current_page + 1)
	else:
		return
	get_viewport().set_input_as_handled()

func _go_to(page: int) -> void:
	current_page = clampi(page, 0, PAGES.size() - 1)
	var data: Dictionary = PAGES[current_page]
	title_label.text = data["title"]
	body.text = "\n".join(PackedStringArray(data["lines"]))
	body.scroll_to_line(0)
	page_label.text = "%d/%d" % [current_page + 1, PAGES.size()]
	prev_button.disabled = current_page == 0
	next_button.disabled = current_page == PAGES.size() - 1
