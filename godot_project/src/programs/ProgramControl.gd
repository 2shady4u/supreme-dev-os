extends Control

var mouse_inside := false
var mouse_offset := Vector2.ZERO

var program : classProgram setget set_program, get_program
func set_program(value : classProgram) -> void:
	_program = weakref(value)
func get_program() -> classProgram:
	return _program.get_ref()

var _program := WeakRef.new()

signal launch_program

func _ready():
	set_process(false)
	update_program()

	if not Engine.editor_hint:
		var _error := $VB/TextureButton.connect("mouse_entered", self, "_on_texture_button_mouse_entered")
		_error = $VB/TextureButton.connect("mouse_exited", self, "_on_texture_button_mouse_exited")

func update_program():
	var local_program := self.program
	if local_program:
		$VB/Label.text = local_program.name + "." + local_program.extension
		$VB/TextureButton.texture_normal = local_program.icon_texture

func _input(event : InputEvent):
	if mouse_inside and event.is_action_pressed("LMB"):
		print("start dragging")
		mouse_offset = rect_position - get_global_mouse_position()
		set_process(true)
	elif event.is_action_released("LMB"):
		set_process(false)

	if mouse_inside and event.is_action_pressed("LMB") and event.doubleclick:
		print("double clicked!")
		# Check if the application can actually be launched!
		if self.program.check_launch_dependencies():
			emit_signal("launch_program")
		else:
			Flow.change_scene_to("failure")

func _process(_delta):
	rect_position = get_global_mouse_position() + mouse_offset

func _on_texture_button_mouse_entered():
	print("mouse inside")
	mouse_inside = true

func _on_texture_button_mouse_exited():
	print("mouse outside")
	mouse_inside = false
