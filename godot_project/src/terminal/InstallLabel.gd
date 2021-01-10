extends Label

var dots := [".", "..", "...", ".."]
var index := 0
var program_id := ""

const DOT_DURATION := 0.5
const INSTALL_DURATION := 2.0

var current_duration := 0.0

const NOT_FOUND := "Pantheon Mainframe does not recognize requested program with id `{0}`"
const INSTALLED_SUCCESFULLY := "`{0}` (with version {1}) has been successfully installed on host device!"

signal install_completed

func _ready():
	var _error := $Timer.connect("timeout", self, "_on_timer_timeout")

	update_text()
	$Timer.start()

func update_text():
	text = "Polling Pantheon Mainframe for latest version of program `{0}`{1}".format([program_id, dots[index]])

func update_program():
	var install_text := NOT_FOUND.format([program_id])
	if Flow.mainframe.has(program_id):
		State.add_program_by_id(program_id)

		var program = State.get_program_by_id(program_id)
		var mainframe_version = Flow.mainframe[program_id]
		program.version = mainframe_version

		install_text = INSTALLED_SUCCESFULLY.format([program_id, mainframe_version])

	emit_signal("install_completed", install_text)

func _on_timer_timeout():
	index = wrapi(index + 1 , 0, dots.size())
	update_text()

	current_duration += DOT_DURATION
	if current_duration > INSTALL_DURATION:
		update_program()
	else:
		$Timer.start()

