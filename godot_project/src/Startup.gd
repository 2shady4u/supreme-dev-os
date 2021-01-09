extends Control

const DURATION := 1.0

var loading_index := 0

func _ready():
	var _error := $VB/LogInButton.connect("pressed", self, "_on_log_in_button_pressed")
	_error = $Timer.connect("timeout", self, "_on_timer_timeout")

	var supreme_dev_os : classProgram = State.get_program_by_id("supreme_dev_os")
	$VB/Label.text = "Supreme Dev OS\nversion {0}".format([supreme_dev_os.version])

	$VB/LoadingControl/VB.visible = false

func _on_log_in_button_pressed() -> void:
	$VB/LogInButton.disabled = true

	$Tween.interpolate_property($VB/LoadingControl/VB/TextureRect, "rect_rotation", 0, 360, DURATION, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	$Tween.repeat = true
	$Tween.start()

	load_next_stage()

	$VB/LoadingControl/VB.visible = true

func load_next_stage():
	if loading_index < LOADING_MESSAGES.size():
		var loading_message : Dictionary = LOADING_MESSAGES[loading_index]
		$VB/LoadingControl/VB/Label.text = loading_message.text
		$Timer.wait_time = loading_message.wait_time
		$Timer.start()
		loading_index += 1
	else:
		Flow.change_scene_to("game")

func _on_timer_timeout():
	load_next_stage()

const LOADING_MESSAGES := [
	{
		"text": "Bootstrapping kernel...",
		"wait_time": 1.0
	},{
		"text": "Preparing graphical environment...",
		"wait_time": 2.0
	},{
		"text": "Downloading more RAM... (1/3)",
		"wait_time": 0.5
	},{
		"text": "Downloading more RAM... (2/3)",
		"wait_time": 0.5
	},{
		"text": "Downloading more RAM... (3/3)",
		"wait_time": 0.5
	},{
		"text": "Finalizing login process...",
		"wait_time": 1.0
	}
]
