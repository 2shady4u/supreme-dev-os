extends Control

func _ready():
	$VBoxContainer/PanelContainer/FailureLabel.text = Flow.failure_message

func _input(event : InputEvent):
	if event.is_action_pressed("restart"):
		Flow.change_scene_to("startup")
