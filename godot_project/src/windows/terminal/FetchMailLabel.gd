extends Label

var dots := [".", "..", "...", ".."]
var index := 0
var program_id := ""

const DOT_DURATION := 0.5
const UPDATE_DURATION := 2.0

var current_duration := 0.0

const NO_NEW_MAILS := "No new mails could be fetched from the Panther Mail Server"
const NEW_MAILS := "SUCCESS: New mails have been added to your `documents`-folder!"

signal fetch_mail_completed

func _ready():
	var _error := $Timer.connect("timeout", self, "_on_timer_timeout")

	update_text()
	$Timer.start()

func update_text():
	text = "Polling Panther Mail Server for new mails{1}".format([program_id, dots[index]])

func update_program():
	var fetch_mail_text := NO_NEW_MAILS.format([program_id])
	if not State.fetched_mails:
		fetch_mail_text = NEW_MAILS
		State.copy_folder_content("res://mail_server", "user://")
		State.fetched_mails = true

	emit_signal("fetch_mail_completed", fetch_mail_text)

func _on_timer_timeout():
	index = wrapi(index + 1 , 0, dots.size())
	update_text()

	current_duration += DOT_DURATION
	if current_duration > UPDATE_DURATION:
		update_program()
	else:
		$Timer.start()

