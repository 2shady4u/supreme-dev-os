extends classWindow

var SCENE_STARTUP := load("res://src/Startup.tscn")

func _ready():
	$VB/ViewportContainer/Viewport.change_scene_to(SCENE_STARTUP)

	self.header_text = "Pantheon Vision - PROTOTYPE"
