extends WindowDialog

const SCENE_TERMINAL_EDIT := preload("res://src/terminal/TerminalEdit.tscn")
const SCENE_TERMINAL_HEADER := preload("res://src/terminal/TerminalHeader.tscn")

const SCENE_UPDATE_LABEL := preload("res://src/terminal/UpdateLabel.tscn")

var terminal_edit : HBoxContainer = null

var block_terminal := false

func _ready():
	var _error := connect("about_to_show", self, "_on_about_to_show")

	reset_terminal()
	add_terminal_edit()

func reset_terminal() -> void:
	terminal_edit = null

	for child in $SC/VB.get_children():
		$SC/VB.remove_child(child)
		child.queue_free()

	var terminal_header := SCENE_TERMINAL_HEADER.instance()
	$SC/VB.add_child(terminal_header)

func _input(event):
	if block_terminal:
		return

	if event.is_action_pressed("confirm") and terminal_edit:
		terminal_edit.editable = false
		parse_terminal_command(terminal_edit.text)
		if not block_terminal:
			add_terminal_edit()

func add_terminal_edit():
	terminal_edit = SCENE_TERMINAL_EDIT.instance()
	$SC/VB.add_child(terminal_edit)

	terminal_edit.give_focus_to_edit()

func parse_terminal_command(text : String) -> void:
	if text.empty():
		return

	var split : Array = text.split(" ", false)
	if split.size() > 0:
		var command_id : String = split.pop_front().strip_edges()
		var command : Dictionary = terminal_commands.get(command_id, terminal_commands.fail)
		var callback : FuncRef = command.callback

		var number_of_parameters : int = command.get("number_of_parameters", 0)
		if number_of_parameters == 0:
			if split.size() != 0:
				var label := Label.new()
				label.text = "Command `{0}` does not allow the use of additional parameters".format([command_id])
				$SC/VB.add_child(label)
			else:
				callback.call_func()
		else:
			if split.size() > number_of_parameters:
				var label := Label.new()
				label.text = "Command `{0}` requires {1} additional parameter(s), supplied console command contained {2}".format([command_id, number_of_parameters, split.size()])
				$SC/VB.add_child(label)
			else:
				callback.call_func(split)

func _on_about_to_show():
	if terminal_edit:
		terminal_edit.give_focus_to_edit()

var terminal_commands := {
	"help": {
		"description": "Show this list",
		"callback": funcref(self, "show_help")
	},
	"clear": {
		"description": "Clear the terminal window",
		"callback": funcref(self, "reset_terminal")
	},
	"fail": {
		"show_on_help": false,
		"callback": funcref(self, "terminal_failure")
	},
	"service_number": {
		"show_on_help": false,
		"callback": funcref(self, "show_service_number")
	},
	"update": {
		"description": "Update program to latest version",
		"callback": funcref(self, "update_program"),
		"number_of_parameters": 1
	},
	"list": {
		"description": "List all installed programs and their versions",
		"callback": funcref(self, "list_programs")
	}
}

func terminal_failure():
	var label = Label.new()
	label.text = \
	"""Command was not recognized or is faulty!
	New here? Type `help` to get a handy list of commands!"""

	$SC/VB.add_child(label)

func update_program(parameters : Array = []):
	var program_id := ""
	if not parameters.empty():
		program_id = parameters[0]

	if program_id.empty():
		var label := Label.new()
		label.text = "Command `update` requires single space separated parameter `program_id`"
		$SC/VB.add_child(label)
	elif not program_id in State.programs.keys():
		var label := Label.new()
		label.text = "Program with `program_id` = {0} is not installed on this device".format([program_id])
		$SC/VB.add_child(label)
	else:
		block_terminal = true
		var update_label = SCENE_UPDATE_LABEL.instance()
		update_label.connect("update_completed", self, "_on_update_completed", [], CONNECT_ONESHOT)

		update_label.program_id = program_id

		$SC/VB.add_child(update_label)

func _on_update_completed(update_text : String):
	var label := Label.new()
	label.text = update_text
	$SC/VB.add_child(label)

	block_terminal = false
	add_terminal_edit()

func show_service_number():
	var label = Label.new()
	# Will have to be randomly generated at start by Flow.gd!
	label.text = "A5U8CC"

	$SC/VB.add_child(label)

func show_help():
	for key in terminal_commands.keys():
		if terminal_commands[key].get("show_on_help", true):
			var label := Label.new()
			label.text = key + " - "
			label.text += terminal_commands[key].get("description", "no description available")

			$SC/VB.add_child(label)

func list_programs():
	for program in State.programs.values():
		if program.show_on_list:
			var label := Label.new()
			label.text = "`{0}`\nversion: {1}\ndescription: {2}\n".format([program.id, program.version, program.description])

			$SC/VB.add_child(label)
