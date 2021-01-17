extends classWindow

const SCENE_TERMINAL_EDIT := preload("res://src/windows/terminal/TerminalEdit.tscn")
const SCENE_TERMINAL_HEADER := preload("res://src/windows/terminal/TerminalHeader.tscn")

const SCENE_UPDATE_LABEL := preload("res://src/windows/terminal/UpdateLabel.tscn")
const SCENE_INSTALL_LABEL := preload("res://src/windows/terminal/InstallLabel.tscn")

const SCENE_FETCH_MAIL_LABEL := preload("res://src/windows/terminal/FetchMailLabel.tscn")

onready var _audio_stream_player := $AudioStreamPlayer
onready var _vbox := $VB/SC/VB

var terminal_edit : HBoxContainer = null
var block_terminal := false

signal programs_updated

func _ready():
	var _error := _audio_stream_player.connect("finished", self, "_on_audio_stream_finished")

	self.header_text = "Terminal (v1.56a-beta)"

	reset_terminal()
	add_terminal_edit()

func reset_terminal() -> void:
	terminal_edit = null

	for child in _vbox.get_children():
		_vbox.remove_child(child)
		child.queue_free()

	var terminal_header := SCENE_TERMINAL_HEADER.instance()
	_vbox.add_child(terminal_header)

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
	_vbox.add_child(terminal_edit)

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
				label.autowrap = true
				_vbox.add_child(label)
			else:
				callback.call_func()
		else:
			if split.size() > number_of_parameters:
				var label := Label.new()
				label.text = "Command `{0}` requires {1} additional parameter(s), supplied console command contained {2}".format([command_id, number_of_parameters, split.size()])
				label.autowrap = true
				_vbox.add_child(label)
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
	"change_volume": {
		"show_on_help": false,
		"callback": funcref(self, "change_volume"),
		"number_of_parameters": 1
	},
	"change_pitch": {
		"show_on_help": false,
		"callback": funcref(self, "change_pitch"),
		"number_of_parameters": 1
	},
	"list": {
		"description": "List all installed programs and their versions",
		"callback": funcref(self, "list_programs")
	},
	"update": {
		"description": "Update program to latest version",
		"callback": funcref(self, "update_program"),
		"number_of_parameters": 1
	},
	"install": {
		"description": "Install a certified program from the Pantheon Mainframe",
		"callback": funcref(self, "install_program"),
		"number_of_parameters": 1
	},
	"compliment": {
		"description": "Receive a well-deserved compliment from BrendAI",
		"callback": funcref(self, "play_compliment")
	},
	"exit": {
		"description": "Exit this command terminal",
		"callback": funcref(self, "exit_terminal")
	},
	"minigame_stats": {
		"show_on_help": false,
		"callback": funcref(self, "list_minigame_stats")
	},
	"fetch_mail": {
		"show_on_help": false,
		"callback": funcref(self, "fetch_mail")
	},
}

func exit_terminal():
	hide()

func terminal_failure():
	var label := Label.new()
	label.text = \
	"""Command was not recognized or is faulty!
	New here? Type `help` to get a handy list of commands!"""
	label.autowrap = true

	_vbox.add_child(label)

func change_volume(parameters : Array = []):
	var volume_linear := NAN
	if not parameters.empty():
		volume_linear = clamp(float(parameters[0]), 0.0, 100.0)

	if is_nan(volume_linear):
		var label := Label.new()
		label.text = "Command `change_volume` requires single space separated parameter `volume_percentage`"
		label.autowrap = true
		_vbox.add_child(label)
	else:
		var volume_db : float = 20*log(float(volume_linear)/100.0)/log(10.0)
		# -INF (when new_value = 0) doesn't seem to pose any issues!
		AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Master"), volume_db)

		var label := Label.new()
		label.text = "NINJA MASTER -> I changed the master volume to {0}%, kohai!".format([volume_linear])
		label.autowrap = true
		_vbox.add_child(label)

func change_pitch(parameters : Array = []):
	var pitch_scale := NAN
	if not parameters.empty():
		pitch_scale = clamp(float(parameters[0]), 0.0, 4.0)

	if is_nan(pitch_scale):
		var label := Label.new()
		label.text = "Command `change_pitch` requires single space separated parameter `pitch_scale`"
		label.autowrap = true
		_vbox.add_child(label)
	else:
		var pitch_shift : AudioEffect = AudioServer.get_bus_effect(AudioServer.get_bus_index("Master"), 0)

		pitch_shift.pitch_scale = pitch_scale

		var label := Label.new()
		label.text = "NINJA MASTER -> I changed the master pitch to {0}, kohai!".format([pitch_scale])
		label.autowrap = true
		_vbox.add_child(label)

