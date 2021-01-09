# Autoload script responsible for interacting with external resources and controlling the game flow.
extends Node

enum STATE {STARTUP, GAME, FAILURE, BOOT}

const DATA_PATH := "res://resources/data.json"

var mainframe := {
	"godot": 3.1,
	"pantheon_drm_certifier": 1.3
}
var failure_message := "NO CRASH!"

var _state_dict := {
	"startup": {
		"packed_scene": preload("res://src/Startup.tscn"),
		"state": STATE.STARTUP
		},
	"game": {
		"packed_scene": preload("res://src/Game.tscn"),
		"state": STATE.GAME
		},
	"failure": {
		"packed_scene": preload("res://src/Failure.tscn"),
		"state": STATE.FAILURE
		},
	"boot": {
		"packed_scene": preload("res://src/Boot.tscn"),
		"state": STATE.BOOT
		}
	}
var _flow_state : int = STATE.STARTUP

func _ready():
	pass

func change_scene_to(key : String) -> void:
	if _state_dict.has(key):
		var state_settings : Dictionary = _state_dict[key]
		var packed_scene : PackedScene = state_settings.packed_scene
		_flow_state = state_settings.state

		var error := get_tree().change_scene_to(packed_scene)
		get_tree().paused = false
		if error != OK:
			push_error("Failed to change scene to '{0}'.".format([key]))
		else:
			print("Succesfully changed scene to '{0}'.".format([key]))
	else:
		push_error("Requested scene '{0}' was not recognized... ignoring call for changing scene.".format([key]))

func get_program_value(id : String, key : String, default):
	if PROGRAM_SETTINGS.has(id):
		var data : Dictionary = PROGRAM_SETTINGS[id]
		return data.get(key, default)
	else:
		return default

# STATIC FUNCTIONS
static func load_JSON(path : String) -> Dictionary:
	var file : File = File.new()
	var error : int = file.open(path, File.READ)
	if error == OK:
		var text : String = file.get_as_text()
		file.close()
		var parse_result = parse_json(text)
		if parse_result is Dictionary:
			return parse_result
		elif parse_result is Array:
			push_error("Top-level arrays in JSON are not allowed! (@ '{0}')".format([path]))
		else:
			push_error("Failed to correctly process '{0}', check file format!".format([path]))
		return {}
	else:
		push_error("Failed to open '{0}', check file availability!".format([path]))
		return {}

static func load_TXT(path : String) -> String:
	# Load a TXT-file and return it as a string.
	var file : File = File.new()
	var string : String = ""
	var error : int = file.open(path, File.READ)
	if error == OK:
		string = file.get_as_text()
		file.close()
		return string
	else:
		push_error("Failed to open '{0}', check file availability!".format([path]))
		return ""

const PROGRAM_SETTINGS := {
	"godot": {
		"extension": "exe",
		"name": "godot",
		"default_version": 2.1,
		"launch_dependencies": [
			{
				"id": "pantheon_drm_certifier",
				"minimum_version": 1.3,
				"failure_message": "Pantheon Inc. DRM certification module (v1.2) requires urgent update!\nPlease update immediately so satisfactory user experience can be ensured."
			},
			{
				"id": "barracuda",
				"minimum_version": 0.3,
				"failure_message": "Failed to initialize Baracuda X99-A graphics driver (v0.2)\nProgram `Godot.exe` requires minimum version 0.3"
			}
		],
		"icon_texture": preload("res://icon.png"),
		"description": "A game engine for creating both 2D and 3D games"
	},
	"terminal": {
		"extension": "exe",
		"name": "terminal",
		"default_version": 1.56,
		"icon_texture": preload("res://graphics/program_icons/terminal.png"),
		"description": "Patheon Inc. certified command console"
	},
	"pantheon_drm_certifier": {
		"description": "Patheon Inc. always-on DRM certification module",
		"default_version": 1.2,
		"show_on_desktop": false
	},
	"barracuda": {
		"default_version": 0.2,
		"show_on_list": false,
		"show_on_desktop": false
	},
	"supreme_dev_os": {
		"default_version": 5.65,
		"show_on_list": false,
		"show_on_desktop": false
	}
}
