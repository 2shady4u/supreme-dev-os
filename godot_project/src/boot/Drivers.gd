extends ScrollContainer

const SCENE_DRIVER_CONTAINER := preload("res://src/boot/DriverContainer.tscn")

signal settings_button_pressed

func _ready():
	update_list()

func update_list():
	for child in $VB.get_children():
		$VB.remove_child(child)
		child.queue_free()

	for program in State.programs.values():
		if program.show_on_boot:
			var driver := SCENE_DRIVER_CONTAINER.instance()

			var _error : int = driver.connect("pressed", self, "_on_settings_button_pressed", [program.id])

			driver.program = program
			$VB.add_child(driver)

func _on_driver_updated():
	update_list()

func _on_settings_button_pressed(program_id : String) -> void:
	emit_signal("settings_button_pressed", program_id)
