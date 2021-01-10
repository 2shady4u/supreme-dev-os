class_name classProgram
extends Reference

var id := ""
var version := 0.0

var context : Dictionary setget set_context
func set_context(value : Dictionary) -> void:
	if not value.has("id"):
		push_error("Program context requires id!")
		return

	id = value.id
	version = value.get("version", self.default_version)

func check_launch_dependencies() -> bool:
	for dependency in self.launch_dependencies:
		if not dependency.has("id"):
			push_error("Depency without an id!")
			continue
		var program : Reference = State.get_program_by_id(dependency.id)
		var minimum_version = dependency.minimum_version

		if program.version < minimum_version:
			# Also add the crash message to the flow!
			Flow.failure_message = dependency.failure_message
			return false
	return true

# These are all constants derived from reporting.JSON and should be treated as such!
var name : String setget , get_name
func get_name() -> String:
	return Flow.get_program_value(id, "name", "MISSING NAME")

var extension : String setget , get_extension
func get_extension() -> String:
	return Flow.get_program_value(id, "extension", "MISSING EXTENSION")

var slogan : String setget , get_slogan
func get_slogan() -> String:
	return Flow.get_program_value(id, "slogan", "MISSING SLOGAN")

var description : float setget , get_description
func get_description() -> float:
	return Flow.get_program_value(id, "description", "MISSING DESCRIPTION")

var icon_texture : String setget , get_icon_texture
func get_icon_texture() -> String:
	return Flow.get_program_value(id, "icon_texture", preload("res://icon.png"))

var show_on_list : bool setget , get_show_on_list
func get_show_on_list() -> bool:
	return Flow.get_program_value(id, "show_on_list", true)

var show_on_desktop : bool setget , get_show_on_desktop
func get_show_on_desktop() -> bool:
	return Flow.get_program_value(id, "show_on_desktop", true)

var show_on_boot : bool setget , get_show_on_boot
func get_show_on_boot() -> bool:
	return Flow.get_program_value(id, "show_on_boot", false)

var default_version : bool setget , get_default_version
func get_default_version() -> bool:
	return Flow.get_program_value(id, "default_version", true)

var launch_dependencies : Dictionary setget , get_launch_dependencies
func get_launch_dependencies() -> Dictionary:
	return Flow.get_program_value(id, "launch_dependencies", [])
