extends PanelContainer

signal pressed

var program : classProgram setget set_program, get_program
func set_program(value : classProgram) -> void:
	_program = weakref(value)
func get_program() -> classProgram:
	return _program.get_ref()

var _program := WeakRef.new()

func _ready():
	var _error := $HB/SettingsButton.connect("pressed", self, "_on_settings_button_pressed")
	update_program()

func _on_settings_button_pressed():
	emit_signal("pressed")

func update_program():
	var local_program := self.program
	if local_program:
		$HB/VB/NameLabel.text = local_program.name
		$HB/VB/DescriptionLabel.text = local_program.description
		$HB/VB/VersionLabel.text = "Version: {0}".format([local_program.version])
