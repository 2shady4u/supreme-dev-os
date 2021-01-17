extends classWindow

const PERMISSION_FAILURE := "`Godot.exe` does not have proper permissions to access filesystem\nIf this access violation was deliberate, launch program with root privileges."

func _ready():
	var _error := $VB/Control/TabContainer/Projects/HB/VB/NewButton.connect("pressed", self, "_on_button_pressed")
	_error = $VB/Control/TabContainer/Projects/HB/VB/ImportButton.connect("pressed", self, "_on_button_pressed")

	self.header_text = "Godot Engine - Project Manager"

	var program : classProgram = State.get_program_by_id("godot")
	if program:
		$VB/Control/VB/MC/VersionLabel.text = "v{0}-official".format([program.version])

func _on_button_pressed():
	var user : classUser = State.get_user_by_viewport(get_viewport())
	if user.is_root:
		Flow.change_scene_to("godot_editor", get_viewport())
	else:
		Flow.failure_message = PERMISSION_FAILURE
		Flow.change_scene_to("failure", get_viewport())
