extends ScrollContainer

onready var _update_button := $MC/VB/UpdateVB/UpdateButton
onready var _update_label := $MC/VB/UpdateVB/Label

onready var _install_button := $MC/VB/InstallVB/InstallButton
onready var _uninstall_button := $MC/VB/InstallVB/UninstallButton
onready var _install_label := $MC/VB/InstallVB/Label

var program : classProgram

signal driver_updated

func _ready():
	var _error := _update_button.connect("pressed", self, "_on_update_button_pressed")
	_error = _install_button.connect("pressed", self, "_on_install_button_pressed")
	_error = _uninstall_button.connect("pressed", self, "_on_uninstall_button_pressed")

	update_program()

func _exit_tree():
	program = null

func update_program():
	if program:
		$MC/VB/NameLabel.text = program.name
		$MC/VB/SloganLabel.text = program.slogan

		$MC/VB/IconRect.texture = program.icon_texture

		# HIDDEN COMMANDS
		for child in $MC/VB/CommandVB.get_children():
			$MC/VB/CommandVB.remove_child(child)
			child.queue_free()

		if program.hidden_commands.empty():
			var label := Label.new()
			label.text = "No custom commands are registered"

			$MC/VB/CommandVB.add_child(label)
		else:
			for hidden_command in program.hidden_commands:
				var id_label := Label.new()
				id_label.text = hidden_command.get("id", "MISSING ID")

				for input in hidden_command.get("inputs", []):
					id_label.text += " `{0}`".format([input])
				$MC/VB/CommandVB.add_child(id_label)

				var description_label := Label.new()
				description_label.text = hidden_command.get("description", "MISSING DESCRIPTION")
				description_label.autowrap = true
				description_label.align = Label.ALIGN_CENTER
				$MC/VB/CommandVB.add_child(description_label)

		# INSTALL/UNINSTALL!
		update_install_vbox()
		# automatically also updates the update vbox!

func _on_update_button_pressed():
	if program:
		if Flow.mainframe.has(program.id):
			var mainframe_version = Flow.mainframe[program.id]

			if program.version < mainframe_version:
				program.version = mainframe_version
				emit_signal("driver_updated")

		update_program()

func _on_install_button_pressed():
	program.is_installed = true
	update_install_vbox()

func _on_uninstall_button_pressed():
	program.is_installed = false
	update_install_vbox()

func update_update_vbox():
	var update_dict := LATEST_VERSION_DICT

	if Flow.mainframe.has(program.id):
		var mainframe_version = Flow.mainframe[program.id]

		if program.version < mainframe_version:
			# NEEDS UPDATE!
			update_dict = NEEDS_UPDATE_DICT
		# YOU HAVE LATEST VERSION!

	if program.is_installed:
		_update_label.text = update_dict.message
		_update_label.set("custom_colors/font_color", update_dict.color)

		_update_button.disabled = update_dict.disabled
	else:
		_update_label.text = "NO INSTALLATION FOUND"
		_update_label.set("custom_colors/font_color", Color.red)

		_update_button.disabled = true

func update_install_vbox():
	var install_dict := {}

	if program.is_installed:
		install_dict = INSTALLED_DICT
		if program.can_be_uninstalled:
			_uninstall_button.disabled = false
		else:
			_uninstall_button.disabled = true
		_install_button.disabled = true
	else:
		install_dict = NOT_INSTALLED_DICT
		_uninstall_button.disabled = true
		_install_button.disabled = false

	_install_label.text = install_dict.message
	_install_label.set("custom_colors/font_color", install_dict.color)

	update_update_vbox()

const LATEST_VERSION_DICT := {
	"message": "You are using the latest version",
	"color": Color.green,
	"disabled": true
}
const NEEDS_UPDATE_DICT := {
	"message": "A new version of this driver is available!",
	"color": Color.red,
	"disabled": false
}
const INSTALLED_DICT := {
	"message": "This driver is correctly installed",
	"color": Color.white
}
const NOT_INSTALLED_DICT := {
	"message": "This driver is not installed on your device!",
	"color": Color.red
}
