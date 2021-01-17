extends Label

var dots := [".", "..", "...", ".."]
var index := 0
var program_id := ""

const DOT_DURATION := 0.5
const UPDATE_DURATION := 2.0

var current_duration := 0.0

const ALREADY_UP_TO_DATE := "You already have the latest version of `{0}`"
const NEW_VERSION := "`{0}` has been successfully updated to version {1}!"

signal update_completed

func _ready():
	var _error := $Timer.connect("timeout", self, "_on_timer_timeout")

	update_text()
	$Timer.start()

func update_text():
	text = "Polling Pantheon Mainframe for latest version of program `{0}`{1}".format([program_id, dots[index]])

func update_program():
	var update_text := ALREADY_UP_TO_DATE.format([program_id])
	if Flow.mainframe.has(program_id):
		var program = State.get_program_by_id(program_id)
		var mainframe_version = Flow.mainframe[program_id]
		if mainframe_version > program.version:
			program.version = mainframe_version
			update_text = NEW_VERSION.format([program_id, mainframe_version])

	emit_signal("update_completed", update_text)

func _on_timer_timeout():
	index = wrapi(index + 1 , 0, dots.size())
	update_text()

	current_duration += DOT_DURATION
	if current_duration > UPDATE_DURATION:
		update_program()
	else:
		$Timer.start()

