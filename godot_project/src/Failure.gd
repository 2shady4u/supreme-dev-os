extends Control

const BOOT_INTERVAL := 6.0

func _ready():
	var _error := $BootTimer.connect("timeout", self, "_on_boot_timer_timeout")
	State.add_crash_log()

	$VBoxContainer/PanelContainer/FailureLabel.text = Flow.failure_message

	$BootTimer.wait_time = BOOT_INTERVAL

	$AudioStreamPlayer.play()

func _input(event : InputEvent) -> void:
	if event.is_action_pressed("restart"):
		$BootTimer.start()
	if event.is_action_released("restart"):
		$BootTimer.stop()
		Flow.change_scene_to("startup", get_viewport())

func _on_boot_timer_timeout():
	Flow.change_scene_to("boot", get_viewport())
