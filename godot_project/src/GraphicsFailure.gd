extends Control

func _input(event : InputEvent) -> void:
	if event.is_action_pressed("restart"):
		Flow.change_scene_to("boot", get_viewport())
