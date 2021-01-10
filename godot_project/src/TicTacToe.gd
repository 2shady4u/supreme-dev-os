extends WindowDialog

const SCENE_ELEMENT := preload("res://src/tic_tac_toe/TicTacToeElement.tscn")

var is_player_turn := true
var is_ai_turn := false

func _ready():
	var _error := $HB/VB/RestartButton.connect("pressed", self, "_on_restart_button_pressed")
	_error = $AudioStreamPlayer.connect("finished", self, "_on_audio_stream_player_finished")

	_on_restart_button_pressed()

func _on_restart_button_pressed():
	$AudioStreamPlayer.stop()
	$HB/VB/Control/StatusLabel.visible = false
	is_player_turn = true
	is_ai_turn = false

	#Remove all the elements!
	for child in $HB/PC/GridContainer.get_children():
		$HB/PC/GridContainer.remove_child(child)
		child.queue_free()

	for i in range(0, 9):
		var element := SCENE_ELEMENT.instance()

		var _error : int = element.connect("pressed", self, "_on_element_pressed", [element])
		element.magic_number = MAGIC_NUMBERS[i]

		$HB/PC/GridContainer.add_child(element)

func _on_element_pressed(element : TextureRect):
	if is_player_turn and element.holder == classTicTacToeElement.HOLDER.NONE:
		element.holder = classTicTacToeElement.HOLDER.PLAYER

		is_player_turn = false
		# Was this the winning move???
		if check_win_condition(classTicTacToeElement.HOLDER.PLAYER):
			is_ai_turn = false

			$HB/VB/Control/StatusLabel.visible = true
			$HB/VB/Control/StatusLabel.text = WIN_SETTINGS.message
			$HB/VB/Control/StatusLabel.set("custom_colors/font_color", WIN_SETTINGS.color)
			$AudioStreamPlayer.stream = WIN_SETTINGS.audio
			$AudioStreamPlayer.play()
		elif check_stalemate():
			is_ai_turn = false

			end_with_stalemate()
		else:
			is_ai_turn = true

			$AudioStreamPlayer.stream = COMMENTS[randi() % COMMENTS.size()]
			$AudioStreamPlayer.play()

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

		$HB/VB/Control/StatusLabel.visible = true
		$HB/VB/Control/StatusLabel.text = LOSE_SETTINGS.message
		$HB/VB/Control/StatusLabel.set("custom_colors/font_color", LOSE_SETTINGS.color)
		$AudioStreamPlayer.stream = LOSE_SETTINGS.audio
		$AudioStreamPlayer.play()
	elif check_stalemate():
		is_player_turn = false

		end_with_stalemate()
	else:
		is_player_turn = true

func end_with_stalemate():
	$HB/VB/Control/StatusLabel.visible = true
	$HB/VB/Control/StatusLabel.text = STALEMATE_SETTINGS.message
	$HB/VB/Control/StatusLabel.set("custom_colors/font_color", STALEMATE_SETTINGS.color)
	$AudioStreamPlayer.stream = STALEMATE_SETTINGS.audio
	$AudioStreamPlayer.play()

func check_stalemate() -> bool:
	if get_empty_squares().empty():
		return true
	else:
		return false

func check_win_condition(holder : int) -> bool:
	for first_child in $HB/PC/GridContainer.get_children():
		for second_child in $HB/PC/GridContainer.get_children():
				for third_child in $HB/PC/GridContainer.get_children():
					if (first_child != second_child) and (first_child != third_child) and (second_child != third_child):
						if first_child.holder == holder and second_child.holder == holder and third_child.holder == holder:
							if (first_child.magic_number + second_child.magic_number + third_child.magic_number == 15):
								return true;

	return false

func get_empty_squares() -> Array:
	var elements := []
	for child in $HB/PC/GridContainer.get_children():
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