func update_program(parameters : Array = []):
	var program_id := ""
	if not parameters.empty():
		program_id = parameters[0]

	if program_id.empty():
		var label := Label.new()
		label.text = "Command `update` requires single space separated parameter `program_id`"
		label.autowrap = true
		_vbox.add_child(label)
	elif not program_id in State.programs.keys():
		var label := Label.new()
		label.text = "Program with `program_id` = {0} is not installed on this device".format([program_id])
		label.autowrap = true
		_vbox.add_child(label)
	elif State.get_program_by_id(program_id).show_on_boot:
		var label := Label.new()
		label.text = "Terminal failed to update `{0}`, Program is driver and should be updated at boot time.".format([program_id])
		label.autowrap = true
		_vbox.add_child(label)
	else:
		block_terminal = true
		var update_label = SCENE_UPDATE_LABEL.instance()
		update_label.connect("update_completed", self, "_on_update_completed", [], CONNECT_ONESHOT)

		update_label.program_id = program_id

		_vbox.add_child(update_label)

func install_program(parameters : Array = []):
	var program_id := ""
	if not parameters.empty():
		program_id = parameters[0]

	if program_id.empty():
		var label := Label.new()
		label.text = "Command `install` requires single space separated parameter `program_id`"
		label.autowrap = true
		_vbox.add_child(label)
	elif program_id in State.programs.keys():
		var label := Label.new()
		label.text = "Program with `program_id` = {0} is already installed on this device".format([program_id])
		label.autowrap = true
		_vbox.add_child(label)
	else:
		block_terminal = true
		var install_label = SCENE_INSTALL_LABEL.instance()
		install_label.connect("install_completed", self, "_on_install_completed", [], CONNECT_ONESHOT)

		install_label.program_id = program_id

		_vbox.add_child(install_label)

func _on_update_completed(update_text : String):
	var label := Label.new()
	label.text = update_text
	label.autowrap = true
	_vbox.add_child(label)

	block_terminal = false
	add_terminal_edit()

func _on_fetch_mail_completed(fetch_mail_text : String):
	var label := Label.new()
	label.text = fetch_mail_text
	label.autowrap = true
	_vbox.add_child(label)

	block_terminal = false
	add_terminal_edit()

func _on_install_completed(install_text : String):
	var label := Label.new()
	label.text = install_text
	label.autowrap = true
	_vbox.add_child(label)

	emit_signal("programs_updated")

	block_terminal = false
	add_terminal_edit()

func show_service_number():
	var label := Label.new()
	# Will have to be randomly generated at start by Flow.gd!
	label.text = "A5U8CC"
	label.autowrap = true

	_vbox.add_child(label)

func play_compliment():
	block_terminal = true

	var index = randi() % COMPLIMENTS.size()
	_audio_stream_player.stream = COMPLIMENTS[index]
	_audio_stream_player.play()

func _on_audio_stream_finished():
	block_terminal = false
	add_terminal_edit()

func show_help():
	for key in terminal_commands.keys():
		if terminal_commands[key].get("show_on_help", true):
			var label := Label.new()
			label.text = key + " - "
			label.text += terminal_commands[key].get("description", "no description available")
			label.autowrap = true

			_vbox.add_child(label)

func list_programs():
	for program in State.programs.values():
		if program.show_on_list:
			var label := Label.new()
			label.text = "`{0}`\nversion: {1}\ndescription: {2}\n".format([program.id, program.version, program.description])
			label.autowrap = true

			_vbox.add_child(label)

func list_minigame_stats():
	for minigame_stat in State.minigame_stats.values():
		var label := Label.new()
		if minigame_stat.has_stalemate:
			label.text = "`{0}`\ngames won: {1}\ngames lost: {2}\nstalemates: {3}\n".format([minigame_stat.id, minigame_stat.win, minigame_stat.loss, minigame_stat.stalemate])
		else:
			label.text = "`{0}`\ngames won: {1}\ngames lost: {2}\n".format([minigame_stat.id, minigame_stat.win, minigame_stat.loss])
		label.autowrap = true

		_vbox.add_child(label)

func fetch_mail():
	block_terminal = true
	var fetch_mail_label = SCENE_FETCH_MAIL_LABEL.instance()
	fetch_mail_label.connect("fetch_mail_completed", self, "_on_fetch_mail_completed", [], CONNECT_ONESHOT)

	_vbox.add_child(fetch_mail_label)

const COMPLIMENTS := [
	preload("res://resources/brenda/compliments/compliment1.ogg"),
	preload("res://resources/brenda/compliments/compliment2.ogg"),
	preload("res://resources/brenda/compliments/compliment3.ogg"),
	preload("res://resources/brenda/compliments/compliment4.ogg"),
	preload("res://resources/brenda/compliments/compliment5.ogg")
]
