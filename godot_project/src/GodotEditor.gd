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

	_error = $Panel/VB/TopHBox/SceneButton.connect("pressed", self, "_on_touch_anything")
	_error = $Panel/VB/TopHBox/ProjectButton.connect("pressed", self, "_on_touch_anything")
	_error = $Panel/VB/TopHBox/DebugButton.connect("pressed", self, "_on_touch_anything")
	_error = $Panel/VB/TopHBox/EditorButton.connect("pressed", self, "_on_touch_anything")
	_error = $Panel/VB/TopHBox/HelpButton.connect("pressed", self, "_on_touch_anything")

	_error = $Panel/VB/PC/HB/CloseButton.connect("pressed", self, "_on_touch_anything")
	_error = $Panel/VB/PC/HB/MinimizeButton.connect("pressed", self, "_on_touch_anything")

	_error = $Panel/VB/BottomHBox/MiddleVBox/PC/HB/OutputButton.connect("pressed", self, "_on_touch_anything")
	_error = $Panel/VB/BottomHBox/MiddleVBox/PC/HB/DebuggerButton.connect("pressed", self, "_on_touch_anything")
	_error = $Panel/VB/BottomHBox/MiddleVBox/PC/HB/AudioButton.connect("pressed", self, "_on_touch_anything")
	_error = $Panel/VB/BottomHBox/MiddleVBox/PC/HB/AnimationButton.connect("pressed", self, "_on_touch_anything")

	_error = $Panel/VB/BottomHBox/RightTab.connect("tab_changed", self, "_on_touch_anything")
	_error = $Panel/VB/BottomHBox/VBoxContainer/LeftTopTab.connect("tab_changed", self, "_on_touch_anything")

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
