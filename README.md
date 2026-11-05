# Bookworm

**Bookworm** é um *roguelite deckbuilder* de combate em turnos, inspirado em *Slay the Spire*. Você controla **Vanessa**, uma bibliotecária e aprendiz de feiticeira, que atravessa um mapa gerado proceduralmente enfrentando os **Leitores Vorazes**, criaturas nascidas do Grimório do Conhecimento Proibido. A cada combate você ganha ouro, cartas e artefatos, e monta um baralho diferente a cada tentativa.

O jogo também tem um componente educativo (tema **Números e Operações**): as intenções dos inimigos aparecem como operações (por exemplo, `2×4` = dois golpes de 4 de dano), e o jogador precisa calcular o dano do turno para decidir sua jogada.

> **Status:** protótipo jogável, em desenvolvimento. O jogo ainda **não possui tutorial interno**; este README cumpre esse papel.

---

## Sumário

1. [Requisitos](#1-requisitos)
2. [Como baixar o projeto](#2-como-baixar-o-projeto)
3. [Instalação e configuração do ambiente](#3-instalação-e-configuração-do-ambiente)
4. [Como executar o jogo](#4-como-executar-o-jogo)
5. [Como jogar](#5-como-jogar)
6. [Objetivo, regras e condições de vitória/derrota](#6-objetivo-regras-e-condições-de-vitóriaderrota)
7. [Limitações conhecidas e funcionalidades não implementadas](#7-limitações-conhecidas-e-funcionalidades-não-implementadas)
8. [Estrutura do projeto](#8-estrutura-do-projeto)
9. [Créditos](#9-créditos)

---

## 1. Requisitos

| Item | Requisito |
|---|---|
| **Engine** | [Godot Engine](https://godotengine.org/download/archive/) **4.6** (versão padrão, **não** é necessária a versão .NET). O projeto foi desenvolvido na 4.6.1 stable. |
| **Linguagem** | GDScript (já incluída na Godot, nada a instalar). |
| **Sistema operacional** | Windows 10/11 de 64 bits (é o único preset de exportação do projeto). O editor da Godot também roda em Linux e macOS, então é possível abrir e executar o projeto por ele nesses sistemas. |
| **Placa de vídeo** | Compatível com OpenGL 3.3 (o projeto usa o renderizador *GL Compatibility*), portanto roda em máquinas modestas. |
| **Periféricos** | **Mouse** (o jogo é jogado inteiramente com o mouse, mais a tecla `Esc`). |
| **Git** | Opcional, apenas para clonar o repositório. |
| **Dependências externas** | Nenhuma. O projeto não usa plugins, addons nem gerenciadores de pacotes. |

A janela do jogo abre em **1280×720** (resolução interna de pixel art de 256×144, ampliada).

---

## 2. Como baixar o projeto

**Opção A: clonar com Git** (recomendado)

```bash
git clone https://github.com/Klebynhow/PAC-jogo.git
cd PAC-jogo
```

**Opção B: baixar o ZIP**

1. Acesse https://github.com/Klebynhow/PAC-jogo
2. Clique em **Code → Download ZIP**.
3. Extraia o arquivo (a pasta extraída se chamará `PAC-jogo-main`).

---

## 3. Instalação e configuração do ambiente

Não há instalador nem dependências para configurar. Basta ter a Godot:

1. Baixe a **Godot 4.6** (versão *Standard*) em https://godotengine.org/download/archive/ e escolha a versão para o seu sistema.
2. Extraia o arquivo baixado. A Godot é **portátil**: o executável (por exemplo, `Godot_v4.6.1-stable_win64.exe`) já abre direto, sem instalação.

> O nome exato do executável varia conforme a versão e o sistema operacional baixados.

---

## 4. Como executar o jogo

### Opção A: pelo editor da Godot (mais simples)

1. Abra a Godot. No **Gerenciador de Projetos**, clique em **Importar**.
2. Selecione o arquivo **`project.godot`** que está na raiz da pasta do projeto e confirme em **Importar e Editar**.
3. Na **primeira abertura**, a Godot importa todos os recursos (imagens, sons etc.). Isso pode levar alguns instantes, pois a pasta `.godot/` não é versionada.
4. Com o projeto aberto, pressione **`F5`** (ou o botão ▶ **Executar projeto**, no canto superior direito).
   A cena principal já está configurada: o jogo abre no **menu principal** (`scenes/ui/main_menu.tscn`).

### Opção B: pela linha de comando

Com o executável da Godot disponível (ajuste o nome ao seu), dentro da pasta do projeto:

```bash
# executa o jogo direto, sem abrir o editor
godot --path .

# abre o editor neste projeto
godot --path . --editor
```

No Windows (PowerShell), por exemplo:

```powershell
.\Godot_v4.6.1-stable_win64.exe --path .
```

### Opção C: gerar um executável (Windows)

1. Instale os **templates de exportação** da mesma versão da Godot: **Editor → Gerenciar Templates de Exportação → Baixar e Instalar**.
2. Abra **Projeto → Exportar…** e selecione o preset **Windows Desktop**.
3. Clique em **Exportar Projeto…** e escolha o destino. O caminho padrão do preset é `../Project-Bookworm.exe` (uma pasta acima do projeto).
4. Execute o `.exe` gerado. **Importante:** o preset está com `embed_pck` desativado, então a exportação cria também um arquivo **`.pck`**, que deve ficar **na mesma pasta** do `.exe`.

> O repositório não inclui executáveis prontos. Se houver builds publicadas, elas estarão na aba **Releases** do GitHub.

### Onde ficam os dados salvos

O jogo salva a tentativa em `user://savegame.tres`, que corresponde a:

| Sistema | Caminho |
|---|---|
| Windows | `%APPDATA%\Godot\app_userdata\Bookworm\savegame.tres` |
| Linux | `~/.local/share/godot/app_userdata/Bookworm/savegame.tres` |
| macOS | `~/Library/Application Support/Godot/app_userdata/Bookworm/savegame.tres` |

Para "zerar" o progresso salvo, basta apagar esse arquivo.

---

## 5. Como jogar

### 5.1 Iniciando uma partida

1. No **menu principal** há três opções:
   - **Continuar:** retoma a última tentativa salva (fica desabilitado se não houver save).
   - **Nova Tentativa:** começa uma tentativa nova.
   - **Sair :(**: fecha o jogo.
2. Em **Nova Tentativa**, abre-se a seleção de personagem (atualmente só **Vanessa**). Clique em **Avante!** para começar.
3. Você cai no **mapa do andar**. Clique em uma das salas disponíveis do primeiro andar para entrar.

### 5.2 Controles

| Ação | Controle |
|---|---|
| Clicar em botões, salas do mapa, recompensas e itens da loja | **Botão esquerdo do mouse** |
| Jogar uma carta **sem alvo** (Defesa, poderes, cartas que afetam todos os inimigos) | Clique na carta e **arraste** para cima da mão (área de jogo); **solte** para jogar |
| Jogar uma carta **com alvo** (ataque a um inimigo) | Clique na carta e mova o mouse: a carta vai para o centro e aparece uma **seta de mira**. Passe sobre o inimigo desejado e **clique** (ou solte) para jogar |
| **Cancelar** a jogada de uma carta | **Botão direito do mouse** (ou leve o mouse para a parte de baixo da tela) |
| Encerrar o turno | Botão **Fim** (canto inferior direito) |
| Rolar o mapa | **Roda do mouse** |
| Pausar / retomar | **`Esc`** |
| Ver a descrição de uma carta | Passe o mouse sobre ela |
| Ver a descrição de um status (Exposto, Força…) | Clique no ícone do status, abaixo da barra de vida |
| Ver a descrição de um artefato | Clique no ícone do artefato, na barra superior |
| Ver a pilha de compra / de descarte | Botões das pilhas, no canto inferior esquerdo / direito da tela de combate |
| Ver o baralho completo | Botão de baralho, na barra superior |
| Fechar janelas de cartas e descrições | Botão **Fechar** ou `Esc` |

**Menu de pausa (`Esc`):** **Voltar** retoma o jogo; **Menu Principal** volta ao menu. O progresso é salvo automaticamente ao entrar em cada sala, então **Continuar** retoma do último ponto salvo. Se você sair no meio de um combate, ao continuar essa sala é reiniciada.

### 5.3 Entendendo a tela de combate

- O **ouro** fica no canto superior esquerdo. Sua **vida** (coração) aparece abaixo da Vanessa, com o **escudo** junto dela.
- **Mana** (ex.: `3/3`) fica no canto inferior esquerdo: cada carta gasta mana, e ela volta ao máximo a cada turno.
- A **mão** de cartas fica na parte de baixo. O número no canto da carta é o seu **custo de mana**.
- Acima de cada inimigo aparece sua **intenção**: o ícone mostra o tipo da ação (ataque, defesa, buff, debuff) e o número mostra o valor. Um valor como **`2×4`** significa **2 golpes de 4 de dano** (8 no total). O número já considera status como **Exposto** e **Força**.
- Abaixo da vida de cada personagem ficam os **status** ativos.

### 5.4 Fluxo de um turno

1. **Seu turno:** o escudo é zerado, a mana é restaurada, artefatos de início de turno ativam e você compra **5 cartas**.
2. Jogue as cartas que quiser, enquanto tiver mana.
3. Clique em **Fim** para encerrar o turno. As cartas que sobraram vão para o descarte (cartas com **Exaurir** saem do baralho até o fim do combate).
4. **Turno dos inimigos:** cada um executa a intenção que mostrava. Depois eles anunciam as próximas ações e o turno volta para você.

Quando a pilha de compra acaba, o descarte é embaralhado e vira a nova pilha de compra.

### 5.5 Tipos de sala do mapa

| Sala | O que acontece |
|---|---|
| **Combate** | Luta contra um grupo de inimigos. Ao vencer, você recebe ouro e escolhe **1 entre 3 cartas** (ou pula). |
| **Loja** | Compre cartas e artefatos com ouro. |
| **Fogueira** | Clique em **Descansar** para recuperar **30% da vida máxima**. |
| **Tesouro** | Abra o baú para receber um **artefato aleatório**. |
| **Chefe** | Último andar (15). Vencê-lo conclui a tentativa. |

O mapa é gerado a cada tentativa. Você só pode seguir por **caminhos ligados** à sala em que está.

---

## 6. Objetivo, regras e condições de vitória/derrota

### Objetivo

Guiar Vanessa pelos **15 andares** do mapa, derrotar o **chefe** do último andar e, pelo caminho, fortalecer o baralho com cartas, ouro e artefatos.

### Regras básicas

- Vanessa começa com **50 de vida**, **3 de mana por turno** e compra **5 cartas por turno**.
- O baralho inicial tem 12 cartas: 4 Ataques (6 de dano), 4 Defesas (5 de escudo), 2 Cortes (4 de dano em todos os inimigos), 1 Pancada e 1 Fortalecer.
- **Escudo** absorve dano antes da vida e é zerado no início do turno de quem o possui.
- **Status importantes:**
  - **Exposto:** quem está Exposto sofre **50% mais dano**.
  - **Força:** aumenta o dano dos ataques.
- **Artefatos** são itens passivos que valem durante toda a tentativa (você começa com a **Poção de Cura**, que cura 3 de vida ao fim de cada combate).
- Alguns inimigos colocam **cartas de debuff** no seu baralho durante o combate (por exemplo, *Página Rasgada* ou *Tinta Derramada*). Elas atrapalham a mão e somem quando o combate termina.
- Você começa a tentativa com **70 de ouro**.

### Progressão

Vencer combates rende **ouro** e **cartas**; a loja vende cartas e artefatos; o tesouro dá artefatos; a fogueira recupera vida. Os combates ficam mais difíceis conforme você avança nos andares.

### Vitória

Derrotar o **chefe do andar 15**. Aparece a **tela de vitória**, com o botão **Voltar ao menu**. O save da tentativa é apagado.

### Derrota

Ter a vida reduzida a **zero** em qualquer combate. Aparece a tela **"Fim de Jogo..."**, o botão volta ao **menu principal** e o save da tentativa é apagado (não há como continuar a tentativa perdida).

---

## 7. Limitações conhecidas e funcionalidades não implementadas

Esta é uma versão de **protótipo**. Itens conhecidos:

- **Sem tutorial interno:** as regras estão apenas neste README.
- **Um personagem jogável** (Vanessa) e **um chefe** (Grande Slime).
- **Menu principal provisório**, que ainda será repaginado. Não há música de menu.
- **Áudio limitado:** uma música de combate e efeitos sonoros básicos.
- **Sem tela de opções:** não há ajuste de volume, resolução ou tela cheia dentro do jogo.
- **Somente mouse:** não há suporte a teclado (além de `Esc`) nem a controle.
- **Exportação configurada apenas para Windows.** Não há preset de exportação para Web, Linux ou macOS, embora a plataforma planejada inclua Web.
- **Arte provisória:** os sprites dos inimigos mais novos (Traça, Mancha de Tinta, Carimbador, Escriba Fantasma e Tomo Mímico) são provisórios.
- **Balanceamento em andamento:** dano, custos, preços e dificuldade ainda estão sendo ajustados e podem mudar.
- **Idioma:** textos apenas em português do Brasil.
- **Funcionalidades previstas, ainda não implementadas:** mais personagens e chefes, novos status (como veneno), mais cartas e batalhas, novas operações no tema educativo (divisão, frações) e arte e animações definitivas.
- Por ser um protótipo, **podem ocorrer bugs**. Se encontrar algum, abra uma *issue* no repositório descrevendo o que aconteceu.

---

## 8. Estrutura do projeto

```text
.
├── project.godot        # configuração do projeto (cena principal, entradas, resolução)
├── GDD                  # pasta com arquivo .pdf do GDD atual
├── main_menu.gd         # script do menu principal
├── art/                 # sprites, ícones, sons e música
├── battles/             # batalhas (cena + peso + ouro) e o pool por tier
├── characters/vanessa/  # stats, baralho inicial e cartas da Vanessa
├── common_cards/        # cartas de debuff (Página Rasgada etc.)
├── custom_resources/    # recursos: Card, Relic, Status, EnemyStats, BattleStats...
├── effects/             # efeitos reutilizáveis (dano, escudo, status)
├── enemies/             # inimigos: stats e IA de cada um
├── relics/              # artefatos
├── statuses/            # status (Exposto, Força, Forma de Guerreiro)
├── global/              # autoloads (Events, RNG, MusicPlayer, SFXPlayer, Shaker)
└── scenes/              # cenas: Run, battle, map, shop, campfire, treasure, ui...
```

O documento de design (GDD) complementa este guia, com a visão completa de mecânicas, conteúdo e roadmap.

---

## 9. Créditos

- **Autor:** Vinicius Batista Condes, Engenharia de Software.
- **Inspirações:** *Slay the Spire* (Mega Crit), *Phoenotopia Awakening* (Cape Cosmic) e *Avonbourough* (D&D), *Deadlock* (Valve).
- **Música:** criada no BandLab, com assistência de IA.
- **Efeitos sonoros:** de origem open source, sem necessidade de licença ou menção.
- **Engine:** [Godot Engine](https://godotengine.org/).

> Este repositório ainda não possui um arquivo de licença.
