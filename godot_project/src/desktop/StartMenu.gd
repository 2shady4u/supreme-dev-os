extends MenuButton

onready var popup : Popup = get_popup()

enum ITEM {LOG_OUT, SETTINGS}

signal program_launched

func _ready():
	popup.add_item("Log Out", ITEM.LOG_OUT)
	popup.add_item("Settings", ITEM.SETTINGS)

	var _error : int = popup.connect("id_pressed", self, "_on_button_pressed")

func _on_button_pressed(int_id : int) -> void:
	match int_id:
		ITEM.LOG_OUT:
			Flow.change_scene_to("startup", get_viewport())
		ITEM.SETTINGS:
			emit_signal("program_launched", "settings")
