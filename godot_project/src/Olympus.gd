extends WindowDialog

func _ready():
	var _error := $VBoxContainer/PanelContainer/HBoxContainer/FileMenu.connect("open_pressed", self, "_on_open_pressed")
	_error = $FileDialog.connect("file_selected", self, "_on_file_selected")

func _on_open_pressed():
	$FileDialog.popup_centered()

func _on_file_selected(path : String):
	if check_dependencies(path.get_extension()):
		$VBoxContainer/ContentContainer.update_content(path)
	else:
		Flow.change_scene_to("failure")

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
	"png": [{
		"id": "pngeon",
		"minimum_version": 0.0,
		"failure_message": "Olympus could not satisfy loading dependency of the `PNG` file format!\nRECOMMENDATION: install program `pngeon` to be able to load `PNG` file format."
	}]
}
