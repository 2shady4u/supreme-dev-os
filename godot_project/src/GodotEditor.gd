extends Control

const DURATION := 1.0
const END_DURATION := 5.0

onready var _loading_tween := $LoadingTween
onready var _end_tween := $EndTween
onready var _end_timer := $EndTimer

onready var _loading_rect := $CrashControl/LoadingRect
onready var _crash_control := $CrashControl

onready var _end_control := $EndControl

func _ready():
	var _error := _end_timer.connect("timeout", self, "_on_end_timer_timeout")
	_error = _end_tween.connect("tween_all_completed", self, "_on_end_tween_all_completed")

	_error = $Panel/VB/HB/SceneButton.connect("pressed", self, "_on_touch_anything")
	_error = $Panel/VB/HB/ProjectButton.connect("pressed", self, "_on_touch_anything")
	_error = $Panel/VB/HB/DebugButton.connect("pressed", self, "_on_touch_anything")
	_error = $Panel/VB/HB/EditorButton.connect("pressed", self, "_on_touch_anything")
	_error = $Panel/VB/HB/HelpButton.connect("pressed", self, "_on_touch_anything")

	_end_timer.wait_time = END_DURATION
	set_process_input(false)

	_crash_control.visible = false
	_end_control.visible = false

func _on_touch_anything():
	initiate_crash()

func _input(event : InputEvent) -> void:
	if event.is_action_pressed("restart"):
		Flow.change_scene_to("startup", get_viewport())

func initiate_crash():
	_crash_control.visible = true

	_loading_tween.interpolate_property(_loading_rect, "rect_rotation", 0, 360, DURATION, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	_loading_tween.repeat = true
	_loading_tween.start()

	_end_timer.start()

func _on_end_timer_timeout():
	_end_control.visible = true
	_end_control.modulate.a = 0

	_end_tween.interpolate_property(_end_control, "modulate:a", 0, 1, DURATION, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	_end_tween.start()

func _on_end_tween_all_completed():
	set_process_input(true)
