class_name classWindow
extends Panel

var _reset_position : Vector2
var _previous_mouse_position : Vector2
var _is_dragging := false

signal window_closed

var taskbar_button : Button

var header_text : String setget set_header_text
func set_header_text(value : String):
	header_text = value
	if is_inside_tree():
		$VB/PC/HB/HeaderLabel.text = header_text

func _ready():
	var _error := $VB/PC/HB/CloseButton.connect("pressed", self, "_on_close_button_pressed")
	_error = $VB/PC/HB/MinimizeButton.connect("pressed", self, "_on_minimize_button_pressed")
	_error = $VB/PC.connect("gui_input", self, "_on_gui_input")

	$VB/PC/HB/HeaderLabel.text = header_text

	_reset_position = rect_position

func _process(_delta):
	if _is_dragging:
		var mouse_delta = _previous_mouse_position - get_local_mouse_position()
		rect_position -= mouse_delta

func _on_gui_input(event):
	if event.is_action_pressed("LMB"):
		_is_dragging = true
		_previous_mouse_position = get_local_mouse_position()
	if event.is_action_released("LMB"):
		_is_dragging = false

func show():
	rect_position = _reset_position
	visible = true

func hide():
	visible = false

func _on_close_button_pressed():
	emit_signal("window_closed")
	hide()

func _on_minimize_button_pressed():
	taskbar_button.pressed = false
