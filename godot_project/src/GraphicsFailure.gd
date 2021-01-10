extends Control

const BOOT_INTERVAL := 6.0

func _ready():
	$BootTimer.wait_time = BOOT_INTERVAL
	var _error := $BootTimer.connect("timeout", self, "_on_boot_timer_timeout")

func _input(event : InputEvent) -> void:
	if event.is_action_pressed("restart"):
		$BootTimer.start()
	if event.is_action_released("restart"):
		$BootTimer.stop()

func _on_boot_timer_timeout():
	Flow.change_scene_to("boot")
