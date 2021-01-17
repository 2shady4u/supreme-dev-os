extends classWindow

onready var _file_menu := $VB/VB/PC/HB/FileMenu
onready var _content := $VB/VB/Content

func _ready():
	var _error := _file_menu.connect("open_pressed", self, "_on_open_pressed")
	_error = $FileDialog.connect("file_selected", self, "_on_file_selected")

	var program : classProgram = State.get_program_by_id("olympus")
	self.header_text = "Olympus (version {0})".format([program.version])

func _on_open_pressed():
	$FileDialog.popup_centered()

func _on_file_selected(path : String):
	if check_dependencies(path.get_extension()):
		print(path)
		_content.update_content(path)
	else:
		Flow.change_scene_to("failure", get_viewport())

func check_dependencies(extension : String) -> bool:
	for dependency in LOAD_DEPENDENCIES.get(extension, []):
		if not dependency.has("id"):
			push_error("Depency without an id!")
			continue
		var program : Reference = State.get_program_by_id(dependency.id)
		var minimum_version = dependency.minimum_version

		if program:
			if program.version < minimum_version:
				# Also add the crash message to the flow!
				Flow.failure_message = dependency.failure_message
				return false
		else:
			Flow.failure_message = dependency.failure_message
			return false
	return true

const LOAD_DEPENDENCIES := {
	"txt": [],
	"enc": [{
		"id": "enigma_encryptor",
		"minimum_version": 0.0,
		"failure_message": "Olympus could not satisfy loading dependency of the `ENC` file format!\nRECOMMENDATION: install program `ERROR:: PROGRAM BLOCKLISTED BY PANTHEON` to be able to load `ENC` file format."
	}],
	"import": [{
		"id": "pngeon",
		"minimum_version": 0.0,
		"failure_message": "Olympus could not satisfy loading dependency of the `PNG` file format!\nRECOMMENDATION: install program `pngeon` to be able to load `PNG` file format."
	}]
}
