extends Control

func _ready():
	var _error := $PC/HB/VB/LeftTab/LoginContainer.connect("login_succeeded", self, "_on_login_succeeded")
	_error = $PC/HB/VB/LeftTab/DriversList.connect("settings_button_pressed", self, "_on_settings_button_pressed")

	_error = $PC/HB/RightTab/DriverSettings.connect("driver_updated", $PC/HB/VB/LeftTab/DriversList, "_on_driver_updated")

func _input(event : InputEvent):
	if event.is_action_pressed("restart"):
		Flow.change_scene_to("startup")

func _on_login_succeeded():
	$PC/HB/VB/LeftTab.current_tab = 1

func _on_settings_button_pressed(program_id : String):
	$PC/HB/RightTab.current_tab = 1

	var program : classProgram = State.programs.get(program_id, null)

	$PC/HB/RightTab/DriverSettings.program = program
	$PC/HB/RightTab/DriverSettings.update_program()
