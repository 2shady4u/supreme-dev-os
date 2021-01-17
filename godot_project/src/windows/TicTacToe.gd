extends classWindow

const SCENE_ELEMENT := preload("res://src/windows/tic_tac_toe/TicTacToeElement.tscn")

onready var _audio_stream_player := $AudioStreamPlayer
onready var _status_label := $VB/HB/VB/Control/StatusLabel
onready var _grid := $VB/HB/PC/Grid

var is_player_turn := true
var is_ai_turn := false

var minigame_stat : classMinigameStat
var id := "tic_tac_toe"

func _ready():
	var _error := $VB/HB/VB/RestartButton.connect("pressed", self, "_on_restart_button_pressed")
	_error = _audio_stream_player.connect("finished", self, "_on_audio_stream_player_finished")

	self.header_text = "Tic-Tac-Toe"

	minigame_stat = State.get_minigame_stat_by_id(id)
	if not minigame_stat:
		minigame_stat = State.add_and_return_minigame_stat_by_id(id)

	_on_restart_button_pressed()

func _exit_tree():
	minigame_stat = null

func _on_restart_button_pressed():
	_audio_stream_player.stop()
	_status_label.visible = false
	is_player_turn = true
	is_ai_turn = false

	#Remove all the elements!
	for child in _grid.get_children():
		_grid.remove_child(child)
		child.queue_free()

	for i in range(0, 9):
		var element := SCENE_ELEMENT.instance()

		var _error : int = element.connect("pressed", self, "_on_element_pressed", [element])
		element.magic_number = MAGIC_NUMBERS[i]

		_grid.add_child(element)

func _on_element_pressed(element : TextureRect):
	if is_player_turn and element.holder == classTicTacToeElement.HOLDER.NONE:
		element.holder = classTicTacToeElement.HOLDER.PLAYER

		is_player_turn = false
		# Was this the winning move???
		if check_win_condition(classTicTacToeElement.HOLDER.PLAYER):
			is_ai_turn = false

			_status_label.visible = true
			_status_label.text = WIN_SETTINGS.message
			_status_label.set("custom_colors/font_color", WIN_SETTINGS.color)
			_audio_stream_player.stream = WIN_SETTINGS.audio
			_audio_stream_player.play()

			if minigame_stat: minigame_stat.win += 1
		elif check_stalemate():
			is_ai_turn = false

			end_with_stalemate()
		else:
			is_ai_turn = true

			_audio_stream_player.stream = COMMENTS[randi() % COMMENTS.size()]
			_audio_stream_player.play()

func _on_audio_stream_player_finished():
	if is_ai_turn:
		execute_ai_move()

func execute_ai_move():
	var elements = get_empty_squares()
	var index : int = randi() % elements.size()
	elements[index].holder = classTicTacToeElement.HOLDER.AI

	is_ai_turn = false
	# Was this the winning move???
	if check_win_condition(classTicTacToeElement.HOLDER.AI):
		is_player_turn = false

		_status_label.visible = true
		_status_label.text = LOSE_SETTINGS.message
		_status_label.set("custom_colors/font_color", LOSE_SETTINGS.color)
		_audio_stream_player.stream = LOSE_SETTINGS.audio
		_audio_stream_player.play()

		if minigame_stat: minigame_stat.loss += 1
	elif check_stalemate():
		is_player_turn = false

		end_with_stalemate()
	else:
		is_player_turn = true

func end_with_stalemate():
	_status_label.visible = true
	_status_label.text = STALEMATE_SETTINGS.message
	_status_label.set("custom_colors/font_color", STALEMATE_SETTINGS.color)
	_audio_stream_player.stream = STALEMATE_SETTINGS.audio
	_audio_stream_player.play()

	if minigame_stat: minigame_stat.stalemate += 1
func check_stalemate() -> bool:
	if get_empty_squares().empty():
		return true
	else:
		return false

func check_win_condition(holder : int) -> bool:
	for first_child in _grid.get_children():
		for second_child in _grid.get_children():
				for third_child in _grid.get_children():
					if (first_child != second_child) and (first_child != third_child) and (second_child != third_child):
						if first_child.holder == holder and second_child.holder == holder and third_child.holder == holder:
							if (first_child.magic_number + second_child.magic_number + third_child.magic_number == 15):
								return true;

	return false

func get_empty_squares() -> Array:
	var elements := []
	for child in _grid.get_children():
		if child.holder == classTicTacToeElement.HOLDER.NONE:
			elements.append(child)
	return elements

const MAGIC_NUMBERS := [4, 9, 2, 3, 5, 7, 8, 1, 6]

const COMMENTS := [
	preload("res://resources/brenda/tic_tac_toe/tic_tac_toe_comment1.ogg"),
	preload("res://resources/brenda/tic_tac_toe/tic_tac_toe_comment2.ogg"),
	preload("res://resources/brenda/tic_tac_toe/tic_tac_toe_comment3.ogg")
]

const WIN_SETTINGS := {
	"audio": preload("res://resources/brenda/tic_tac_toe/tic_tac_toe_win.ogg"),
	"message": "You win!",
	"color": Color.green
}
const LOSE_SETTINGS := {
	"audio":  preload("res://resources/brenda/tic_tac_toe/tic_tac_toe_lose.ogg"),
	"message": "You lose!",
	"color": Color.red
}
const STALEMATE_SETTINGS := {
	"audio": preload("res://resources/brenda/tic_tac_toe/tic_tac_toe_stalemate.ogg"),
	"message": "It's a stalemate!",
	"color": Color.orange
}
