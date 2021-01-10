extends Control

const SCENE_PROGRAM_CONTROL := preload("res://src/programs/ProgramControl.tscn")

const MAX_ROWS := 5

var row_index := 0
var column_index := 0

func _ready():
	#$Windows/Terminal.popup_centered()
	#$Windows/Olympus.popup_centered()
	#$Windows/TicTacToe.popup_centered()

	$WelcomePlayer.play()

	for child in $Programs.get_children():
		$Programs.remove_child(child)
		child.queue_free()

	for program in State.programs.values():
		if program.show_on_desktop:
			var program_control := SCENE_PROGRAM_CONTROL.instance()

			var _error : int = program_control.connect("launch_program", self, "_on_program_launched", [program.id])

			if program.id == "godot":
				program_control.rect_position = Vector2(464, 240)
			else:
				program_control.rect_position.x = 24
				program_control.rect_position.y = 24 + (row_index)*(64+48)
				row_index += 1

			program_control.program = program
			$Programs.add_child(program_control)

func _on_program_launched(program_id : String):
	match program_id:
		"terminal":
			$Windows/Terminal.popup_centered()
		"tic_tac_toe":
			$Windows/TicTacToe.popup_centered()
		"olympus":
			$Windows/Olympus.popup_centered()
		"godot":
			$Windows/Godot.popup_centered()
