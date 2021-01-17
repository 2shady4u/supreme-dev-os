extends Control

const DURATION := 1.0
const BOOT_INTERVAL := 6.0

onready var _tween := $Tween

var loading_index := 0
var is_loading := false

func _ready():
	var _error := $VB/LogInButton.connect("pressed", self, "_on_log_in_button_pressed")
	_error = $LoadingTimer.connect("timeout", self, "_on_loading_timer_timeout")
	_error = $BootTimer.connect("timeout", self, "_on_boot_timer_timeout")

	$BootTimer.wait_time = BOOT_INTERVAL

	var user : classUser = State.user
	$VB/VB/TextureRect/PortraitRect.texture = user.portrait_texture
	$BackgroundRect.texture = user.background_texture
	$VB/VB/NameLabel.text = user.name

	$VB/LoadingControl/VB.visible = false

func _on_log_in_button_pressed() -> void:
	$VB/LogInButton.disabled = true

	_tween.interpolate_property($VB/LoadingControl/VB/TextureRect, "rect_rotation", 0, 360, DURATION, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	_tween.repeat = true
	_tween.start()

	is_loading = true
	$BootTimer.stop()

	load_next_stage()

	$VB/LoadingControl/VB.visible = true

func load_next_stage():
	if loading_index < LOADING_MESSAGES.size():
		var loading_message : Dictionary = LOADING_MESSAGES[loading_index]
		$VB/LoadingControl/VB/Label.text = loading_message.text
		$LoadingTimer.wait_time = loading_message.wait_time
		$LoadingTimer.start()
		loading_index += 1
	else:
		Flow.change_scene_to("desktop", get_viewport())

func _on_loading_timer_timeout():
	load_next_stage()

func _on_boot_timer_timeout():
	Flow.change_scene_to("boot", get_viewport())

func _input(event):
	if is_loading:
		return

	if event.is_action_pressed("restart"):
		$BootTimer.start()
	if event.is_action_released("restart"):
		$BootTimer.stop()

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
