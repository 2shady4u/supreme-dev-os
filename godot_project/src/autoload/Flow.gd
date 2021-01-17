# Autoload script responsible for interacting with external resources and controlling the game flow.
extends Node

enum STATE {STARTUP, GAME, FAILURE, BOOT, GODOT_EDITOR}

var mainframe := {
	"godot": 3.1,
	"pantheon_drm_certifier": 1.3,
	"enigma_encryptor": 3.6,
	"pngeon": 66.6,
	"barracuda": 0.3,
	"minesweeper": 2.3,
	"virtual_dev_kit": 1.0
}
var failure_message := "NO CRASH!"

var _state_dict := {
	"startup": {
		"packed_scene": preload("res://src/Startup.tscn"),
		"state": STATE.STARTUP
		},
	"desktop": {
		"packed_scene": preload("res://src/Desktop.tscn"),
		"state": STATE.GAME
		},
	"failure": {
		"packed_scene": preload("res://src/Failure.tscn"),
		"state": STATE.FAILURE
		},
	"boot": {
		"packed_scene": preload("res://src/Boot.tscn"),
		"state": STATE.BOOT
		},
	"graphics_failure": {
		"packed_scene": preload("res://src/GraphicsFailure.tscn"),
		"state": STATE.BOOT
		},
	"godot_editor": {
		"packed_scene": preload("res://src/GodotEditor.tscn"),
		"state": STATE.GODOT_EDITOR
		}
	}
var _flow_state : int = STATE.STARTUP

func _ready():
	randomize()

func change_scene_to(key : String, viewport : Viewport) -> void:
	if _state_dict.has(key):
		var state_settings : Dictionary = _state_dict[key]
		var packed_scene : PackedScene = state_settings.packed_scene
		_flow_state = state_settings.state

		var error := OK
		if viewport == get_tree().get_root():
			error = get_tree().change_scene_to(packed_scene)
		elif viewport is classVirtualViewport:
			error = viewport.change_scene_to(packed_scene)

		if error != OK:
			push_error("Failed to change scene to '{0}'.".format([key]))
		else:
			print("Succesfully changed scene to '{0}'.".format([key]))
	else:
		push_error("Requested scene '{0}' was not recognized... ignoring call for changing scene.".format([key]))

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

static func save_TXT(path : String, content : String) -> void:
	# Load a TXT-file and return it as a string.
	var file : File = File.new()
	var error : int = file.open(path, File.WRITE)
	if error == OK:
		file.store_string(content)
		file.close()
	else:
		push_error("Failed to open '{0}', check file availability!".format([path]))

# Backgrounds that are available on every user system!!!
const DEFAULT_BACKGROUNDS := [
	preload("res://graphics/backgrounds/background1.jpg"),
	preload("res://graphics/backgrounds/background2.jpg"),
	preload("res://graphics/backgrounds/background3.jpg"),
	preload("res://graphics/backgrounds/background4.jpg"),
	preload("res://graphics/backgrounds/background5.jpg")
]

const USER_SETTINGS := {
	"john_doe": {
		"name": "John Doe",
		"portrait_texture": preload("res://graphics/startup/portrait_john.png"),
		"greeting": preload("res://resources/brenda/greetings/default_greeting.ogg")
	},
	"lucas_tillborg": {
		"name": "Lucas Tillborg",
		"portrait_texture": preload("res://graphics/startup/portrait_lucas.png"),
		"greeting": preload("res://resources/brenda/greetings/lucas_greeting.ogg")
	},
	"andrew_pantheon": {
		"is_root": true,
		"name": "Andrew Pantheon",
		"portrait_texture": preload("res://graphics/startup/portrait_andrew.png"),
		"greeting": preload("res://resources/brenda/greetings/andrew_greeting.ogg")
	},
	"brock_zhu": {
		"name": "Brock Zhu",
		"portrait_texture": preload("res://graphics/startup/portrait_andrew.png"),
		"greeting": preload("res://resources/brenda/greetings/default_greeting.ogg")
	}
}

