extends ScrollContainer

var program : classProgram

signal driver_updated

func _ready():
	var _error := $MC/VB/UpdateVB/UpdateButton.connect("pressed", self, "_on_update_button_pressed")
	update_program()

func _exit_tree():
	program = null

func update_program():
	if program:
		$MC/VB/NameLabel.text = program.name
		$MC/VB/SloganLabel.text = program.slogan

		$MC/VB/IconRect.texture = program.icon_texture

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

		var update_dict := LATEST_VERSION_DICT
		if Flow.mainframe.has(program.id):
			var mainframe_version = Flow.mainframe[program.id]

			if program.version < mainframe_version:
				# NEEDS UPDATE!
				update_dict = NEEDS_UPDATE_DICT
			# YOU HAVE LATEST VERSION!

		$MC/VB/UpdateVB/Label.text = update_dict.message
		$MC/VB/UpdateVB/Label.set("custom_colors/font_color", update_dict.color)

		$MC/VB/UpdateVB/UpdateButton.disabled = update_dict.disabled

func _on_update_button_pressed():
	if program:
		if Flow.mainframe.has(program.id):
			var mainframe_version = Flow.mainframe[program.id]

			if program.version < mainframe_version:
				program.version = mainframe_version
				emit_signal("driver_updated")

		update_program()

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
