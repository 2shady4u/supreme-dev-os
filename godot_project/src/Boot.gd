extends Control

func _ready():
	pass # Replace with function body.

func _input(event : InputEvent):
	if event.is_action_pressed("restart"):
		Flow.change_scene_to("startup")
	elif event.is_action_pressed("restart_with_boot"):
		Flow.change_scene_to("boot")