const PROGRAM_SETTINGS := {
	"godot": {
		"extension": "exe",
		"name": "godot",
		"default_version": 2.1,
		"packed_scene": preload("res://src/windows/Godot.tscn"),
		"launch_dependencies": [
			{
				"id": "pantheon_drm_certifier",
				"minimum_version": 1.2,
				"failure_message": "Pantheon Inc. DRM certification module (v1.2) requires urgent update!\nPlease update immediately so satisfactory user experience can be ensured."
			},
			{
				"id": "barracuda",
				"minimum_version": 0.2,
				"failure_message": "Failed to initialize Barracuda X99-A graphics driver (v0.2)\nProgram `Godot.exe` requires minimum version 0.3"
			}
		],
		"icon_texture": preload("res://icon.png"),
		"description": "A game engine for creating both 2D and 3D games"
	},
	"settings": {
		"packed_scene": preload("res://src/windows/Settings.tscn"),
		"show_on_list": false,
		"show_on_desktop": false,
		"show_on_boot": true,
	},
	"terminal": {
		"extension": "exe",
		"name": "terminal",
		"default_version": 1.56,
		"packed_scene": preload("res://src/windows/Terminal.tscn"),
		"icon_texture": preload("res://graphics/program_icons/terminal.png"),
		"description": "Patheon Inc. certified command console"
	},
	"virtual_dev_kit": {
		"extension": "exe",
		"name": "Pantheon Vision",
		"default_version": 1.0,
		"packed_scene": preload("res://src/windows/VirtualDevKit.tscn"),
		"icon_texture": preload("res://graphics/program_icons/virtual_dev_kit.png"),
		"description": "Development kit for making Godot games in Pantheon Vision (c)"
	},
	"minesweeper": {
		"extension": "exe",
		"name": "Minesweeper",
		"default_version": 2.3,
		"icon_texture": preload("res://graphics/program_icons/minesweeper.png"),
		"packed_scene": preload("res://src/windows/Minesweeper.tscn"),
		"description": "Classical minesweeper game to play when waiting for CI/CD completion",
		"launch_dependencies": [
			{
				"id": "pantheon_drm_certifier",
				"minimum_version": 1.2,
				"failure_message": "Pantheon Inc. DRM certification module (v1.2) requires urgent update!\nPlease update immediately so satisfactory user experience can be ensured."
			}
		],
	},
	"pantheon_drm_certifier": {
		"description": "Patheon Inc. always-on DRM certification module",
		"default_version": 1.2,
		"show_on_desktop": false
	},
	"barracuda": {
		"name": "Barracuda",
		"default_version": 0.2,
		"show_on_list": false,
		"show_on_desktop": false,
		"show_on_boot": true,
		"description": "High-Fidelity Graphics Driver",
		"slogan": "At the vanguard of modern graphics!",
		"icon_texture": preload("res://graphics/program_icons/barracuda.png"),
		"can_be_uninstalled" : true
	},
	"supreme_dev_os": {
		"default_version": 5.65,
		"show_on_list": false,
		"show_on_desktop": false
	},
	"ninja": {
		"name": "NINJA MASTER",
		"default_version": 9.1,
		"show_on_list": false,
		"show_on_desktop": false,
		"show_on_boot": true,
		"description": "Sound driver for pitch-perfect sound design",
		"icon_texture": preload("res://graphics/program_icons/ninja.png"),
		"slogan": "The Art of Silence",
		"hidden_commands": [{
			"id": "change_volume",
			"inputs": ["volume_percentage"],
			"description": "Change the master volume of the NINJA MASTER sound card.\nInput values are clamped between 0 and 100."
		},{
			"id": "change_pitch",
			"inputs": ["pitch_scale"],
			"description": "Change the master pitch scale of the NINJA MASTER sound card.\nInput values are clamped between 0 and 4."
		}]
	},
	"brendai": {
		"name": "BrendAI (AI Companion)",
		"default_version": 4.01,
		"show_on_list": false,
		"show_on_desktop": false,
		"show_on_boot": true,
		"description": "State-of-the-Art AI for companionship during game development",
		"icon_texture": preload("res://graphics/program_icons/brendai.png"),
		"slogan": "Your companion till the very end",
		"can_be_uninstalled" : true,
		"hidden_commands": [{
			"id": "minigame_stats",
			"inputs": [],
			"description": "Print out win/loss/stalemate statistics for all BrendAI approved minigames."
		},{
			"id": "fetch_mail",
			"inputs": [],
			"description": "Fetch latest mails from the Panther mail server."
		},{
			"id": "service_number",
			"inputs": [],
			"description": "Print out the service number of this device."
		}]
	},
	"tic_tac_toe": {
		"extension": "exe",
		"name": "Tic-Tac-Toe",
		"default_version": 0.1,
		"description": "Classical tic-tac-toe game to play during dev burn-out against BrendAI",
		"icon_texture": preload("res://graphics/program_icons/tic_tac_toe.png"),
		"packed_scene": preload("res://src/windows/TicTacToe.tscn"),
		"launch_dependencies": [
			{
				"id": "pantheon_drm_certifier",
				"minimum_version": 1.2,
				"failure_message": "Pantheon Inc. DRM certification module (v1.2) requires urgent update!\nPlease update immediately so satisfactory user experience can be ensured."
			},
			{
				"id": "brendai",
				"minimum_version": 0.0,
				"failure_message": "Launch dependency `brendai` could not be satisfied!\nProgram `Tic-Tac-Toe.exe` requires minimum version 3.12"
			}
		],
	},
	"olympus": {
		"extension": "exe",
		"name": "Olympus",
		"default_version": 4.12,
		"description": "Default file viewer & browser",
		"icon_texture": preload("res://graphics/program_icons/olympus.png"),
		"packed_scene": preload("res://src/windows/Olympus.tscn"),
		"launch_dependencies": [
			{
				"id": "pantheon_drm_certifier",
				"minimum_version": 1.2,
				"failure_message": "Pantheon Inc. DRM certification module (v1.2) requires urgent update!\nPlease update immediately so satisfactory user experience can be ensured."
			}
		],
	},
	"enigma_encryptor": {
		"show_on_list": true,
		"show_on_desktop": false,
		"name": "Enigma Encryptor",
		"default_version": 3.6,
		"description": "Unhackable Encryptor/Decryptor for text files"
	},
	"pngeon": {
		"show_on_list": true,
		"show_on_desktop": false,
		"name": "PNGeon",
		"default_version": 66.6,
		"description": "Pantheon Certified PNG image viewer"
	}
}
