extends WindowDialog

const PERMISSION_FAILURE := "`Godot.exe` does not have proper permissions to access filesystem\nIf this access violation was deliberate, launch program with root privileges."

func _ready():
	var _error := $TabContainer/Projects/HB/VB/NewButton.connect("pressed", self, "_on_button_pressed")
	_error = $TabContainer/Projects/HB/VB/ImportButton.connect("pressed", self, "_on_button_pressed")

	var program : classProgram = State.get_program_by_id("godot")
	if program:
		$VB/VersionLabel.text = "v{0}-official".format([program.version])

func _on_button_pressed():
	Flow.failure_message = PERMISSION_FAILURE
	Flow.change_scene_to("failure")
