extends classWindow

const SCENE_ELEMENT := preload("res://src/windows/minesweeper/MinesweeperElement.tscn")

const NUMBER_OF_BOMBS := 40
const NUMBER_OF_ROWS := 12
const NUMBER_OF_COLUMNS := 24

onready var _audio_stream_player := $AudioStreamPlayer
onready var _status_label := $VB/VB/VB/Control/StatusLabel
onready var _grid := $VB/VB/PC/Grid

var minigame_stat : classMinigameStat
var id := "minesweeper"

var elements : Array

var game_finished := false

func _ready():
	var _error := $VB/VB/VB/RestartButton.connect("pressed", self, "_on_restart_button_pressed")
	_error = _audio_stream_player.connect("finished", self, "_on_audio_stream_player_finished")

	self.header_text = "Minesweeper"

	minigame_stat = State.get_minigame_stat_by_id(id)
	if not minigame_stat:
		minigame_stat = State.add_and_return_minigame_stat_by_id(id)
		minigame_stat.has_stalemate = false

	_on_restart_button_pressed()

func _exit_tree():
	minigame_stat = null

func player_loss():
	game_finished = true
	_status_label.visible = true
	_status_label.text = LOSE_SETTINGS.message
	_status_label.set("custom_colors/font_color", LOSE_SETTINGS.color)
	_audio_stream_player.stream = LOSE_SETTINGS.audio[randi() % LOSE_SETTINGS.audio.size()]
	_audio_stream_player.play()
	if minigame_stat: minigame_stat.loss += 1

	for element in elements:
		if element.is_da_bomb:
			element.is_hidden = false

func player_win():
	game_finished = true
	_status_label.visible = true
	_status_label.text = WIN_SETTINGS.message
	_status_label.set("custom_colors/font_color", WIN_SETTINGS.color)
	_audio_stream_player.stream = WIN_SETTINGS.audio[randi() % WIN_SETTINGS.audio.size()]
	_audio_stream_player.play()
	if minigame_stat: minigame_stat.win += 1

func _on_audio_stream_player_finished():
	pass

func _on_restart_button_pressed():
	_audio_stream_player.stop()
	_status_label.visible = false
	game_finished = false

	#Remove all the elements!
	for child in _grid.get_children():
		_grid.remove_child(child)
		child.queue_free()

	# Choose the bombs!
	randomize()
	var bomb_indexes := []
	while bomb_indexes.size() < NUMBER_OF_BOMBS:
		var index := randi() % (NUMBER_OF_COLUMNS*NUMBER_OF_ROWS)
		if not bomb_indexes.has(index):
			bomb_indexes.append(index)

	for i in range(0, NUMBER_OF_COLUMNS*NUMBER_OF_ROWS):
		var element := SCENE_ELEMENT.instance()

		element.is_da_bomb = bomb_indexes.has(i)
		element.index = i

		var _error : int = element.connect("pressed", self, "_on_element_pressed", [element])
		_grid.add_child(element)

	elements = _grid.get_children()
	for i in range(0, elements.size()):
		var element : classMinesweeperElement = elements[i]

		for j in get_neighbour_indexes(i):
			if elements[j].is_da_bomb:
				element.neighbors_with_bombs += 1

		element.is_hidden = true

func _on_element_pressed(is_left_pressed : bool, element : classMinesweeperElement):
	if game_finished:
		return

	if is_left_pressed:
		element.is_hidden = false
		if element.is_da_bomb:
			player_loss()
		else:
			reveal_all_neighbours(element.index)
			if is_game_finished():
				player_win()
	elif element.is_hidden:
		element.is_tagged = not element.is_tagged

func reveal_all_neighbours(i : int, already_visited : Array = []):
	already_visited.append(elements[i])

	for j in get_neighbour_indexes(i):
		if elements[j] in already_visited:
			continue
		if elements[j].is_da_bomb:
			continue

		elements[j].is_hidden = false
		if elements[j].neighbors_with_bombs == 0:
			reveal_all_neighbours(j, already_visited)

func get_neighbour_indexes(i : int) -> Array:
	var indexes := [
		i - NUMBER_OF_COLUMNS, # top
		i + NUMBER_OF_COLUMNS, # bottom
	]
	if i % NUMBER_OF_COLUMNS != 0:
		# ITS NOT THE LEFT SIDE!
		indexes.append(i - NUMBER_OF_COLUMNS - 1) # topleft
		indexes.append(i - 1) # left
		indexes.append(i + NUMBER_OF_COLUMNS - 1) # bottomleft
	if (i + 1) % NUMBER_OF_COLUMNS != 0:
		# ITS NOT THE RIGHT SIDE!
		indexes.append(i - NUMBER_OF_COLUMNS + 1) # topright
		indexes.append(i + 1) # right
		indexes.append(i + NUMBER_OF_COLUMNS + 1) # bottomright

	var valid_indexes := []
	for j in indexes:
		if j >= 0 and j < NUMBER_OF_COLUMNS*NUMBER_OF_ROWS:
			valid_indexes.append(j)

	return valid_indexes

func is_game_finished() -> bool:
	for element in elements:
		if not element.is_da_bomb and element.is_hidden:
			return false
	return true

const WIN_SETTINGS := {
	"audio": [
		preload("res://resources/brenda/minesweeper/minesweeper_win.ogg"),
		preload("res://resources/brenda/minesweeper/minesweeper_win2.ogg")
	],
	"message": "You successfully defused the minefield!",
	"color": Color.green
}
const LOSE_SETTINGS := {
	"audio": [
		preload("res://resources/brenda/minesweeper/minesweeper_lose.ogg"),
		preload("res://resources/brenda/minesweeper/minesweeper_lose2.ogg")
	],
	"message": "You exploded!",
	"color": Color.red
}
