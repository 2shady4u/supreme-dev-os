extends Control

const SCENE_DESKTOP_ICON := preload("res://src/base/DesktopIcon.tscn")
const SCENE_TASKBAR_BUTTON := preload("res://src/base/TaskbarButton.tscn")

const MAX_ROWS := 5

const MAX_WINDOWS := 20
const MAX_WINDOWS_REACHED := "You have reached the maximum number of open windows (= 20)\nPlease purchase the PRO version of Supreme Dev OS for unlimited windows."

onready var _background_rect := $BackgroundRect
onready var _audio_stream_player := $AudioStreamPlayer
onready var _desktop_icons_container := $DesktopIcons
onready var _windows_container := $Windows
onready var _taskbar := $VB/PC/HB/Control/SC/Taskbar

var row_index := 0
var column_index := 0

var programs := []
var windows := []

func _ready():
	var _error := $VB/PC/HB/StartMenu.connect("program_launched", self, "_on_program_launched")
	_error = State.connect("background_changed", self, "_on_background_changed")
	_error = State.connect("programs_changed", self, "_on_programs_changed")

	for child in _desktop_icons_container.get_children():
		_desktop_icons_container.remove_child(child)
		child.queue_free()
	for child in _taskbar.get_children():
		_taskbar.remove_child(child)
		child.queue_free()

	for program in State.programs.values():
		if program.show_on_desktop:
			_add_desktop_icon(program)

	var user : classUser = State.user
	if user:
		_background_rect.texture = user.background_texture
		var brendai : classProgram = State.get_program_by_id("brendai")
		if brendai and brendai.is_installed:
			_audio_stream_player.stream = user.greeting
			_audio_stream_player.play()
			if user.id == "lucas_tillborg":
				_error = _audio_stream_player.connect("finished", self, "_on_audio_stream_player_finished")

func _on_background_changed(background_texture : Texture):
	_background_rect.texture = background_texture

func _on_audio_stream_player_finished():
	# Lucas' account is terminated!!!
	Flow.change_scene_to("startup", get_viewport())

func _on_program_launched(program_id : String):
	var program : classProgram = State.get_program_by_id(program_id)
	var packed_scene : PackedScene = program.packed_scene
	if packed_scene:
		_add_window(packed_scene)

func _on_window_closed(window : classWindow) -> void:
	windows.erase(window)

	var taskbar_button := window.taskbar_button
	_taskbar.remove_child(taskbar_button)
	taskbar_button.queue_free()

	_windows_container.remove_child(window)
	window.queue_free()

func _on_taskbar_button_toggled(toggled : bool, window : classWindow) -> void:
	if toggled:
		window.show()
	else:
		window.hide()

func _on_programs_changed():
	for program in State.programs.values():
		if program.show_on_desktop:
			if not program.id in programs:
				_add_desktop_icon(program)

func _add_desktop_icon(program : classProgram) -> void:
	var desktop_icon := SCENE_DESKTOP_ICON.instance()
	desktop_icon.name = program.id

	var _error : int = desktop_icon.connect("launch_program", self, "_on_program_launched", [program.id])

	if program.id == "godot":
		desktop_icon.rect_position = Vector2(464, 240)
	else:
		desktop_icon.rect_position.x = 24 + (column_index)*(64+48)
		desktop_icon.rect_position.y = 64 + (row_index)*(64+48)
		row_index += 1
		if row_index >= 4:
			row_index -= 4
			column_index += 1

	programs.append(program.id)

	desktop_icon.program = program
	_desktop_icons_container.add_child(desktop_icon)

func _add_window(packed_scene : PackedScene):
	var window : classWindow = packed_scene.instance()
	var _error : int = window.connect("window_closed", self, "_on_window_closed", [window])
	var window_name := window.name # Get the name BEFORE it gets corrupted!
	_windows_container.add_child(window)

	var taskbar_button := SCENE_TASKBAR_BUTTON.instance()
	_error = taskbar_button.connect("toggled", self, "_on_taskbar_button_toggled", [window])

	taskbar_button.text = window_name
	taskbar_button.pressed = true

	window.taskbar_button = taskbar_button

	_taskbar.add_child(taskbar_button)

	windows.append(window)
	if windows.size() > MAX_WINDOWS:
		Flow.failure_message = MAX_WINDOWS_REACHED
		Flow.change_scene_to("failure", get_viewport())
